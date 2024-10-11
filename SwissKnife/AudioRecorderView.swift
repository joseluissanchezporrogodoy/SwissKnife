//
//  AudioRecorderView.swift
//  TestGitPR
//
//  Created by JLSANCHEZP on 3/10/24.
//

import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                if audioRecorder.isRecording {
                    Text("Grabando... \(audioRecorder.recordingTimeFormatted)")
                        .font(.headline)
                        .padding()
                    
                    AudioWaveView(audioLevel: audioRecorder.audioLevel)
                        .frame(height: 100)
                        .padding()
                }
                
                Button(action: {
                    audioRecorder.isRecording ? audioRecorder.stopRecording() : audioRecorder.startRecording()
                }) {
                    Text(audioRecorder.isRecording ? "Detener Grabación" : "Iniciar Grabación")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(audioRecorder.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                List {
                    ForEach(audioRecorder.recordings, id: \.url) { recording in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(recording.title)
                                Text("\(recording.durationFormatted)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: audioRecorder.isPlaying(recording) ? "pause.circle.fill" : "play.circle.fill")
                                .foregroundColor(audioRecorder.isPlaying(recording) ? .red : .blue)
                        }
                        .contentShape(Rectangle()) // Hace que toda la fila sea interactuable
                        .onTapGesture {
                            audioRecorder.togglePlayback(recording)
                        }
                    }
                    .onDelete(perform: isEditing ? audioRecorder.deleteRecording : nil)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Grabadora")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Hecho" : "Editar") {
                        isEditing.toggle()
                    }
                }
            }
            .onAppear {
                audioRecorder.requestPermission()
                audioRecorder.loadRecordings()
            }
        }
    }
}

class AudioRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    @Published var isRecording = false
    @Published var recordings: [Recording] = []
    @Published var audioLevel: Float = 0.0
    @Published var recordingTimeFormatted = "00:00"
    @Published var currentPlayingURL: URL? // URL de la grabación actual en reproducción
    private var currentPlaybackTime: TimeInterval = 0.0 // Tiempo actual de reproducción
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("Permiso para usar el micrófono denegado.")
            }
        }
    }
    
    func startRecording() {
        configureAudioSession() // Configurar el AVAudioSession antes de comenzar a grabar
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy,HH:mm:ss"
        let filename = "record_\(formatter.string(from: Date())).m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)
        
        print("Ruta del archivo de grabación: \(audioFilename)") // Verifica la ruta del archivo
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            startTimer()
        } catch {
            print("No se pudo iniciar la grabación: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
        loadRecordings() // Cargar las grabaciones después de detener la grabación
        deactivateAudioSession() // Desactivar el AVAudioSession al finalizar la grabación
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Error al configurar el AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch {
            print("Error al desactivar el AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    func togglePlayback(_ recording: Recording) {
        if isPlaying(recording) {
            pausePlayback()
        } else {
            playRecording(recording)
        }
    }
    
    func playRecording(_ recording: Recording) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: recording.url.path) {
            do {
                if audioPlayer == nil || currentPlayingURL != recording.url {
                    audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
                    audioPlayer?.delegate = self
                    currentPlaybackTime = 0.0
                }
                audioPlayer?.currentTime = currentPlaybackTime
                audioPlayer?.play()
                currentPlayingURL = recording.url
            } catch {
                print("No se pudo reproducir la grabación: \(error.localizedDescription)")
            }
        } else {
            print("El archivo de audio no existe en la ruta: \(recording.url.path)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        currentPlaybackTime = audioPlayer?.currentTime ?? 0.0
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        currentPlaybackTime = 0.0
        currentPlayingURL = nil
    }
    
    func isPlaying(_ recording: Recording) -> Bool {
        return currentPlayingURL == recording.url && audioPlayer?.isPlaying == true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateAudioLevel()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateAudioLevel() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        audioLevel = audioRecorder.averagePower(forChannel: 0)
        
        let normalizedLevel = normalizeAudioLevel(audioLevel)
        DispatchQueue.main.async {
            self.audioLevel = normalizedLevel
        }
        
        let currentTime = Int(audioRecorder.currentTime)
        let minutes = currentTime / 60
        let seconds = currentTime % 60
        recordingTimeFormatted = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Normalizar el nivel de audio para mejorar la visualización de la "nube de audio"
    private func normalizeAudioLevel(_ level: Float) -> Float {
        let minLevel: Float = -80.0
        let maxLevel: Float = 0.0
        let range = maxLevel - minLevel
        let adjustedLevel = max(level, minLevel)
        return (adjustedLevel - minLevel) / range
    }
    
    func loadRecordings() {
        recordings.removeAll()
        
        let directory = getDocumentsDirectory()
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "m4a" {
                let recording = Recording(url: file)
                recordings.append(recording)
            }
            recordings.sort { $0.url.lastPathComponent > $1.url.lastPathComponent }
        } catch {
            print("No se pudieron cargar las grabaciones: \(error.localizedDescription)")
        }
    }
    
    func deleteRecording(at offsets: IndexSet) {
        offsets.forEach { index in
            let recording = recordings[index]
            do {
                try FileManager.default.removeItem(at: recording.url)
                recordings.remove(at: index)
            } catch {
                print("No se pudo eliminar la grabación: \(error.localizedDescription)")
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// Conformidad de AudioRecorder con el protocolo AVAudioPlayerDelegate
extension AudioRecorder {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentPlayingURL = nil
        currentPlaybackTime = 0.0
    }
}

struct Recording {
    let url: URL
    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
    var duration: TimeInterval {
        let asset = AVURLAsset(url: url)
        return asset.duration.seconds
    }
    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioWaveView: View {
    var audioLevel: Float
    
    var body: some View {
        GeometryReader { geometry in
            let height = CGFloat(max(10.0, geometry.size.height * CGFloat(audioLevel)))
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.red)
                .frame(height: height)
                .animation(.linear(duration: 0.1), value: height)
        }
    }
}

#Preview {
    AudioRecorderView()
}
