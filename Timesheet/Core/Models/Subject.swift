//
//  Subject.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation
import SwiftData

@Model
final class Subject: Hashable, Identifiable {
    var id: String
    var summary: String

    init(id: String, summary: String) {
        self.id = id
        self.summary = summary
    }

    convenience init(from issue: IssueAPI) {
        self.init(id: issue.key, summary: issue.fields.summary)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Subject, rhs: Subject) -> Bool {
        return lhs.id == rhs.id
    }
}
