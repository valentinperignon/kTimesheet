//
//  LoadingButton.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import SwiftUI

struct LoadingButton: View {
    let label: LocalizedStringResource
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Label(label, systemImage: systemImage)
                    .opacity(isLoading ? 0 : 1)

                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
                    .opacity(isLoading ? 1 : 0)
            }
        }
    }
}
