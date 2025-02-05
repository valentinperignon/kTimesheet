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

    var body: some View {
        ZStack {
            switch rootViewModel.state {
            case .hello:
                HelloView()
            case .login:
                LoginView()
            case .content:
                Text("Content")
            }
        }
        .environment(userManager)
        .environment(rootViewModel)
    }
}

#Preview {
    RootView()
}
