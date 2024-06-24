//
//  FullScreenImageView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 25/6/2024.
//

import SwiftUI

struct FullScreenImageView: View {
  private var items: [ImageModel]
  @Binding private var currentIndex: Int
  private let dismissAction: () -> Void

  @Environment(\.verticalSizeClass) var verticalSizeClass
  @State private var size: CGSize = .zero
  @State private var hideControls: Bool = false

  init(
    items: [ImageModel],
    currentIndex: Binding<Int>,
    dismissAction: @escaping () -> Void
  ) {
    self.items = items
    self._currentIndex = currentIndex
    self.dismissAction = dismissAction
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
      Rectangle()
        .fill(Color.orange)
        .frame(maxWidth: .infinity)
        .frame(height: 300)
      // TODO: LightBoxView
//      LightBoxView(
//        containerSize: $size,
//        safeAreaBottomInsets: geometryProxy.safeAreaInsets.bottom,
//        items: items,
//        currentIndex: $currentIndex,
//        hideControls: hideControls
//      )

      // we need to keep the double tap gesture here in SwiftUI to recognise the UIKit double tap gesture added
      // for the image view.
      .simultaneousGesture(TapGesture(count: 2).onEnded { _ in
      })
      .overlay(alignment: .top, content: {
        headerView
          .padding(.top, geometryProxy.safeAreaInsets.top)
          .opacity(hideControls ? 0 : 1)
      })

      footerView
    }
    .ignoresSafeArea()
    .onAppear {
      size = geometryProxy.size
    }.onChange(of: geometryProxy.size) { newSize in
      size = newSize
    }
  }

  private var footerView: some View {
    HStack {
      Button {
        print("Share")
      } label: {
        Image(systemName: "square.and.arrow.up")
          .resizable()
          .frame(width: 20, height: 20)
          .padding(.leading, 10)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      Button {
        print("Delete")
      } label: {
        Image(systemName: "trash")
          .resizable()
          .frame(width: 20, height: 20)
          .padding(.trailing, 10)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
    .frame(height: 41)
    .frame(maxWidth: .infinity)
    .background(backgroundColorWithOpacity)
    .opacity(hideControls ? 0 : 1)
  }

  private var headerView: some View {
    Text("\(currentIndex + 1)/\(items.count)")
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
      }
      .frame(height: 41)
      .background(backgroundColorWithOpacity)
  }

  func headerLeadingPadding() -> CGFloat {
    return verticalSizeClass == .regular ? 0 : 40
  }

  var backgroundColorWithOpacity: Color {
    Color.black.opacity(0.6)
  }
}

#Preview {
  FullScreenImageView(
    items: [],
    currentIndex: .constant(0),
    dismissAction: {}
  )
}
