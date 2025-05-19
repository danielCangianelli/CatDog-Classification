import SwiftUI
import PhotosUI
import UIKit
import Photos

struct MediaPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: MediaSource
    var onImagePicked: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        switch sourceType {
        case .camera:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = context.coordinator
            return picker

        case .gallery:
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.selectionLimit = 1
            config.filter = .images
            config.preferredAssetRepresentationMode = .current

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.onImagePicked()
            picker.dismiss(animated: true)
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first else { return }

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.image = image
                        self?.parent.onImagePicked()
                    }
                }
            }
        }
    }
}
enum MediaSource {
    case camera
    case gallery
}

func requestLimitedPhotoAccess() {
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        if status == .limited {
            print("Acesso limitado concedido")
        } else if status == .authorized {
            print("Acesso total concedido")
        } else {
            print("Acesso negado")
        }
    }
}
