//
//  SearchResultAPI.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation

struct SearchResultAPI: Decodable, Sendable {
    let issues: [IssueAPI]
}
