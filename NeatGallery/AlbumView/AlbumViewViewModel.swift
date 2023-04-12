//
//  AlbumViewViewModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 11/4/2023.
//

import Foundation

class AlbumViewViewModel: ObservableObject {
  @Published var albums: [AlbumModel] = []

  private let fileManager = FileManager.default

  init() {
    loadAlbums()
  }

  func albumExists(name: String) -> Bool {
    albums.contains { $0.name.lowercased() == name.lowercased() }
  }

  func createNewAlbum(name: String) {
    guard let documentsDirectory: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let customFolderUrl: URL = documentsDirectory.appendingPathComponent(name, isDirectory: true)
    if !fileManager.fileExists(atPath: customFolderUrl.path) {
      do {
        try fileManager.createDirectory(at: customFolderUrl, withIntermediateDirectories: true)
        let newAlbum: AlbumModel = .init(name: name, url: customFolderUrl)
        albums.insert(newAlbum, at: 0)
      } catch {}
    }
  }

  private func loadAlbums() {
    guard let documentsDirectory: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
          let urls: [URL] = try? fileManager.getFolderURLsInDirectory(atURL: documentsDirectory, sortedBy: .created, ascending: false) else { return }
    var loadedAlbums: [AlbumModel] = []

    for url in urls {
      do {
        let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
        if resourceValues.isDirectory == true {
          loadedAlbums.append(.init(name: url.lastPathComponent, url: url))
        }
      } catch {}
    }
    albums = loadedAlbums
  }
}
