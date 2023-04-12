//
//  AlbumView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 10/4/2023.
//

import SwiftUI

struct AlbumsView: View {
  @State private var presentEnterNameAlert: Bool = false
  @State private var presentNameExistAlert: Bool = false
  @State private var isNavigationLinkActive = false
  @ObservedObject private var viewModel: AlbumsViewViewModel = .init()

  var body: some View {
    NavigationView {
      contentView
        .alert("", isPresented: $presentNameExistAlert, actions: {
          Button("Ok", role: .cancel) {}
        }, message: {
          Text("This album already exists")
        })
        .alertWithTextField(
          isPresented: $presentEnterNameAlert,
          message: "Enter your new album name",
          placeholder: "e.g. 21st Birthday") { didEnterNewAlbumName($0) }
        .navigationTitle("Albums")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              presentEnterNameAlert = true
            } label: {
              Image(systemName: "folder.badge.plus")
            }
          }
        }
    }
  }
}

private extension AlbumsView {
  @ViewBuilder var contentView: some View {
    if viewModel.albums.isEmpty {
      noFolderView
    } else {
      gridView
    }
  }

  var noFolderView: some View {
    VStack {
      Spacer()
      Text("Create your first album!")
      Spacer()
      Spacer()
    }
  }

  @ViewBuilder var gridView: some View {
    let columns = [
      GridItem(.adaptive(minimum: 120)),
      GridItem(.adaptive(minimum: 120))
    ]

    ScrollView {
      LazyVGrid(columns: columns, spacing: 60) {
        ForEach(viewModel.albums) { album in
          tileView(albumModel: album)
        }
      }
      .padding(.vertical)
    }
  }

  @ViewBuilder func tileView(albumModel: AlbumModel) -> some View {
    VStack {
      AlbumTileView(albumName: albumModel.name)
        .onTapGesture {
          isNavigationLinkActive = true
        }
      NavigationLink("", isActive: $isNavigationLinkActive) {
        Text("Test")
      }
    }
  }

  func didEnterNewAlbumName(_ albumName: String?) {
    guard let albumName, !albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
    if viewModel.albumExists(name: albumName) {
      presentNameExistAlert = true
    } else {
      withAnimation(.easeInOut) {
        viewModel.createNewAlbum(name: albumName)
      }
    }
  }
}

struct AlbumView_Previews: PreviewProvider {
  static var previews: some View {
    AlbumsView()
  }
}
