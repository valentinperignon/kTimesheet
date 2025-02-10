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
    @Environment(RootViewModel.self) private var rootViewModel
    @Environment(JiraManager.self) private var jiraManager

    @State private var contentType = ContentType.form

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

                Picker("Type de contenu", selection: $contentType) {
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
                try? await jiraManager.fetchEpics()
            }
        }
    }

    private func openSettings() {
        rootViewModel.transition(to: .settings)
    }
}

#Preview {
    ContentView()
        .environment(PreviewHelper.jiraManager)
}
