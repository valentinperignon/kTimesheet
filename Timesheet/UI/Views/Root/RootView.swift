//
//  RootView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import SwiftUI

struct RootView: View {
    @State private var userManager = UserManager()
    @State private var rootViewModel = RootViewModel()
    @State private var activityManager = ActivityManager()

    var body: some View {
        ZStack {
            switch rootViewModel.state {
            case .hello:
                HelloView()
            case .login:
                LoginView()
            case .content(let jiraManager):
                ContentView()
                    .environment(jiraManager)
            case .settings:
                SettingsView()
            }
        }
        .environment(userManager)
        .environment(rootViewModel)
        .environment(activityManager)
    }
}

#Preview {
    RootView()
}
