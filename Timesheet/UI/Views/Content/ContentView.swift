//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//


import SimpleToast
import RealmSwift
import SwiftUI

enum ContentType: String, Identifiable, CaseIterable {
    case form
    case activity

    var id: String { rawValue }

    var label: String {
        switch self {
        case .form:
            return "Formulaire"
        case .activity:
            return "Mon Activité"
        }
    }
}

struct ContentView: View {
    private static let minimumFetchDelay = TimeInterval(60 * 60 * 3) // 3 hours

    @Environment(RootViewModel.self) private var rootViewModel

    @State private var contentType = ContentType.form

    let jiraManager: JiraManager

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Timesheet")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: openSettings) {
                        Label("Paramètres", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }

                Picker("Type de contenue", selection: $contentType) {
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
                    FormView(jiraManager: jiraManager)
                case .activity:
                    ActivitiesView()
                }
            }
            .padding()
            .task {
                await fetchEpics()
            }
        }
    }

    private func fetchEpics() async {
        try? await jiraManager.fetchEpics()
    }

    private func openSettings() {
        rootViewModel.transition(to: .settings)
    }
}

#Preview {
    ContentView(
        jiraManager: JiraManager(jiraFetcher: JiraFetcher(user: User(username: "a", token: "a")))
    )
}
