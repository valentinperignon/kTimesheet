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

    /// Replaces the sent activities of the given day with the user's worklogs from Jira, leaving drafts untouched.
    func fetchActivities(of date: Date) async throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let startOfFollowingDay = Calendar.current.startOfFollowingDay(date)

        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyy-MM-dd"

        let searchRequest = try jiraFetcher.makeRequest(
            path: "/rest/api/3/search/jql",
            parameters: SearchParameters(
                jql: "worklogAuthor = currentUser() AND worklogDate = \"\(dayFormatter.string(from: date))\"",
                fields: ["summary"]
            )
        )
        let myselfRequest = try jiraFetcher.makeRequest(path: "/rest/api/3/myself", method: .get)

        async let searchResult: SearchResultAPI = jiraFetcher.performRequest(searchRequest)
        async let myself: AuthorAPI = jiraFetcher.performRequest(myselfRequest)
        let (issues, accountID) = try await (searchResult.issues, myself.accountId)

        let jiraFetcher = jiraFetcher
        let worklogsByIssue = try await withThrowingTaskGroup(of: (IssueAPI, [WorklogAPI]).self) { group in
            for issue in issues {
                let request = try jiraFetcher.makeRequest(
                    path: "/rest/api/2/issue/\(issue.key)/worklog",
                    method: .get,
                    queryItems: [
                        URLQueryItem(name: "startedAfter", value: String(Int(startOfDay.timeIntervalSince1970 * 1000))),
                        URLQueryItem(name: "startedBefore", value: String(Int(startOfFollowingDay.timeIntervalSince1970 * 1000)))
                    ]
                )
                group.addTask {
                    let result: WorklogsResultAPI = try await jiraFetcher.performRequest(request)
                    return (issue, result.worklogs.filter { $0.author.accountId == accountID })
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        let realm = getRealm()
        try realm.write {
            let sentActivities = realm.objects(Activity.self)
                .filter("draft == false AND date >= %@ AND date < %@", startOfDay, startOfFollowingDay)
            realm.delete(sentActivities)

            for (issue, worklogs) in worklogsByIssue {
                let subject = realm.create(
                    Subject.self,
                    value: ["id": issue.key, "summary": issue.fields.summary],
                    update: .modified
                )
                let activities = worklogs.map { worklog in
                    Activity(
                        subject: subject,
                        duration: worklog.timeSpentSeconds,
                        comment: worklog.comment ?? "",
                        date: worklog.started,
                        draft: false
                    )
                }
                realm.add(activities)
            }
        }
    }

    func sendTime(for activityID: ObjectId) async throws {
        let realm = getRealm()
        guard let activity = realm.object(ofType: Activity.self, forPrimaryKey: activityID) else {
            throw DomainError.activityNotFound
        }
        
        guard let subject = activity.subject else {
            throw DomainError.subjectNotFound
        }

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
        
        await NotificationsReminderManager.shared.cancelReminderIfNecessary(at: date)
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
