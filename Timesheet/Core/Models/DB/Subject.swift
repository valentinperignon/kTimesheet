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
    nonisolated(unsafe) static let unknown = Subject(id: "-1", summary: String(localized: .selectAnOptionPlaceholder))
}

/// Nature of the work a subject stands for, which most epics declare a subject for.
enum SubjectKind: String, CaseIterable {
    case increment
    case maintenance
}

extension Subject {
    /// Matches loosely, as summaries spell the kind in either language and casing.
    var kind: SubjectKind? {
        return SubjectKind.allCases.first {
            summary.range(of: $0.rawValue, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
}
