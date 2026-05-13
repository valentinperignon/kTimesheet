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
        if hours > 0 && minutes > 0 {
            timeSpent = "\(hours)h \(minutes)m"
        } else if hours > 0 {
            timeSpent = "\(hours)h"
        } else {
            timeSpent = "\(minutes)m"
        }
        self.started = date
        self.comment = comment
    }
}
