//
//  BottomInfoView.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 14/4/2023.
//

import SwiftUI

struct FooterView<TextView: View, TrailingButtonInfoView: View, LeadingButtonInfoView: View>: View {
  let textView: TextView
  let trailingButtonView: TrailingButtonInfoView
  let leadingButtonView: LeadingButtonInfoView

  init(
    @ViewBuilder textView: () -> TextView,
    @ViewBuilder leadingButtonInfoView: () -> LeadingButtonInfoView = { EmptyView() },
    @ViewBuilder trailingButtonInfoView: () -> TrailingButtonInfoView = { EmptyView() }
  ) {
    self.textView = textView()
    self.leadingButtonView = leadingButtonInfoView()
    self.trailingButtonView = trailingButtonInfoView()
  }

  var body: some View {
    Text("")
      .frame(maxWidth: .infinity)
      .padding(.top)
      .background(.secondary.opacity(0.3))
      .overlay(alignment: .leading) {
        leadingButtonView
      }
      .overlay(alignment: .trailing) {
        trailingButtonView
      }
      .overlay(alignment: .center) {
       textView
      }
  }
}
