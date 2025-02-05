//
//  Item.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation

enum ItemType: Sendable {
    case epic
    case topic
}

struct Item: Sendable, Hashable, Identifiable {
    let id: String
    let summary: String
    let type: ItemType

    init(id: String, summary: String, type: ItemType) {
        self.id = id
        self.summary = summary
        self.type = type
    }

    init(from issue: IssueAPI, type: ItemType) {
        self.init(id: issue.key, summary: issue.fields.summary, type: type)
    }
}
