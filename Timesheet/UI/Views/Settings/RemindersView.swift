//
//  RemindersView.swift
//  kTimesheet
//
//  Created by Valentin on 27/03/2026.
//

import SwiftUI

enum SchedulableDay: String, Sendable, Identifiable, CaseIterable {
    var id: String {
        rawValue
    }
    
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    
    var localized: LocalizedStringKey {
        switch self {
        case .monday:
            return LocalizedStringResource.dayMonday
        case .tuesday:
            return LocalizedStringResource.dayTuesday
        case .wednesday:
            return LocalizedStringResource.dayWednesday
        case .thursday:
            return "dayThursday"
        case .friday:
            return LocalizedStringResource.dayFriday
        }
    }
}

struct RemindersView: View {
    @AppStorage("shouldSendNotifications") private var shouldSendNotifications: Bool = true
    
    @State private var selectedDays = Set<SchedulableDay>()
    
    var body: some View {
        Form {
            Section {
                Toggle(.receiveDailyReminders, isOn: $shouldSendNotifications)
                    .toggleStyle(.switch)
            }
            
            if shouldSendNotifications {
                Section {
                    ForEach(SchedulableDay.allCases) { day in
                        Toggle(
                            day.localized,
                            isOn: Binding(get: { selectedDays.contains(day) }, set: {  _,_ in toggleDay(day) })
                        )
                        .toggleStyle(.checkbox)
                    }
                } header: {
                    Text(.days)
                }
                
                Section {
                    
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private func toggleDay(_ day: SchedulableDay) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    private func addReminder() {
        
    }
}
