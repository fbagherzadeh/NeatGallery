//
//  AlbumDetailView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 12/4/2023.
//

import SwiftUI
import Photos

struct AlbumDetailView: View {
  @StateObject private var viewModel: AlbumDetailViewModel
  @State private var shouldShowDeniedPhotoAccessAlert: Bool = false
  @State private var shouldShowImagePickerSheet: Bool = false
  @State private var showFullScreenImageView: Bool = false
  @State private var currentIndex: Int = 0

  init(album: AlbumModel?) {
    _viewModel = StateObject(wrappedValue: AlbumDetailViewModel(album: album))
  }

  var body: some View {
    content
      .onAppear { viewModel.loadImages() }
      .navigationTitle(viewModel.title)
      .navigationViewStyle(.stack)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            requestPhotoLibraryAccess()
          } label: {
            Image(systemName: "photo.badge.plus")
          }
          .disabled(viewModel.shouldDisableAddNewPhotos)
        }
      }
      .customAlert(
        isPresented: $shouldShowDeniedPhotoAccessAlert,
        title: "Photo Library access denied or restricted!",
        message: "To add photos to your album, please allow Photos access in the settings."
      ) {
        Button("Cancel") {}
        Button {
          openAppSetting()
        } label: {
          Text("Settings")
        }
      }
      .customAlert(
        isPresented: $viewModel.showDeleteImportedPhotosAlert,
        title: "Remove photos?",
        message: "To free up storage, you can remove the imported photos from your device's Photos app."
      ) {
        Button("Yes", role: .destructive) {
          viewModel.confirmDeletion()
        }
        Button("No", role: .cancel) {}
      }
      .sheet(isPresented: $shouldShowImagePickerSheet) {
        ImagePicker(didFinishPickingMedia: viewModel.addPickedImages(from:))
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

    ScrollView {
      LazyVGrid(columns: columns) {
        ForEach(viewModel.images.indices, id: \.self) { index in
          let imageModel = viewModel.images[index]
          AlbumDetailImageTileView(image: imageModel.resizedImage)
            .onTapGesture {
              currentIndex = index
              showFullScreenImageView = true
            }
        }
      }
      .padding(.vertical)
    }
    .padding(.bottom, 30)
    .overlay(alignment: .bottom) {
      FooterView {
        Text(viewModel.footerTitle)
          .font(.caption)
          .bold()
      }
    }
    .overlay(viewModel.isAddingNewImages ? loadingView : nil)
    .fullScreenCover(isPresented: $showFullScreenImageView) {
      FullScreenImageView(
        items: viewModel.images,
        currentIndex: $currentIndex,
        dismissAction: { showFullScreenImageView = false }, 
        onDeleteAction: { viewModel.deleteSingleImage(image: $0) }
      )
    }
  }

  func requestPhotoLibraryAccess() {
    PHPhotoLibrary.requestAuthorization { status in
      shouldShowDeniedPhotoAccessAlert = status == .denied || status == .restricted
      shouldShowImagePickerSheet = !shouldShowDeniedPhotoAccessAlert
    }
  }

  private func openAppSetting() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
