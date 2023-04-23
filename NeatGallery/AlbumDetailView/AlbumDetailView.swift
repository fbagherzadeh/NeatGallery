//
//  AlbumDetailView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 12/4/2023.
//

import SwiftUI

struct AlbumDetailView: View {
  @StateObject var viewModel: AlbumDetailViewModel

  init(album: AlbumModel?) {
    _viewModel = StateObject(wrappedValue: AlbumDetailViewModel(album: album))
  }

  var body: some View {
    content
      .task {
        await viewModel.loadImages()
      }
      .animation(.default, value: viewModel.state)
      .navigationTitle(viewModel.title)
      .navigationViewStyle(.stack)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
          } label: {
            Image(systemName: "photo")
          }
          .disabled(viewModel.isAddMorePhotoDisabled)
        }
      }
  }
}

private extension AlbumDetailView {
  @ViewBuilder var content: some View {
    switch viewModel.state {
    case .failed:
      failedView
    case .empty:
      noImageView
    case .loading:
      loadingView
    case .loaded:
      gridView
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

  var noImageView: some View {
    VStack {
      Spacer()
      Text("Start adding your first photos!")
      Spacer()
      Spacer()
    }
  }

  var loadingView: some View {
    ProgressView()
      .progressViewStyle(.circular)
      .scaleEffect(1.5)
  }

  @ViewBuilder var gridView: some View {
    let columns = [
      GridItem(.adaptive(minimum: 120)),
      GridItem(.adaptive(minimum: 120)),
      GridItem(.adaptive(minimum: 120)),
    ]

    VStack(spacing: .zero) {
      ScrollView {
        LazyVGrid(columns: columns) {
          ForEach(viewModel.images, id: \.self) { image in
            AlbumDetailImageTileView(image: image)
              .onTapGesture {
                // TODO: open full screen image view
              }
          }
        }
        .padding(.vertical)
      }

      FooterView {
        Text("\(viewModel.images.count) items")
          .font(.caption)
          .bold()
      }
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
