//
//  SettingsView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(RootViewModel.self) private var rootViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: back) {
                    Label("Retour", systemImage: "chevron.left")
                        .labelStyle(.iconOnly)
                }

                Text("Paramètres")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: logout) {
                    Label("Se déconnecter", systemImage: "person.slash")
                        .labelStyle(.iconOnly)
                }

                Button(action: quit) {
                    Text("Quitter")
                }
            }
            .padding(.bottom, 8)

            EpicsList()
        }
        .padding()
    }

    private func back() {
        guard let jiraManager = userManager.jiraManager else { return }
        rootViewModel.transition(to: .content(jiraManager))
    }

    private func logout() {
        Task {
            try await userManager.removeCurrentUser()
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
