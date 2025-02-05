//
//  TimesheetViewModel.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import Foundation

@Observable @MainActor
final class TimesheetViewModel {
    private(set) var epics: [Epic] = []
    private(set) var subjects: [Subject] = []

    private let userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    func fetchEpics() async throws {
        guard let jiraFetcher = userManager.jiraFetcher else { return }

        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND issueType=Epic"]
        )
        let result: SearchResultAPI = try await jiraFetcher.performRequest(request)

        epics = result.issues
            .map { Epic(from: $0) }
            .sorted { $0.summary < $1.summary }
    }

    func fetchIssues(of epic: Epic) async throws {
        guard let jiraFetcher = userManager.jiraFetcher else { return }

        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND parentEpic=\(epic.id)"]
        )
        let result: SearchResultAPI = try await jiraFetcher.performRequest(request)

        subjects = result.issues
            .map { Subject(from: $0) }
            .sorted { $0.summary < $1.summary }
    }

    func validate(issue: Subject, time: Int) async throws {
        guard let jiraFetcher = userManager.jiraFetcher else { return }

        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/issue/\(issue.id)/worklog",
            parameters: TimeSpent(timeSpent: time)
        )
        let _ = try await jiraFetcher.performRequest(request)
    }
}

struct TimeSpent: Codable {
    let timeSpent: Int
}
