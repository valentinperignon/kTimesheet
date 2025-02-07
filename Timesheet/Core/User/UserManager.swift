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
            setupCurrentJiraManager()
        }
    }
    private(set) var jiraFetcher: JiraFetcher?
    private(set) var jiraManager: JiraManager?

    private let userStore = UserStore()

    func saveUser(username: String, token: String) async throws {
        try await userStore.saveUser(username: username, token: token)

        UserDefaults.standard.currentUsername = username
        currentUser = User(username: username, token: token)
    }

    func setCurrentUser() async throws -> User? {
        guard let currentUsername = UserDefaults.standard.currentUsername else {
            return nil
        }

        do {
            currentUser = try await userStore.fetchUser(username: currentUsername)
            return currentUser
        } catch UserStore.DomainError.keychainError(_) {
            try? await removeUser(username: currentUsername)
        }
        return nil
    }

    func removeCurrentUser() async throws {
        guard let currentUser else { return }
        try await removeUser(username: currentUser.username)
    }

    func removeUser(username: String) async throws {
        try await userStore.removeUser(username: username)

        UserDefaults.standard.currentUsername = nil
        currentUser = nil
    }
}

extension UserManager {
    private func setupCurrentJiraFetcher() {
        guard let currentUser else {
            jiraFetcher = nil
            return
        }

        jiraFetcher = JiraFetcher(user: currentUser)
    }

    private func setupCurrentJiraManager() {
        guard currentUser != nil, let jiraFetcher else {
            jiraManager = nil
            return
        }

        jiraManager = JiraManager(jiraFetcher: jiraFetcher)
    }
}
