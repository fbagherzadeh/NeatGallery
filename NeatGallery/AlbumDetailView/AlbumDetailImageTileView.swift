//
//  AlbumDetailImageTileView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import SwiftUI

struct AlbumDetailImageTileView: View {
  let imageURL: URL

  var body: some View {
    AsyncImage(url: imageURL) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 120, height: 67.50)
        .background(
          image
            .resizable()
            .blur(radius: 20)
        )
        .cornerRadius(8)
    } placeholder: {
      RoundedRectangle(cornerRadius: 8)
        .foregroundColor(.gray.opacity(0.2))
        .frame(width: 120, height: 67.50)
        .overlay {
          ProgressView()
        }
    }
  }
}

struct AlbumDetailImageTileView_Previews: PreviewProvider {
  static var previews: some View {
    AlbumDetailImageTileView(imageURL: URL(string: "www.google.com")!)
      .previewLayout(.sizeThatFits)
  }
}
