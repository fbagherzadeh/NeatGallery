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
  var imageURLs: [URL] = []
  var isAddMorePhotoDisabled: Bool {
    return state == .failed
  }

  private let album: AlbumModel?
  private let fileManager = FileManager.default

  var title: String {
    album?.name ?? ""
  }

  init(album: AlbumModel?) {
    self.album = album
    if album == nil {
      state = .failed
    }
  }

  func loadImageURLs() {
    state = .loading
    imageURLs = fileManager.getImageURLsInDirectory(album: title)
    state = imageURLs.isEmpty ? .empty : .loaded
  }
}
