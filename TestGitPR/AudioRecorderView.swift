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
    
    var body: some View {
        VStack {
            if audioRecorder.isRecording {
                Text("Grabando...")
                    .font(.headline)
                    .padding()
            } else {
                Text("Grabación detenida")
                    .font(.headline)
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
        }
        .padding()
        .onAppear {
            audioRecorder.requestPermission()
        }
    }
}

class AudioRecorder: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    
    func requestPermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if !granted {
                    print("Permission to use the microphone was denied.")
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    print("Permission to use the microphone was denied.")
                }
            }
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

#Preview {
    AudioRecorderView()
}
