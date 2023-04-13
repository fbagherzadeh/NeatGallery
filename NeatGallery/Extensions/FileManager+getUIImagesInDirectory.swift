//
//  FileManager+getUIImagesInDirectory.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import Foundation
import UIKit

extension FileManager {
  func getUIImagesInDirectory(album folderName: String) -> [UIImage] {
    guard let documentsDirectory = urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }

    let folderURL: URL = documentsDirectory.appendingPathComponent(folderName)
    var loadedImages: [UIImage] = []

    if let folderContents = try? contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil) {
      let imageFileURLs = folderContents.filter({ $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" })
      loadedImages = imageFileURLs.compactMap { UIImage(contentsOfFile: $0.path) }
    }

    return loadedImages
  }
}
