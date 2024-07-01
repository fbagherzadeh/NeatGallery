//
//  OrientationManager.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 1/7/2024.
//

import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { $0.object as? UIDevice }
            .map { $0.orientation.isLandscape }
            .assign(to: \.isLandscape, on: self)
    }
}
