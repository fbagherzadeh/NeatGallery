//
//  AlbumDetailImageTileView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 13/4/2023.
//

import SwiftUI

struct AlbumDetailImageTileView: View {
  let image: UIImage

  var body: some View {
    Image(uiImage: image)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 120, height: 67.50)
      .background(
        Image(uiImage: image)
          .resizable()
          .blur(radius: 20)
      )
      .cornerRadius(8)
  }
}

struct AlbumDetailImageTileView_Previews: PreviewProvider {
  static var previews: some View {
    AlbumDetailImageTileView(image: UIImage(named: "noImage")!)
      .previewLayout(.sizeThatFits)
  }
}
