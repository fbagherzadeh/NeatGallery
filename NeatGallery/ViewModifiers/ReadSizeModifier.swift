//
//  ReadSizeModifier.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 1/7/2024.
//

import SwiftUI

extension View {
  func readSize(_ completion: @escaping (CGSize) -> Void) -> some View {
    return background {
      sizeReaderView(completion)
    }
  }

  private func sizeReaderView(_ completion: @escaping (CGSize) -> Void) -> some View {
    GeometryReader { proxy in
      Color.clear
        .preference(
          key: SizePreferenceKey.self,
          value: proxy.size
        )
    }
    .onPreferenceChange(SizePreferenceKey.self) {
      completion($0)
    }
  }
}

struct SizePreferenceKey: PreferenceKey {
  public typealias Value = CGSize
  public static var defaultValue: CGSize = .zero
  public static func reduce(value: inout Value, nextValue: () -> Value) {
    print("previous value \(value). next value \(nextValue())")
    value = nextValue()
  }
}

