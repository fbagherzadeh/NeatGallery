//
//  HomeView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 2/4/2023.
//

import SwiftUI
import PhotosUI
import Combine

enum PHPickerError: Error {
  case notSupportedType
  case loadingFailed
}

class HomeViewViewModel: ObservableObject {
  @Published var images: [UIImage] = []
  @Published var pickerResults: [PHPickerResult] = []

  private var cancellable: Set<AnyCancellable> = .init()

  init() {
    $pickerResults
      .dropFirst()
      .sink { [weak self] results in
        guard let self else { return }
//        self.convertToUIImageWithDispatchGroup(results) { [weak self] in
//          self?.images = $0
//        }

        Task {
          do {
            self.images = try await self.convertToUIImageWithTaskGroup(results: results)
          } catch {
            print("SOMETHING WENT WRONG")
          }
        }
      }
      .store(in: &cancellable)

  }

//  func convertToUIImageWithDispatchGroup(_ results: [PHPickerResult], completion: @escaping ([UIImage]) -> Void) {
//    var images: [UIImage] = []
//    let dispatchGroup = DispatchGroup()
//
//    for result in results {
//      print("A")
//      dispatchGroup.enter()
//      if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
//          if let image = image as? UIImage {
//            print("B")
//            images.append(image)
//          }
//          dispatchGroup.leave()
//        }
//      } else {
//        dispatchGroup.leave()
//      }
//    }
//
//    dispatchGroup.notify(queue: DispatchQueue.main) {
//      completion(images)
//      print("C")
//    }
//  }

    func convertToUIImageWithTaskGroup(results: [PHPickerResult]) async throws -> [UIImage] {
      return try await withThrowingTaskGroup(of: UIImage?.self) { group in
        var loadedImages: [UIImage] = []
        loadedImages.reserveCapacity(results.count)

        results.forEach { result in
          group.addTask { [weak self] in
            try? await self?.convertToImage(result: result)
          }
        }

        for try await loadedImage in group {
          if let loadedImage = loadedImage {
            loadedImages.append(loadedImage)
          }
        }

        return loadedImages
      }
    }

    private func convertToImage(result: PHPickerResult) async throws -> UIImage {
      return try await withCheckedThrowingContinuation { continuation in
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
          result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            guard let image = image as? UIImage else {
              continuation.resume(throwing: PHPickerError.loadingFailed)
              return
            }
            continuation.resume(returning: image)
          }
        } else {
          continuation.resume(throwing: PHPickerError.notSupportedType)
        }
      }
    }
}

struct HomeView: View {
  @ObservedObject var viewModel: HomeViewViewModel = .init()
  @State private var showSheet = false

  var body: some View {
    VStack {
      Button("Request permission") {
        requestPhotoLibraryAccess()
      }

      Button("Select photos") {
        viewModel.images = []
        showSheet = true
      }
      .padding()

      List {
        ForEach(viewModel.images, id: \.self) { image in
          TileImageView(uiImage: image)
        }
      }
    }
    .sheet(isPresented: $showSheet) {
//      ImagePicker(pickedResults: $viewModel.pickerResults)
    }
  }


  func requestPhotoLibraryAccess() {
    PHPhotoLibrary.requestAuthorization { status in
      switch status {
      case .authorized:
        // Access granted, proceed with your photo-related tasks
        print("Access granted, proceed with your photo-related tasks")
      case .denied, .restricted:
        // Access denied or restricted, inform the user
        print("Access denied or restricted, inform the user")
      case .notDetermined:
        // The user has not yet been prompted for permission, request it now
        print("The user has not yet been prompted for permission, request it now")
      case .limited:
        print("Access limited")
      @unknown default:
        return
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
