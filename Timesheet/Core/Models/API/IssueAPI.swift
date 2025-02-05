//
//  IssueAPI.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation

struct IssueAPI: Decodable, Sendable {
    let key: String
    let fields: FieldsAPI
}
