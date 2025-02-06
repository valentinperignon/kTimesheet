//
//  TimesheetViewModel.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import Foundation
import RealmSwift

@Observable @MainActor
final class TimesheetViewModel {
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

        let realm = try! await Realm()
        try? realm.write {
            let epics = result.issues.map { issueAPI in
                let epic = Epic(from: issueAPI)
                keepCacheAttribute(for: epic, in: realm)
                return epic
            }

            realm.add(epics, update: .modified)
        }
    }

    func fetchIssues(of epicID: String) async throws {
        guard let jiraFetcher = userManager.jiraFetcher else { return }

        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND parentEpic=\(epicID)"]
        )
        let result: SearchResultAPI = try await jiraFetcher.performRequest(request)

        let subjects = result.issues.map { Subject(from: $0) }

        let realm = try! await Realm()
        guard let liveEpic = realm.object(ofType: Epic.self, forPrimaryKey: epicID) else { return }
        try? realm.write {
            liveEpic.subjects.removeAll()
            liveEpic.subjects.append(objectsIn: subjects)
            realm.add(liveEpic, update: .modified)
        }
    }

    func validate(issueID: String, time: Double) async throws {
        guard let jiraFetcher = userManager.jiraFetcher else { return }

        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/issue/\(issueID)/worklog",
            parameters: TimeSpent(timeSpent: time)
        )
        let _ = try await jiraFetcher.performRequest(request)
    }

    private func keepCacheAttribute(for epic: Epic, in realm: Realm) {
        guard let savedEpic = realm.object(ofType: Epic.self, forPrimaryKey: epic.id) else { return }

        for subject in savedEpic.subjects {
            epic.subjects.append(Subject(value: subject.freeze()))
        }
    }
}
