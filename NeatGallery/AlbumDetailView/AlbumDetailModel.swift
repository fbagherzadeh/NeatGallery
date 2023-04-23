//
//  AlbumDetailModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 23/4/2023.
//

import UIKit

struct ImageModel: Identifiable {
  let id: String
  let resizedImage: UIImage
  let imageUrl: URL

  init(resizedImage: UIImage, imageUrl: URL) {
    self.id = UUID().uuidString
    self.resizedImage = resizedImage
    self.imageUrl = imageUrl
  }
}
