//
//  TimesheetApp.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import Sentry
import SwiftUI

@main
struct TimesheetApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://0113a044a193d56421fbf3d1a8cbab9c@o4509079449698304.ingest.de.sentry.io/4509079459856464"
            options.sendDefaultPii = true
            options.tracesSampleRate = 1.0
            options.enableMetricKit = true
        }
    }

    var body: some Scene {
        MenuBarExtra(.kTimesheet, systemImage: "calendar.badge.clock") {
            RootView()
        }
        .menuBarExtraStyle(.window)
    }
}
