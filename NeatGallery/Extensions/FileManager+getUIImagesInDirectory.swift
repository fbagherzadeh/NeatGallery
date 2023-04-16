//
//  FileManager+getUIImagesInDirectory.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import Foundation
import UIKit

extension FileManager {
  func getImageURLsInDirectory(album folderName: String) -> [URL] {
    guard let documentsDirectory = urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }

    let folderURL: URL = documentsDirectory.appendingPathComponent(folderName)

    if let folderContents = try? contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil) {
      return folderContents.filter({ $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" })
    }

    return []
  }
}
