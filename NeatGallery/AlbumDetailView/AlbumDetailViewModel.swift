//
//  AlbumDetailViewModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import UIKit

enum AlbumDetailViewStatus: Equatable {
  case empty
  case loading
  case loaded
  case failed
}

class AlbumDetailViewModel: ObservableObject {
  @Published var state: AlbumDetailViewStatus = .empty
  var images: [ImageModel] = []

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
