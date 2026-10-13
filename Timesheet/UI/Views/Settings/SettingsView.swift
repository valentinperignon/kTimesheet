//
//  SettingsView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import Sentry
import SwiftUI

enum SettingsType: String, Sendable, Identifiable, CaseIterable {
    case epicsList
    case reminders

    var id: String { rawValue }

    var label: LocalizedStringResource {
        switch self {
        case .epicsList:
            return LocalizedStringResource.titleEpics
        case .reminders:
            return LocalizedStringResource.titleReminders
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RootViewModel.self) private var rootViewModel
    
    @State private var settingsType = SettingsType.epicsList

    var body: some View {
        Group {
            #if os(iOS)
            List {
                Section {
                    NavigationLink {
                        EpicsList()
                            .navigationTitle(Text(.titleEpics))
                            .toolbar { closeToolbar }
                    } label: {
                        Label(.titleEpics, systemImage: "list.bullet")
                    }

                    NavigationLink {
                        RemindersView()
                            .navigationTitle(Text(.titleReminders))
                            .toolbar { closeToolbar }
                    } label: {
                        Label(.titleReminders, systemImage: "bell")
                    }
                }

                Section {
                    Button(role: .destructive, action: logout) {
                        Text(.buttonLogout)
                    }
                }
            }
            #else
            macSettings
            #endif
        }
        #if os(iOS)
        .navigationTitle(Text(.settingsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { closeToolbar }
        #endif
    }

    #if os(iOS)
    @ToolbarContentBuilder
    private var closeToolbar: some ToolbarContent {
        ToolbarItem(id: "closeSettings", placement: .primaryAction) {
            Button {
                dismiss()
            } label: {
                Label("button.close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
        }
    }
    #endif

    #if os(macOS)
    private var macSettings: some View {
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

            Picker(.accessibilitySettingsType, selection: $settingsType) {
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
    #endif

    private func back() {
        guard let jiraManager = UserManager.shared.jiraManager else {
            return
        }
        rootViewModel.transition(to: .content(jiraManager))
    }

    private func logout() {
        Task {
            do {
                try await UserManager.shared.removeCurrentUser()
                #if os(iOS)
                dismiss()
                #endif
                rootViewModel.transition(to: .login)
            } catch {
                SentrySDK.capture(error: error)
            }
        }
    }

    #if os(macOS)
    private func quit() {
        NSRunningApplication.current.terminate()
    }
    #endif
}

#Preview {
    SettingsView()
}
