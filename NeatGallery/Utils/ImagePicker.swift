//
//  ImagePicker.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 2/4/2023.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    let didFinishPickingMedia: ([PHPickerResult]) -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        let photoLibrary = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.selectionLimit = 0

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = context.coordinator
        return pickerViewController
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if !results.isEmpty {
                parent.didFinishPickingMedia(results)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
