//
//  RootView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import SwiftUI

struct RootView: View {
    @State private var rootViewModel = RootViewModel()

    var body: some View {
        ZStack {
            switch rootViewModel.state {
            case .hello:
                HelloView()
            case .login:
                #if os(iOS)
                NavigationStack {
                    LoginView()
                        .navigationTitle(Constants.appName)
                }
                #else
                LoginView()
                #endif
            case .content(let jiraManager):
                ContentView()
                    .environment(jiraManager)
            case .settings:
                SettingsView()
            }
        }
        .environment(rootViewModel)
    }
}

#Preview {
    RootView()
}
