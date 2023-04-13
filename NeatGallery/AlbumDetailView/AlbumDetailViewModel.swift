//
//  AlbumDetailViewModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import UIKit

enum AlbumDetailViewStatus {
  case empty, loading, loaded, failed
}

class AlbumDetailViewModel: ObservableObject {
  @Published var status: AlbumDetailViewStatus = .empty
  var loadedImages: [UIImage] = []

  private let album: AlbumModel?
  private let fileManager = FileManager.default

  var title: String {
    album?.name ?? ""
  }

  init(album: AlbumModel?) {
    self.album = album
    if album == nil {
      status = .failed
    }
  }

  func loadImages() {
    status = .loading
    loadedImages = fileManager.getUIImagesInDirectory(album: title)
    status = loadedImages.isEmpty ? .empty : .loaded
  }
}
