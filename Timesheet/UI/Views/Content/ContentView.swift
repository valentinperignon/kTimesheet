//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import RealmSwift
import Sentry
import SwiftUI

enum ContentType: String, Sendable, Identifiable, CaseIterable {
    case form
    case activity

    var id: String {
        return rawValue
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
    @Environment(JiraManager.self) private var jiraManager

    @State private var contentType = ContentType.form

    var body: some View {
        VStack {
            ContentHeaderView()

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
                try await jiraManager.fetchEpics()
            } catch {
                SentrySDK.capture(error: error)
            }

            await NotificationsReminderManager.shared.requestAuthorization()
            if await NotificationsReminderManager.shared.shouldRescheduleReminders() {
                await NotificationsReminderManager.shared.scheduleAllReminders()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(RootViewModel())
        .environment(PreviewHelper.jiraManager)
}
