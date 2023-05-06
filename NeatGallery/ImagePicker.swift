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
    var config = PHPickerConfiguration()
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
    private var loadedImages: [UIImage] = []
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      parent.didFinishPickingMedia(results)
      parent.presentationMode.wrappedValue.dismiss()

//      let group = DispatchGroup()
//      print(results.count)
//
//      for result in results {
//        group.enter()
//        if result.itemProvider.canLoadObject(ofClass: UIImage.self ) {
//          result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
//            if let image = image as? UIImage {
//              self?.loadedImages.append(image)
//            }
//            group.leave()
//          }
//        } else {
//          group.leave()
//        }
//      }
//
//      group.notify(queue: .main) { [weak self] in
//        guard let self else { return }
//        self.parent.didSelectImages(self.loadedImages)
//        self.parent.presentationMode.wrappedValue.dismiss()
//      }
    }
  }
}
