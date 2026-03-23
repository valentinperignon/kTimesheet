//
//  HelloView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import SwiftUI

struct HelloView: View {
    @Environment(RootViewModel.self) private var rootViewModel

    var body: some View {
        VStack {
            Image(systemName: "calendar.badge.clock")
                .font(.title)
                .padding(.bottom, 4)

            Text("Bienvenue")
                .font(.headline)
            Text("Chargement en cours…")
                .font(.callout)
                .padding(.bottom, 4)

            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
        }
        .padding()
        .task {
            let currentUser = try? await UserManager.shared.setCurrentUser()
            if currentUser != nil, let jiraManager = UserManager.shared.jiraManager {
                rootViewModel.transition(to: .content(jiraManager))
            } else {
                rootViewModel.transition(to: .login)
            }
        }
    }
}

#Preview {
    HelloView()
}
