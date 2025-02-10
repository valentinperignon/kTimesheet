//
//  DurationView.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import SwiftUI

struct DurationView: View {
    let duration: TimeInterval
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundStyle(.secondary)

            Text(Duration.seconds(duration), format: .time(pattern: .hourMinute))
        }
    }
}

#Preview {
    DurationView(duration: 30)
}
