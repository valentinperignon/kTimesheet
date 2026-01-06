//
//  SearchParameters.swift
//  kTimesheet
//
//  Created by Valentin on 06/01/2026.
//

import Foundation

struct SearchParameters: Codable, Sendable {
    let jql: String
    let fields: [String]
}
