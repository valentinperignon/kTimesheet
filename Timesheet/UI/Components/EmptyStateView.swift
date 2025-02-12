//
//  EmptyStateView.swift
//  kTimesheet
//
//  Created by Valentin on 10/02/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: Image
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 32)

            Text(title)
                .font(.title2)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    EmptyStateView(icon: Image(systemName: "figure.run.treadmill"), title: "Hello, World")
}
