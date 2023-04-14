//
//  BottomInfoView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 14/4/2023.
//

import SwiftUI

struct BottomInfoView<TextInfoView: View, ButtonInfoView: View>: View {
  let textInfoView: TextInfoView
  let buttonInfoView: ButtonInfoView

  init(
    @ViewBuilder textInfoView: () -> TextInfoView,
    @ViewBuilder buttonInfoView: () -> ButtonInfoView = { EmptyView() }
  ) {
    self.textInfoView = textInfoView()
    self.buttonInfoView = buttonInfoView()
  }

  var body: some View {
    Text("")
      .frame(maxWidth: .infinity)
      .padding(.top)
      .background(.secondary.opacity(0.3))
      .overlay(alignment: .trailing) {
        buttonInfoView
      }
      .overlay(alignment: .center) {
       textInfoView
      }
  }
}
