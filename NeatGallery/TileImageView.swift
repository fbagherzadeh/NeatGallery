//
//  ImageTileView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 2/4/2023.
//

import SwiftUI

struct TileImageView: View {
  let uiImage: UIImage?

  var body: some View {
    Group {
      if let uiImage {
        Image(uiImage: uiImage)
          .resizable()
      } else {
        Image("noImage")
          .resizable()
      }
    }
    .frame(width: 300, height: 200)
    .cornerRadius(20)
  }
}

struct TileImageView_Previews: PreviewProvider {
  static var previews: some View {
    TileImageView(uiImage: nil)
  }
}
