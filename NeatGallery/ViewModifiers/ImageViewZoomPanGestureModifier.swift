//
//  ImageViewZoomPanGestureModifier.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 1/7/2024.
//

import SwiftUI

struct ImageViewZoomPanGestureModifier: ViewModifier {
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
