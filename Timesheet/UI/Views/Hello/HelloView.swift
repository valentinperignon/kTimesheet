//
//  HelloView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import SwiftUI

struct HelloView: View {
    @Environment(UserManager.self) private var userManager
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
            if (try? await userManager.setCurrentUser()) != nil {
                rootViewModel.transition(to: .content)
            } else {
                rootViewModel.transition(to: .login)
            }
        }
    }
}

#Preview {
    HelloView()
}
