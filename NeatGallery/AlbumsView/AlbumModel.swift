//
//  AlbumModel.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 11/4/2023.
//

import Foundation

struct AlbumModel: Identifiable, Hashable {
  let id: String = UUID().uuidString
  let name: String
  let url: URL
}
