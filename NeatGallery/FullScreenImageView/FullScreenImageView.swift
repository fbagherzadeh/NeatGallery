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
          .frame(width: 25, height: 25)
          .padding(.leading, 10)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      Button {
        print("Delete")
      } label: {
        Image(systemName: "trash")
          .resizable()
          .frame(width: 25, height: 25)
          .padding(.trailing, 10)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
    .frame(height: 41)
    .frame(maxWidth: .infinity)
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
  }

  func headerLeadingPadding() -> CGFloat {
    return verticalSizeClass == .regular ? 0 : 40
  }

  var backgroundColorWithOpacity: Color {
    Color.black.opacity(0.6)
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
}

private struct ImageViewZoomPanGestureModifier: ViewModifier {
  @Binding var containerSize: CGSize
  @Binding var imageSize: CGSize

  public func body(content: Content) -> some View {
    ImageViewWithZoomPanGesture(
      containerSize: $containerSize,
      imageSize: $imageSize
    ) {
      content
    }
  }
}

private struct ImageViewWithZoomPanGesture<Content: View>: UIViewRepresentable {
  private let content: Content
  @Binding private var containerSize: CGSize
  @Binding private var imageSize: CGSize
  private let scrollView = UIScrollView()

  init(
    containerSize: Binding<CGSize>,
    imageSize: Binding<CGSize>,
    @ViewBuilder content: () -> Content
  ) {
    self._containerSize = containerSize
    self._imageSize = imageSize
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    configure(scrollView, context: context)

    let doubleTapGestureRecognizer = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(context.coordinator.doubleTapped(sender:))
    )
    doubleTapGestureRecognizer.numberOfTapsRequired = 2
    scrollView.addGestureRecognizer(doubleTapGestureRecognizer)

    if let hostingView = context.coordinator.hostingController.view {
      hostingView.backgroundColor = .clear
      hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      scrollView.addSubview(hostingView)
    }
    return scrollView
  }

  func updateUIView(_: UIScrollView, context: Context) {
    context.coordinator.hostingController.rootView = content
  }

  func makeCoordinator() -> Coordinator {
    let hostingController = UIHostingController(rootView: content)
    return Coordinator(
      hostingController: hostingController,
      scrollView: scrollView,
      containerSize: containerSize,
      imageSize: $imageSize
    )
  }

  private func configure(_ scrollView: UIScrollView, context: Context) {
    scrollView.delegate = context.coordinator
    scrollView.maximumZoomScale = 4
    scrollView.minimumZoomScale = 1
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bouncesZoom = false
    scrollView.bounces = false
  }
}

extension ImageViewWithZoomPanGesture {
  class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    let hostingController: UIHostingController<Content>
    private let scrollView: UIScrollView
    private let containerSize: CGSize
    @Binding private var imageSize: CGSize

    init(
      hostingController: UIHostingController<Content>,
      scrollView: UIScrollView,
      containerSize: CGSize,
      imageSize: Binding<CGSize>
    ) {
      self.hostingController = hostingController
      self.scrollView = scrollView
      self.containerSize = containerSize
      self._imageSize = imageSize
    }

    func viewForZooming(in _: UIScrollView) -> UIView? {
      return hostingController.view
    }

    @objc
    func doubleTapped(sender: UITapGestureRecognizer) {
      if scrollView.zoomScale > scrollView.minimumZoomScale {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
      } else {
        scrollView.zoom(to: zoomRect(forScale: 2.0, center: sender.location(in: sender.view)), animated: true)
      }
    }

    // These calculations are taken from FullScreenCarouselItemInsetManager.swift in Red App
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
      guard let containerView = hostingController.view,
        scrollView.zoomScale > 1 else {
        return scrollView.contentInset = .zero
      }

      let widthRatio = containerView.frame.width / imageSize.width
      let heightRatio = containerView.frame.height / imageSize.height

      let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
      var xPadding = CGFloat.zero
      var yPadding = CGFloat.zero

      let newWidth = imageSize.width * ratio

      if newWidth * scrollView.zoomScale > containerView.frame.width {
        xPadding = (newWidth - containerView.frame.width) / 2
      } else {
        xPadding = (scrollView.frame.width - scrollView.contentSize.width) / 2
      }

      let newHeight = imageSize.height * ratio

      if newHeight * scrollView.zoomScale > containerView.frame.height {
        yPadding = (newHeight - containerView.frame.height) / 2
      } else {
        yPadding = (scrollView.frame.height - scrollView.contentSize.height) / 2
      }

      scrollView.contentInset = UIEdgeInsets(top: yPadding, left: xPadding, bottom: yPadding, right: xPadding)
    }

    private func zoomRect(forScale scale: CGFloat, center: CGPoint) -> CGRect {
      guard let containerView = hostingController.view else { return .zero }
      let newCenter: CGPoint = containerView.convert(center, from: scrollView)
      let width: CGFloat = containerView.frame.width / scale
      let height: CGFloat = containerView.frame.height / scale

      return CGRect(
        x: newCenter.x - (width / scale),
        y: newCenter.y - (height / scale),
        width: width,
        height: height
      )
    }
  }
}

#Preview {
  FullScreenImageView(
    items: [],
    currentIndex: .constant(0),
    dismissAction: {}
  )
}
