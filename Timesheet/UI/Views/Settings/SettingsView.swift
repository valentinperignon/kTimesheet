//
//  SettingsView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import SwiftUI

enum SettingsType: String, Identifiable, CaseIterable {
    case epicsList
    case reminders

    var id: String { rawValue }

    var label: LocalizedStringResource {
        switch self {
        case .epicsList:
            return "Epics"
        case .reminders:
            return "Reminders"
        }
    }
}

struct SettingsView: View {
    @Environment(RootViewModel.self) private var rootViewModel
    
    @State private var settingsType = SettingsType.epicsList

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
            .padding([.horizontal, .top])
            .padding(.bottom, 8)
            
            Picker("Setings type", selection: $settingsType) {
                ForEach(SettingsType.allCases) { settingType in
                    Text(settingType.label)
                        .tag(settingType)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal)
            .padding(.bottom, 8)

            switch settingsType {
            case .epicsList:
                EpicsList()
            case .reminders:
                RemindersView()
            }
        }
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
