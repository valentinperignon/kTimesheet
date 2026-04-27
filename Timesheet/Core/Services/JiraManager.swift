//
//  TimesheetViewModel.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import Foundation
import Observation
import Realm
import RealmSwift

@Observable
final class JiraManager: Sendable {
    private let jiraFetcher: JiraFetcher

    enum DomainError: Error {
        case activityNotFound
        case subjectNotFound
    }

    init(jiraFetcher: JiraFetcher) {
        self.jiraFetcher = jiraFetcher
    }

    func fetchEpics() async throws {
        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/3/search/jql",
            parameters: SearchParameters(
                jql: "project=TIM AND issueType=Epic",
                fields: ["summary"]
            )
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

    func fetchSubjects(of epicID: String) async throws {
        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/3/search/jql",
            parameters: SearchParameters(
                jql: "project=TIM AND parentEpic=\(epicID)",
                fields: ["summary"]
            )
        )
        let result: SearchResultAPI = try await jiraFetcher.performRequest(request)

        let subjects = result.issues.map { Subject(from: $0) }

        let realm = getRealm()
        guard let liveEpic = realm.object(ofType: Epic.self, forPrimaryKey: epicID) else { return }
        try? realm.write {
            realm.add(subjects, update: .modified)

            liveEpic.subjects.insert(objectsIn: subjects)
            realm.add(liveEpic, update: .modified)
        }
    }

    func sendTime(for activityID: ObjectId) async throws {
        let realm = getRealm()
        guard let activity = realm.object(ofType: Activity.self, forPrimaryKey: activityID) else {
            throw DomainError.activityNotFound
        }
        
        guard let subject = activity.subject else { throw DomainError.subjectNotFound }

        let (hours, minutes) = DurationHelper(duration: activity.duration).transformToHoursAndMinutes()
        try await sendTime(ofSubject: subject.id, hours: hours, minutes: minutes, date: activity.date, comment: activity.comment)
    }

    func sendTime(ofSubject subjectID: Subject.ID, hours: Int, minutes: Int, date: Date, comment: String) async throws {
        let request = try jiraFetcher.makeRequest(
            path: "/rest/api/2/issue/\(subjectID)/worklog",
            queryItems: [
                URLQueryItem(name: "adjustEstimate", value: "new"),
                URLQueryItem(name: "newEstimate", value: "0m")
            ],
            parameters: TimesheetData(hours: hours, minutes: minutes, date: date, comment: comment)
        )
        _ = try await jiraFetcher.performRequest(request)
    }

    private func keepCacheAttribute(for epic: Epic, in realm: Realm) {
        guard let savedEpic = realm.object(ofType: Epic.self, forPrimaryKey: epic.id) else { return }

        epic.showing = savedEpic.showing
        epic.subjects.insert(objectsIn: savedEpic.subjects)
    }

    private func getRealm() -> Realm {
        let realm = try! Realm()
        return realm
    }
}
