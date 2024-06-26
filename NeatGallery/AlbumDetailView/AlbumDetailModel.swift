//
//  AlbumDetailModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 23/4/2023.
//

import UIKit

struct ImageModel: Identifiable, Hashable {
  let id: String
  let resizedImage: UIImage
  let imageUrl: URL
  let assetIdentifier: String?

  init(
    resizedImage: UIImage,
    imageUrl: URL,
    assetIdentifier: String? = nil
  ) {
    self.id = UUID().uuidString
    self.resizedImage = resizedImage
    self.imageUrl = imageUrl
    self.assetIdentifier = assetIdentifier
  }
}
