//
//  AccountManager.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation
import Observation

@Observable @MainActor
final class UserManager {
    private(set) var currentUser: User? {
        didSet {
            setupCurrentJiraFetcher()
        }
    }
    private(set) var jiraFetcher: JiraFetcher?

    private let userStore = UserStore()

    func saveUser(username: String, token: String) async throws {
        try await userStore.saveUser(username: username, token: token)
        currentUser = User(username: username, token: token)
    }

    func setCurrentUser() async throws -> User? {
        currentUser = try await userStore.fetchUser()
        return currentUser
    }

    func removeUser() async throws {
        currentUser = nil
        try await userStore.removeUser()
    }

    private func setupCurrentJiraFetcher() {
        guard let currentUser else {
            jiraFetcher = nil
            return
        }

        jiraFetcher = JiraFetcher(user: currentUser)
    }
}
