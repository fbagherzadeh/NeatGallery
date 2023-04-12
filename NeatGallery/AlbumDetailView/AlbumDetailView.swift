//
//  AlbumDetailView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 12/4/2023.
//

import SwiftUI

struct AlbumDetailView: View {
  let album: AlbumModel?

  var body: some View {
    content
      .navigationViewStyle(.stack)
      .navigationBarTitleDisplayMode(.inline)

  }
}

private extension AlbumDetailView {
  @ViewBuilder var content: some View {
    if let album {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        .navigationTitle(album.name)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
            } label: {
              Image(systemName: "photo")
            }
          }
        }
    } else {
      failedView
    }
  }

  var failedView: some View {
    VStack {
      Spacer()
      Text("Something went wrong!")
        .font(.title2)
        .padding(.bottom, 4)
      Text("Failed to load selected album")
      Spacer()
      Spacer()
    }
  }
}

struct AlbumDetailView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AlbumDetailView(
        album: .init(name: "Adelaide", url: URL(string: "https://www.google.com")!))

    }
  }
}
