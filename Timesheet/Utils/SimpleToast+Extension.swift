//
//  SimpleToast+Extension.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import SimpleToast
import SwiftUI

extension SimpleToastOptions {
    static let timesheet = SimpleToastOptions(
        alignment: .bottom,
        hideAfter: TimeInterval(30),
        backdrop: nil,
        animation: .default,
        modifierType: .fade,
        dismissOnTap: true,
        disableDragGesture: true
    )
}

struct ToastModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.primary)
            .padding(16)
            .background(Material.thin, in: .rect(cornerRadius: 16))
            .padding(.bottom, 16)
            .shadow(radius: 16)
    }
}

extension View {
    func toast() -> some View {
        modifier(ToastModifier())
    }
}
