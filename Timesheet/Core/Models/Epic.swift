//
//  Epic.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import RealmSwift
import Foundation

final class Epic: Object, JiraResult {
    @Persisted(primaryKey: true) var id: String
    @Persisted var summary: String
    @Persisted var subjects: List<Subject>
    @Persisted var showing: Bool

    convenience init(id: String, summary: String) {
        self.init()
        self.id = id
        self.summary = summary
        showing = true
    }

    convenience init(from issue: IssueAPI) {
        self.init(id: issue.key, summary: issue.fields.summary)
    }
}

extension Epic {
    static let unknown = Epic(id: "-1", summary: "-- Faites un choix")
}
