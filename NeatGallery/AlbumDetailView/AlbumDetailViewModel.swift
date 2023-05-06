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
  var images: [ImageModel] = []
  var shouldDisableAddNewPhotos: Bool {
    state == .loading || state == .failed
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
    print("Convert \(pickerResults.count) results to ImageModel, add to images array and save to the file")
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
}
