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
    let started: Date

    init(hours: Int, minutes: Int, date: Date, comment: String) {
        timeSpent = "\(hours)h \(minutes)m"
        self.started = date
        self.comment = comment
    }
}
