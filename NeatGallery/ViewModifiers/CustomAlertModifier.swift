//
//  CustomAlertModifier.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 28/6/2024.
//

import SwiftUI

extension View {
    func customAlert<Actions: View>(
      isPresented: Binding<Bool>,
      title: String,
      message: String,
      @ViewBuilder actions: @escaping () -> Actions) -> some View {
        self.modifier(
          AlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            actions: actions
          )
        )
    }
}

struct AlertModifier<Actions: View>: ViewModifier {
  let isPresented: Binding<Bool>
  let title: String
  let message: String
  let actions: () -> Actions

  func body(content: Content) -> some View {
    content
      .alert(
        title,
        isPresented: isPresented
      ) {
        actions()
      } message: {
        Text(message)
      }
  }
}
