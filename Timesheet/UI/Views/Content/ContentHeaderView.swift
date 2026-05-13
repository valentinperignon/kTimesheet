//
//  ContentHeaderView.swift
//  kTimesheet
//
//  Created by Valentin on 13/05/2026.
//

import SwiftUI

struct ContentHeaderView: View {
    @Environment(RootViewModel.self) private var rootViewModel
    
    var body: some View {
        HStack {
            Text(verbatim: Constants.appName)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: openSettings) {
                Label(.settingsTitle, systemImage: "gear")
                    .labelStyle(.iconOnly)
            }
        }
    }
    
    private func openSettings() {
        rootViewModel.transition(to: .settings)
    }
}

#Preview {
    ContentHeaderView()
}
