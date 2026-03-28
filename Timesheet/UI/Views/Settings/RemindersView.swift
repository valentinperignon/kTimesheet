//
//  RemindersView.swift
//  kTimesheet
//
//  Created by Valentin on 27/03/2026.
//

import SwiftUI

enum Days: String, Sendable, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
}

struct RemindersView: View {
    @AppStorage("shouldSendNotifications") private var shouldSendNotifications: Bool = true
    
    @State private var selectedDays = Set<Days>()
    
    var body: some View {
        Form {
            Toggle("!Receive daily reminders", isOn: $shouldSendNotifications)
                .toggleStyle(.switch)
            
            if shouldSendNotifications {
                HStack {
                    
                }
            }
        }
    }
    
    private func addReminder() {
        
    }
}
