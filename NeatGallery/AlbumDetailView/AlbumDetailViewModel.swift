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
  private let scale: CGFloat = UIScreen.main.scale

  var title: String {
    album?.name ?? ""
  }

  init(album: AlbumModel?) {
    self.album = album
    if album == nil {
      state = .failed
    }
  }

  func loadImages() {
    state = .loading
    Task {
      images = await loadResizedImages()
      await MainActor.run {
        state = images.isEmpty ? .empty : .loaded
      }
    }
  }

  func addPickedImages(from pickerResults: [PHPickerResult]) {
    isAddingNewImages = true
    Task {
      do {
        let newImageModels: [ImageModel] = try await convertToUIImageWithTaskGroup(results: pickerResults)
        newImageModels.forEach { saveImageAsJPEGToDocumentDirectory(model: $0) }
        deletePhotos(with: newImageModels.compactMap { $0.assetIdentifier })
        images.insert(contentsOf: newImageModels, at: 0)
        await MainActor.run {
          state = images.isEmpty ? .empty : .loaded
          isAddingNewImages = false
        }
      } catch {
        // TODO: Error handling
        print("Something went wrong")
      }
    }
  }

  private func loadResizedImages() async -> [ImageModel] {
    let urls: [URL] = fileManager.getImageURLsInDirectory(album: title)
    var resizedImages: [ImageModel] = []

    await withTaskGroup(of: ImageModel?.self) { group in
      for url in urls {
        group.addTask { [weak self] in
          guard let self,
                let image = UIImage(contentsOfFile: url.path)?.resizeWithScaleAspectFitMode(to: self.tileWidth * scale) else { return nil }
          return ImageModel(resizedImage: image, imageUrl: url)
        }
      }

      for await result in group {
        if let imageModel = result {
          resizedImages.append(imageModel)
        }
      }
    }

    return resizedImages
  }

  private func convertToUIImageWithTaskGroup(results: [PHPickerResult]) async throws -> [ImageModel] {
    guard let album else { return [] }
    return try await withThrowingTaskGroup(of: (image: UIImage, imageName: String, assetIdentifier: String?)?.self) { group in
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
            resizedImage: loadedImage.image,
            imageUrl: album.url.appendingPathComponent(loadedImage.imageName), 
            assetIdentifier: loadedImage.assetIdentifier
          )
          newImageModels.append(imageModel)
        }
      }

      return newImageModels
    }
  }

  private func convertToImage(result: PHPickerResult) async throws -> (image: UIImage, imageName: String, assetIdentifier: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
          guard let image = image as? UIImage else {
            continuation.resume(throwing: PHPickerError.loadingFailed)
            return
          }
          let imageName: String = result.itemProvider.suggestedName ?? "IMAGE_\(Date())"
          continuation.resume(returning: (image, imageName, result.assetIdentifier))
        }
      } else {
        continuation.resume(throwing: PHPickerError.notSupportedType)
      }
    }
  }

  private func saveImageAsJPEGToDocumentDirectory(model: ImageModel) {
    guard let album,
          let data = model.resizedImage.jpegData(compressionQuality: 1.0) else {
      print("Failed to convert image to data.")
      return
    }

    let fileURL = album.url
      .appendingPathComponent(model.id)
      .appendingPathExtension("jpeg")

    do {
      try data.write(to: fileURL)
      print("Image saved as JPEG successfully at: \(fileURL)")
    } catch {
      print("Failed to save image as JPEG: \(error)")
    }
  }

  private func deletePhotos(with localIdentifiers: [String]) {
      // Fetch the assets for the provided local identifiers
      let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)

      // Create an array to hold the assets to delete
      var assetsToDelete: [PHAsset] = []
      fetchResult.enumerateObjects { (asset, _, _) in
          assetsToDelete.append(asset)
      }

      // Perform the deletion
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
    })
  }
}
