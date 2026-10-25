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
            return .kTimesheet
        case .activity:
            return .tabActivity
        }
    }
}

struct ContentView: View {
    @Environment(JiraManager.self) private var jiraManager

    @State private var contentType = ContentType.form
    @State private var isShowingSettings = false
    @State private var formState = FormState()

    var body: some View {
        @Bindable var formState = formState

        Group {
            #if os(iOS)
            TabView(selection: $contentType) {
                Tab(value: ContentType.form) {
                    NavigationStack {
                        FormView(state: formState)
                            .navigationTitle(Text(ContentType.form.label))
                            .toolbar { settingsToolbar }
                    }
                } label: {
                    Label(ContentType.form.label, systemImage: "square.and.pencil")
                }

                Tab(value: ContentType.activity) {
                    NavigationStack {
                        ActivitiesView(date: $formState.date)
                            .navigationTitle(Text(ContentType.activity.label))
                            .toolbarTitleDisplayMode(.inline)
                            .toolbar { settingsToolbar }
                    }
                } label: {
                    Label(ContentType.activity.label, systemImage: "clock")
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
            #else
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
                    FormView(state: formState)
                case .activity:
                    ActivitiesView(date: $formState.date)
                }
            }
            .padding()
            #endif
        }
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

    #if os(iOS)
    @ToolbarContentBuilder
    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isShowingSettings = true
            } label: {
                Label(.settingsTitle, systemImage: "gear")
            }
        }
    }
    #endif
}

#Preview {
    ContentView()
        .environment(RootViewModel())
        .environment(PreviewHelper.jiraManager)
}
