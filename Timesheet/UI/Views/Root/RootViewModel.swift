//
//  RootViewModel.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Observation
import SwiftUI

enum RootViewState {
    case hello
    case login
    case content(JiraManager)
    case settings
}

@Observable @MainActor
final class RootViewModel {
    var state = RootViewState.hello

    func transition(to state: RootViewState) {
        withAnimation {
            self.state = state
        }
    }
}
