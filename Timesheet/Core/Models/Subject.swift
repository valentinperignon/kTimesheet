//
//  Subject.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import RealmSwift
import Foundation

final class Subject: Object, JiraResult {
    @Persisted(primaryKey: true) var id: String
    @Persisted var summary: String

    convenience init(id: String, summary: String) {
        self.init()
        self.id = id
        self.summary = summary
    }

    convenience init(from issue: IssueAPI) {
        self.init(id: issue.key, summary: issue.fields.summary)
    }
}

extension Subject {
    static let unknown = Subject(id: "-1", summary: "-- Faites un choix")
}
