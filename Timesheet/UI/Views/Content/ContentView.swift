//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//


import SimpleToast
import RealmSwift
import SwiftUI

struct ContentView: View {
    private static let minimumFetchDelay = TimeInterval(60 * 60 * 3) // 3 hours

    @Environment(RootViewModel.self) private var rootViewModel

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

                FormView(jiraManager: jiraManager)
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
