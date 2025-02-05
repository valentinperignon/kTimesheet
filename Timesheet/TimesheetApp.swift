//
//  TimesheetApp.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import SwiftUI

@main
struct TimesheetApp: App {
    var body: some Scene {
        MenuBarExtra("Timesheet", systemImage: "calendar.badge.clock") {
            RootView()
        }
        .menuBarExtraStyle(.window)
    }
}
