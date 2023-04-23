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

  private var backgroundColor: UIColor {
    UIColor { trait -> UIColor in
      trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    }
  }

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
    VStack {
      Spacer()

      RoundedRectangle(cornerRadius: 10)
        .background(Color(uiColor: backgroundColor))
        .foregroundColor(.secondary.opacity(0.3))
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all, edges: .bottom)
        .frame(height: 30)
        .overlay(alignment: .leading) {
          leadingButtonView
            .padding(.top)
        }
        .overlay(alignment: .trailing) {
          trailingButtonView
            .padding(.top)
        }
        .overlay(alignment: .center) {
         textView
            .padding(.top)
        }
    }
  }
}
