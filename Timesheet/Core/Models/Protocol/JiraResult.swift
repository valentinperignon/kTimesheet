//
//  JiraResult.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import Foundation

protocol JiraResult: Identifiable {
    var id: String { get }
    var summary: String { get }

    init(from issue: IssueAPI)
}
