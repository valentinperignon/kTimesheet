//
//  WorklogAPI.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 25.10.2026.
//

import Foundation

struct WorklogsResultAPI: Decodable, Sendable {
    let worklogs: [WorklogAPI]
}

struct WorklogAPI: Decodable, Sendable {
    let id: String
    let author: AuthorAPI
    let comment: String?
    let started: Date
    let timeSpentSeconds: TimeInterval
}

struct AuthorAPI: Decodable, Sendable {
    let accountId: String
}
