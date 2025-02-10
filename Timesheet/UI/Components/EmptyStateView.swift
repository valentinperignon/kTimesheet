//
//  EmptyStateView.swift
//  kTimesheet
//
//  Created by Valentin on 10/02/2025.
//

import SwiftUI

struct EmptyStateView: View {
    private let emptyStateSymbols = ["figure.run.treadmill", "figure.fall", "figure.american.football", "figure.badminton", "figure.cooldown"]

    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: emptyStateSymbols.randomElement()!)
                .font(.largeTitle)
            Text(title)
                .font(.title2)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    EmptyStateView(title: "Hello, World")
}
