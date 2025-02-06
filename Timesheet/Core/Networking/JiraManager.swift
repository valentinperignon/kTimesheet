//
//  TimesheetViewModel.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import Foundation
import Realm
import RealmSwift

final class JiraManager {
    private let jiraFetcher: JiraFetcher

    init(jiraFetcher: JiraFetcher) {
        self.jiraFetcher = jiraFetcher
    }

    func fetchEpics() async throws {
        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND issueType=Epic"]
        )
        let result: SearchResultAPI = try await jiraFetcher.performRequest(request)

        let realm = getRealm()
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
        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND parentEpic=\(epicID)"]
        )
        let result: SearchResultAPI = try await jiraFetcher.performRequest(request)

        let subjects = result.issues.map { Subject(from: $0) }

        let realm = getRealm()
        guard let liveEpic = realm.object(ofType: Epic.self, forPrimaryKey: epicID) else { return }
        try? realm.write {
            liveEpic.subjects.removeAll()
            liveEpic.subjects.append(objectsIn: subjects)
            realm.add(liveEpic, update: .modified)
        }
    }

    func sendTime(issueID: String, hours: Int, minutes: Int, comment: String) async throws {
        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/issue/\(issueID)/worklog",
            parameters: TimesheetData(hours: hours, minutes: minutes, comment: comment)
        )
        let _ = try await jiraFetcher.performRequest(request)
    }

    private func keepCacheAttribute(for epic: Epic, in realm: Realm) {
        guard let savedEpic = realm.object(ofType: Epic.self, forPrimaryKey: epic.id) else { return }

        for subject in savedEpic.subjects {
            epic.subjects.append(Subject(value: subject.freeze()))
        }
    }

    private func getRealm() -> Realm {
        let realm = try! Realm()
        return realm
    }
}
