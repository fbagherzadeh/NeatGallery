//
//  AlertWithTextFieldModifier.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 10/4/2023.
//

import SwiftUI

extension View {
    func alertWithTextField(
        isPresented: Binding<Bool>,
        title: String = "",
        message: String? = nil,
        text: String = "",
        placeholder: String = "",
        action: @escaping (String?) -> Void
    ) -> some View {
      self
        .modifier(
          AlertWithTextFieldModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            text: text,
            placeholder: placeholder,
            action: action)
        )
    }
}

struct AlertWithTextFieldModifier: ViewModifier {
  @State private var alertController: UIAlertController?
  @Binding var isPresented: Bool

  let title: String
  let message: String?
  let text: String?
  let placeholder: String
  let action: (String?) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: isPresented) { isPresented in
      if isPresented, alertController == nil {
        let newAlertController = makeAlertController()
        self.alertController = newAlertController
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          return
        }
        scene.windows.first?.rootViewController?.present(newAlertController, animated: true)
      } else if !isPresented, let alertController = alertController {
        alertController.dismiss(animated: true)
        self.alertController = nil
      }
    }
  }

  private func makeAlertController() -> UIAlertController {
    let alertController: UIAlertController = .init(title: title, message: message, preferredStyle: .alert)

    alertController.addTextField {
      $0.placeholder = placeholder
      $0.autocapitalizationType = .sentences
      $0.text = text
    }

    let cancelAction: UIAlertAction = .init(title: "Cancel", style: .cancel) { _ in
      action(nil)
      shutdown()
    }
    alertController.addAction(cancelAction)

    let saveAction: UIAlertAction = .init(title: "Save", style: .default) {
      _ in
        action(alertController.textFields?.first?.text)
        shutdown()
    }
    alertController.addAction(saveAction)

    alertController.preferredAction = saveAction
    return alertController
  }

  private func shutdown() {
    isPresented = false
    alertController = nil
  }
}
