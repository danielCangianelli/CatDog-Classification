import SwiftUI
import PhotosUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = AnimalClassifierViewModel()
    
    @State private var showSourceSelector = false
    @State private var showCamera = false
    @State private var showGallery = false
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            
            Text(viewModel.result)
                .font(.title2)
                .padding()
            
            Button("Selecionar Imagem") {
                showSourceSelector = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .actionSheet(isPresented: $showSourceSelector) {
                ActionSheet(
                    title: Text("Selecione a origem"),
                    buttons: [
                        .default(Text("Tirar Foto")) {
                            handleSourceSelection(.camera)
                        },
                        .default(Text("Escolher da Galeria")) {
                            handleSourceSelection(.gallery)
                        },
                        .cancel()
                    ]
                )
            }
        }
        .sheet(isPresented: $showCamera) {
            MediaPicker(image: $viewModel.image, sourceType: .camera) {
                if let image = viewModel.image {
                    viewModel.classify(image: image)
                }
            }
        }
        .sheet(isPresented: $showGallery) {
            MediaPicker(image: $viewModel.image, sourceType: .gallery) {
                if let image = viewModel.image {
                    viewModel.classify(image: image)
                }
            }
        }
        .padding()
        .navigationTitle("Classificador de Animais")
    }
    
    private func handleSourceSelection(_ source: MediaSource) {
        switch source {
        case .camera:
            checkCameraPermission { granted in
                if granted {
                    showCamera = true
                } else {
                    viewModel.result = "Permissão da câmera necessária"
                }
            }
        case .gallery:
            showGallery = true
        }
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

#Preview {
    ContentView()
}
