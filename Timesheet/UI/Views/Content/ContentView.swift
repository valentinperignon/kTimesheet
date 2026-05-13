//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import RealmSwift
import Sentry
import SwiftUI

enum ContentType: String, Identifiable, CaseIterable {
    case form
    case activity

    var id: String {
        rawValue
    }

    var label: LocalizedStringResource {
        switch self {
        case .form:
            return .tabForm
        case .activity:
            return .tabActivity
        }
    }
}

struct ContentView: View {
    @Environment(RootViewModel.self) private var rootViewModel
    @Environment(JiraManager.self) private var jiraManager

    @State private var contentType = ContentType.form

    var body: some View {
        VStack {
            HStack {
                Text(verbatim: Constants.appName)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: openSettings) {
                    Label(.settingsTitle, systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
            }

            Picker(.pickerContentType, selection: $contentType) {
                ForEach(ContentType.allCases) { contentType in
                    Text(contentType.label)
                        .tag(contentType)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.bottom, 8)

            switch contentType {
            case .form:
                FormView()
            case .activity:
                ActivitiesView()
            }
        }
        .padding()
        .task {
            do {
                async let _ = try jiraManager.fetchEpics()
            } catch {
                SentrySDK.capture(error: error)
            }

            async let _ = NotificationsReminderManager.shared.requestAuthorization()
            if await NotificationsReminderManager.shared.shouldRescheduleReminders() {
                await NotificationsReminderManager.shared.scheduleAllReminders()
            }
        }
    }

    private func openSettings() {
        rootViewModel.transition(to: .settings)
    }
}

#Preview {
    ContentView()
        .environment(RootViewModel())
        .environment(PreviewHelper.jiraManager)
}
