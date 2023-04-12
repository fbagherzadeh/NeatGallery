//
//  AlbumTileView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 11/4/2023.
//

import SwiftUI

struct AlbumTileView: View {
  let albumName: String

  var body: some View {
    VStack(spacing: 6) {
      Image("folder")
        .resizable()
        .frame(width: 120, height: 80)

      Text(albumName)
        .font(.caption)
        .lineLimit(1)
    }
  }
}

struct AlbumTileView_Previews: PreviewProvider {
  static var previews: some View {
    AlbumTileView(albumName: "Trip to Bali")
  }
}
