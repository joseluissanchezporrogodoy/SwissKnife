//
//  ContentView.swift
//  TestGitPR
//
//  Created by JLSANCHEZP on 3/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalculatorView()
                .tabItem {
                    Label("Calculadora", systemImage: "plus.slash.minus")
                }
            
            NotesView()
                .tabItem {
                    Label("Notas", systemImage: "note.text")
                }
            
            AudioRecorderView()
                .tabItem {
                    Label("Grabadora", systemImage: "mic")
                }
            
            QRCodeGeneratorView()
                .tabItem {
                    Label("Generador de QR", systemImage: "qrcode")
                }
        }
    }
}

#Preview {
    ContentView()
}
