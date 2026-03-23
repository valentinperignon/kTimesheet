//
//  SettingsView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(RootViewModel.self) private var rootViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: back) {
                    Label(.buttonBack, systemImage: "chevron.left")
                        .labelStyle(.iconOnly)
                }

                Text(.settingsTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: logout) {
                    Label(.buttonLogout, systemImage: "person.slash")
                        .labelStyle(.iconOnly)
                }

                Button(action: quit) {
                    Text(.buttonQuit)
                }
            }
            .padding(.bottom, 8)

            EpicsList()
        }
        .padding()
    }

    private func back() {
        guard let jiraManager = UserManager.shared.jiraManager else {
            return
        }
        rootViewModel.transition(to: .content(jiraManager))
    }

    private func logout() {
        Task {
            try await UserManager.shared.removeCurrentUser()
            rootViewModel.transition(to: .login)
        }
    }

    private func quit() {
        NSRunningApplication.current.terminate()
    }
}

#Preview {
    SettingsView()
}
