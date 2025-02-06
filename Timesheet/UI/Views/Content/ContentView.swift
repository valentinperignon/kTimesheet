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

    @Environment(UserManager.self) private var userManager
    @Environment(RootViewModel.self) private var rootViewModel

    let jiraManager: JiraManager

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Timesheet")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink(destination: SettingsView()) {
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
        let lastFetchDate = UserDefaults.standard.object(forKey: "lastFetchDate") as? Date

        if let lastFetchDate, lastFetchDate.distance(to: .now) < Self.minimumFetchDelay {
            return
        }

        do {
            try await jiraManager.fetchEpics()
            UserDefaults.standard.set(Date.now, forKey: "lastFetchDate")
        } catch {
            print("Impossible to fetch epics")
        }
    }

    private func logout() {
        Task {
            try await userManager.removeUser()
            rootViewModel.transition(to: .login)
        }
    }
}

#Preview {
    ContentView(
        jiraManager: JiraManager(jiraFetcher: JiraFetcher(user: User(username: "a", token: "a")))
    )
}
