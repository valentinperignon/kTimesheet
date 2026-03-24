//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//


import RealmSwift
import SwiftUI

enum ContentType: String, Identifiable, CaseIterable {
    case form
    case activity

    var id: String { rawValue }

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
        ScrollView {
            VStack {
                HStack {
                    Text(verbatim: "kTimesheet")
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
            .frame(minWidth: 325)
            .padding()
            .task {
                async let _ = try? jiraManager.fetchEpics()
                
                async let _ = NotificationsManager.shared.requestAuthorization()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
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
