//
//  QRCodeGeneratorView.swift
//  SwissKnife
//
//  Created by JLSANCHEZP on 11/10/24.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorView: View {
    @State private var inputText: String = ""
    @State private var qrCodeImage: UIImage? = nil
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Introduce el texto", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    generateQRCode(from: inputText)
                }) {
                    Text("Generar QR")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                if let qrCodeImage = qrCodeImage {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                } else {
                    Text("El código QR aparecerá aquí")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Generador de QR")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        shareQRCode()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(qrCodeImage == nil) // Deshabilitar el botón si no hay QR generado
                }
            }
        }
    }
    
    private func generateQRCode(from string: String) {
        guard !string.isEmpty else {
            qrCodeImage = nil
            return
        }
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) // Aumentar el tamaño del QR
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrCodeImage = UIImage(cgImage: cgImage)
            }
        }
    }
    
    private func shareQRCode() {
        guard let qrCodeImage = qrCodeImage else { return }
        
        let activityController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
        }
    }
}

#Preview {
    QRCodeGeneratorView()
}
