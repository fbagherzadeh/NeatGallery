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
  @StateObject private var viewModel: AlbumsViewViewModel = .init()

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
    VStack {
      switch viewModel.state {
      case .empty:
        noFolderView
      case .hasAlbum:
        gridView
      }
    }
    .animation(.easeInOut, value: viewModel.state)
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

    VStack(spacing: .zero) {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 50) {
          ForEach(viewModel.albums, id: \.id) { album in
            tileView(album)
          }
        }
        .padding(.vertical)
      }
      bottomView
    }
  }

  var bottomView: some View {
    BottomInfoView {
      Text("\(viewModel.albums.count) items")
        .font(.caption)
        .bold()
    } buttonInfoView: {
      Button {
        // TODO: show help tips
      } label: {
        Image(systemName: "info.circle")
      }
      .padding(.trailing)
    }
  }

  func tileView(_ album: AlbumModel) -> some View {
    AlbumTileView(albumName: album.name)
      .background(
        NavigationLink(
          isActive: Binding(
            get: {
              viewModel.selectedAlbum != nil
            },
            set: { isActive in
              if !isActive {
                viewModel.selectedAlbum = nil
              }
            }
          )
        ) {
          AlbumDetailView(album: viewModel.selectedAlbum)
        } label: {}
      )
      .onTapGesture {
        viewModel.selectedAlbum = album
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
