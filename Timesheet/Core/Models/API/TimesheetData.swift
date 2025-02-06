//
//  TimeSpent.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation

struct TimesheetData: Codable {
    let timeSpent: String
    let comment: String

    init(hours: Int, minutes: Int, comment: String) {
        timeSpent = "\(hours)h \(minutes)m"
        self.comment = comment
    }
}
