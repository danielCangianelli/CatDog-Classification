import SwiftUI
import CoreML
import Vision
import UIKit

@MainActor
class AnimalClassifierViewModel: ObservableObject {
    @Published var result: String = ""
    @Published var image: UIImage? {
        didSet {
            if let img = image {
                classify(image: img)
            }
        }
    }
    
    private let classLabels: [String: String] = [
        "cats_set": "Gato",
        "dogs_set": "Cão"
    ]
    
    func classify(image: UIImage) {
        guard let cgImage = image.cgImage else {
            result = "Imagem inválida"
            return
        }
        
        result = "Analisando..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let model = try VNCoreMLModel(for: AnimalClassifierV1().model)
                
                let request = VNCoreMLRequest(model: model) { request, _ in
                    DispatchQueue.main.async {
                        if let results = request.results as? [VNClassificationObservation],
                           let top = results.first {
                            let translatedLabel = self?.translateLabel(top.identifier) ?? "Desconhecido"
                            let confidence = String(format: "%.1f", top.confidence * 100)
                            self?.result = "É um \(translatedLabel) (\(confidence)%)"
                        } else {
                            self?.result = "Não identificado"
                        }
                    }
                }
                
                let handler = VNImageRequestHandler(cgImage: cgImage)
                try handler.perform([request])
                
            } catch {
                DispatchQueue.main.async {
                    self?.result = "Erro: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func translateLabel(_ label: String) -> String {
        return classLabels[label] ?? label
    }
}
