//
//  ActivitiesEmptyState.swift
//  kTimesheet
//
//  Created by Valentin on 12/02/2025.
//

import SwiftUI

struct ActivitiesEmptyState: View {
    private let images = [
        "figure.run.treadmill",
        "figure.fall",
        "figure.american.football",
        "figure.badminton",
        "figure.cooldown",
        "figure.bowling",
        "figure.climbing",
        "figure.fishing",
        "figure.flexibility",
        "figure.strengthtraining.traditional"
    ]

    var body: some View {
        EmptyStateView(
            icon: Image(images.randomElement()!),
            title: .activitiesEmptyTitle
        )
    }
}

#Preview {
    ActivitiesEmptyState()
}
