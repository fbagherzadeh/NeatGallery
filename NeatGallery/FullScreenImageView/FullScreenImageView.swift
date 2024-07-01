//
//  FullScreenImageView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 25/6/2024.
//

import SwiftUI

struct FullScreenImageView: View {
    @State private var items: [ImageModel]
    @Binding private var currentIndex: Int
    private let dismissAction: () -> Void
    private let onDeleteAction: (ImageModel) -> Void

    @StateObject private var orientationManager = OrientationManager()
    @State private var size: CGSize = .zero
    @State private var hideControls: Bool = false
    @State private var itemsCount: Int
    @State var showDeleteConfirmationAlert = false

    init(
        items: [ImageModel],
        currentIndex: Binding<Int>,
        dismissAction: @escaping () -> Void,
        onDeleteAction: @escaping (ImageModel) -> Void
    ) {
        self.items = items
        self._currentIndex = currentIndex
        self.dismissAction = dismissAction
        self.onDeleteAction = onDeleteAction
        itemsCount = items.count
    }

    var body: some View {
        GeometryReader { geometryProxy in
            lightBoxWithOrientationView(
                geometryProxy: geometryProxy
            )
        }
    }

    @ViewBuilder
    private func lightBoxWithOrientationView(geometryProxy: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            LightBoxView(
                containerSize: $size,
                safeAreaBottomInsets: geometryProxy.safeAreaInsets.bottom,
                items: items,
                currentIndex: $currentIndex,
                hideControls: hideControls
            )
            .simultaneousGesture(TapGesture().onEnded { _ in
                withAnimation {
                    hideControls.toggle()
                }
            })
            // we need to keep the double tap gesture here in SwiftUI to recognise the UIKit double tap gesture added
            // for the image view.
            .simultaneousGesture(TapGesture(count: 2).onEnded { _ in
            })
            .overlay(alignment: .top, content: {
                headerView
                    .padding(.top, geometryProxy.safeAreaInsets.top)
                    .opacity(hideControls ? 0 : 1)
            })
            .overlay(alignment: .bottom, content: {
                footerView
                    .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
            })
        }
        .ignoresSafeArea()
        .onAppear {
            size = geometryProxy.size
        }
        .onChange(of: geometryProxy.size) { newSize in
            size = newSize
        }
        .customAlert(
            isPresented: $showDeleteConfirmationAlert,
            title: "Remove current photo?",
            message: "The photo will be deleted permanently.") {
                Button("Yes", role: .destructive) {
                    withAnimation {
                        didTapDelete()
                    }
                }
                Button("No", role: .cancel) {}
            }
    }


}

private extension FullScreenImageView {
    var footerView: some View {
        HStack {
            Button {
                print("Share")
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, orientationManager.isLandscape ? 30 : nil)
            .padding(.bottom, orientationManager.isLandscape ? 10 : nil)

            Button {
                showDeleteConfirmationAlert.toggle()
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.trailing, orientationManager.isLandscape ? 30 : nil)
            .padding(.bottom, orientationManager.isLandscape ? 10 : nil)
        }
        .frame(height: 41)
        .frame(maxWidth: .infinity)
        .opacity(hideControls ? 0 : 1)
    }

    var headerView: some View {
        Text("\(currentIndex + 1)/\(itemsCount)")
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay(alignment: .leading) {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.leading, 10)
                }
                .padding(.leading, orientationManager.isLandscape ? 30 : nil)
                .padding(.top, orientationManager.isLandscape ? 10 : nil)
            }
            .frame(height: 41)
    }
}

private extension FullScreenImageView {
    func didTapDelete() {
        guard items.indices.contains(currentIndex) else { return }
        let indexToBeDeleted = currentIndex
        let itemToBeDeleted = items[indexToBeDeleted]
        items.remove(at: indexToBeDeleted)
        if (currentIndex + 1) == itemsCount {
            currentIndex = 0
        }
        itemsCount -= 1

        if items.isEmpty {
            dismissAction()
        }

        onDeleteAction(itemToBeDeleted)
    }
}

struct LightBoxView: View {
    @Binding var containerSize: CGSize
    let safeAreaBottomInsets: CGFloat
    let items: [ImageModel]
    @Binding var currentIndex: Int
    @State var hideControls: Bool

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(items.indices, id: \.self) { index in
                LightBoxImageView(
                    item: items[index],
                    containerSize: $containerSize
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct LightBoxImageView: View {
    var item: ImageModel
    @Binding var containerSize: CGSize
    @State private var imageSize: CGSize = .zero

    var body: some View {
        if let uiImage = loadImage(from: item.imageUrl) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .readSize { size in imageSize = size }
                .ignoresSafeArea(edges: .all)
                .modifier(
                    ImageViewZoomPanGestureModifier(
                        containerSize: $containerSize,
                        imageSize: $imageSize
                    )
                )
        } else {
            Text("Failed to load image")
        }
    }

    func loadImage(from url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print("Error loading image from URL: \(error)")
            return nil
        }
    }
}

#Preview {
    FullScreenImageView(
        items: [],
        currentIndex: .constant(0),
        dismissAction: {},
        onDeleteAction: {_ in}
    )
}
