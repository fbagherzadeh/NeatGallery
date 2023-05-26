//
//  AlbumDetailViewModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import UIKit
import PhotosUI

enum AlbumDetailViewStatus: Equatable {
  case empty
  case loading
  case loaded
  case failed
}

class AlbumDetailViewModel: ObservableObject {
  @Published var state: AlbumDetailViewStatus = .empty
  @Published var isAddingNewImages: Bool = false
  var images: [ImageModel] = []
  var shouldDisableAddNewPhotos: Bool {
    state == .loading || state == .failed
  }

  var footerTitle: String {
    isAddingNewImages ? "Adding new items..." : "\(images.count) \(images.count == 1 ? "item" : "items")"
  }

  private let album: AlbumModel?
  private let fileManager = FileManager.default
  private let tileWidth: CGFloat = 120

  var title: String {
    album?.name ?? ""
  }

  init(album: AlbumModel?) {
    self.album = album
    if album == nil {
      state = .failed
    }
  }

  @MainActor
  func loadImages() async {
    state = .loading
    images = await loadResizedImages()
    state = images.isEmpty ? .empty : .loaded
  }

  func addPickedImages(from pickerResults: [PHPickerResult]) {
    isAddingNewImages = true
    Task {
      do {
        let newImageModels: [ImageModel] = try await convertToUIImageWithTaskGroup(results: pickerResults)
        newImageModels.forEach { saveImageAsJPEGToDocumentDirectory(model: $0) }
        images.insert(contentsOf: newImageModels, at: 0)
        DispatchQueue.main.async { [weak self] in
          self?.isAddingNewImages = false
        }
      } catch {
        // TODO: Error handling
        print("Something went wrong")
      }
    }
  }

  private func loadResizedImages() async -> [ImageModel] {
    let urls: [URL] = fileManager.getImageURLsInDirectory(album: title)
    let scale: CGFloat = await UIScreen.main.scale
    var resizedImages: [ImageModel] = []
    for url in urls {
      if let image = UIImage(contentsOfFile: url.path)?.resizeWithScaleAspectFitMode(to: tileWidth * scale) {
        resizedImages.append(.init(resizedImage: image, imageUrl: url))
      }
    }
    return resizedImages
  }

  private func convertToUIImageWithTaskGroup(results: [PHPickerResult]) async throws -> [ImageModel] {
    guard let album else { return [] }
    return try await withThrowingTaskGroup(of: (UIImage, String)?.self) { group in
      var newImageModels: [ImageModel] = []
      newImageModels.reserveCapacity(results.count)

      results.forEach { result in
        group.addTask { [weak self] in
          try? await self?.convertToImage(result: result)
        }
      }

      for try await loadedImage in group {
        if let loadedImage = loadedImage {
          let imageModel: ImageModel = .init(
            resizedImage: loadedImage.0,
            imageUrl: album.url.appendingPathComponent(loadedImage.1)
          )
          newImageModels.append(imageModel)
        }
      }

      return newImageModels
    }
  }

  private func convertToImage(result: PHPickerResult) async throws -> (UIImage, String) {
    return try await withCheckedThrowingContinuation { continuation in
      if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
          guard let image = image as? UIImage else {
            continuation.resume(throwing: PHPickerError.loadingFailed)
            return
          }
          let imageName: String = result.itemProvider.suggestedName ?? "IMAGE_\(Date())"
          continuation.resume(returning: (image, imageName))
        }
      } else {
        continuation.resume(throwing: PHPickerError.notSupportedType)
      }
    }
  }

  func saveImageAsJPEGToDocumentDirectory(model: ImageModel) {
    guard let album,
          let data = model.resizedImage.jpegData(compressionQuality: 1.0) else {
      print("Failed to convert image to data.")
      return
    }

    let fileURL = album.url.appendingPathComponent(model.id).appendingPathExtension("jpeg")

    do {
      try data.write(to: fileURL)
      print("Image saved as JPEG successfully at: \(fileURL)")
    } catch {
      print("Failed to save image as JPEG: \(error)")
    }
  }
}
