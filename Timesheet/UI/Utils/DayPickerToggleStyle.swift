//
//  Untitled.swift
//  kTimesheet
//
//  Created by Valentin on 06/05/2026.
//

import SwiftUI

extension ToggleStyle where Self == DayPickerToggleStyle {
    static var dayPicker: DayPickerToggleStyle {
        DayPickerToggleStyle()
    }
}

struct DayPickerToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.$isOn.wrappedValue.toggle()
        } label: {
            configuration.label
                .font(.system(.body, design: .monospaced))
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(configuration.isOn ? Color.white : Color.primary)
                .padding()
                .background {
                    Circle()
                        .fill(configuration.isOn ? Color.accentColor : Color.gray.opacity(0.15))
                }
        }
        .buttonStyle(.plain)
    }
}
