//
//  Epic.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation
import SwiftData

@Model
final class Epic: Hashable, Identifiable {
    var id: String
    var summary: String
    var subjects: [Subject]

    init(id: String, summary: String, subjects: [Subject]) {
        self.id = id
        self.summary = summary
        self.subjects = subjects
    }

    convenience init(from issue: IssueAPI) {
        self.init(id: issue.key, summary: issue.fields.summary, subjects: [])
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Epic, rhs: Epic) -> Bool {
        return lhs.id == rhs.id
    }
}
