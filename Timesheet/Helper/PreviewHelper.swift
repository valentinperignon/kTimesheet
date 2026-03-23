//
//  PreviewHelper.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 09.02.2025.
//

import Foundation

enum PreviewHelper {
    static let jiraManager = JiraManager(jiraFetcher: JiraFetcher(user: User(username: "a", token: "a")))

    static let activityManager = ActivityManager.shared
}
