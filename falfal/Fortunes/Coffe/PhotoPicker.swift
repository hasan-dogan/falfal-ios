import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
	var sourceType: UIImagePickerController.SourceType
	var onImagePicked: (UIImage?) -> Void

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.sourceType = sourceType
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(self, onImagePicked: onImagePicked)
	}

	class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let parent: ImagePicker
		var onImagePicked: (UIImage?) -> Void

		init(_ parent: ImagePicker, onImagePicked: @escaping (UIImage?) -> Void) {
			self.parent = parent
			self.onImagePicked = onImagePicked
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
			if let image = info[.originalImage] as? UIImage {
				onImagePicked(image)
			}
			picker.dismiss(animated: true)
		}

		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			onImagePicked(nil)
			picker.dismiss(animated: true)
		}
	}
}
