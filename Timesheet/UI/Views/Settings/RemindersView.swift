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
    
    var localized: String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        }
    }
}

struct RemindersView: View {
    @AppStorage("shouldSendNotifications") private var shouldSendNotifications: Bool = true
    
    @State private var selectedDays = Set<Days>()
    
    var body: some View {
        Form {
            Section {
                Toggle("!Receive daily reminders", isOn: $shouldSendNotifications)
                    .toggleStyle(.switch)
            }
            
            if shouldSendNotifications {
                Section {
                    ForEach(Days.allCases) { day in
                        Toggle(
                            day.localized,
                            isOn: Binding(get: { selectedDays.contains(day) }, set: {  _,_ in toggleDay(day) })
                        )
                        .toggleStyle(.checkbox)
                    }
                } header: {
                    Text("Days")
                }
                
                Section {
                    
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private func toggleDay(_ day: Days) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    private func addReminder() {
        
    }
}
