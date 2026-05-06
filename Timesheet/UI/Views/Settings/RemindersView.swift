//
//  RemindersView.swift
//  kTimesheet
//
//  Created by Valentin on 27/03/2026.
//

import SwiftUI

struct DayPickerToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.$isOn.wrappedValue.toggle()
        } label: {
            configuration.label
                .font(.system(.body, design: .monospaced))
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(configuration.isOn ? Color.white : Color.primary)
                .padding()
                .background {
                    Circle()
                        .fill(configuration.isOn ? Color.accentColor : Color.gray.opacity(0.15))
                }
        }
        .buttonStyle(.plain)
    }
}

enum SchedulableDay: Int, Sendable, Identifiable, Equatable, CaseIterable {
    var id: Int {
        rawValue
    }
    
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    
    var localized: LocalizedStringResource {
        switch self {
        case .monday:
            return LocalizedStringResource.dayMonday
        case .tuesday:
            return LocalizedStringResource.dayTuesday
        case .wednesday:
            return LocalizedStringResource.dayWednesday
        case .thursday:
            return LocalizedStringResource.dayThursday
        case .friday:
            return LocalizedStringResource.dayFriday
        }
    }
    
    var shortLocalized: String {
        return "\(String(localized: localized).prefix(1))"
    }
}

struct RemindersView: View {
    @State private var shouldSendNotifications = NotificationsReminderManager.shared.shouldSendNotifications
    
    @State private var selectedDays = Set<SchedulableDay>()
    @State private var selectedTime = Date()
    
    @State private var isLoading = false
    @State private var shouldSaveChanges = false
    
    var body: some View {
        Form {
            Section {
                Toggle(.receiveDailyReminders, isOn: $shouldSendNotifications)
                    .toggleStyle(.switch)
                    .onChange(of: shouldSendNotifications) { _, newValue in
                        Task {
                            await NotificationsReminderManager.shared.enableReminders(newValue)
                        }
                    }
            }
            
            if shouldSendNotifications {
                Section {
                    HStack {
                        ForEach(SchedulableDay.allCases) { day in
                            Toggle(
                                day.shortLocalized,
                                isOn: Binding(get: { selectedDays.contains(day) }, set: {  _,_ in toggleDay(day) })
                            )
                            .toggleStyle(DayPickerToggleStyle())
                        }
                    }
                    .onChange(of: selectedDays) { _, _ in
                        shouldSaveChanges = needsToSaveChanges(days: true)
                    }
                    
                    DatePicker(.fieldHour, selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .onChange(of: selectedTime) { _, _ in
                            shouldSaveChanges = needsToSaveChanges(time: true)
                        }
                } footer: {
                    LoadingButton(label: .save, systemImage: "checkmark.circle", isLoading: isLoading) {
                        saveReminders()
                    }
                    .disabled(!shouldSaveChanges)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            setupValues()
        }
    }
    
    private func setupValues() {
        selectedDays = Set(NotificationsReminderManager.shared.selectedDays.compactMap { SchedulableDay(rawValue: $0) })
        
        var dateComponents = DateComponents()
        dateComponents.hour = NotificationsReminderManager.shared.selecteHour
        dateComponents.minute = NotificationsReminderManager.shared.selecteMinutes
        selectedTime = Calendar.current.date(from: dateComponents) ?? .now
    }
    
    private func needsToSaveChanges(days: Bool = false, time: Bool = false) -> Bool {
        if days {
            let selectedDays = Set(self.selectedDays.map(\.rawValue))
            let savedDays = Set(NotificationsReminderManager.shared.selectedDays)
            
            if selectedDays != savedDays {
                return true
            }
        }
        
        if time {
            let hourIsDifferent = NotificationsReminderManager.shared.selecteHour != Calendar.current.component(.hour, from: selectedTime)
            let minutesIsDifferent = NotificationsReminderManager.shared.selecteMinutes != Calendar.current.component(.minute, from: selectedTime)
            
            if hourIsDifferent || minutesIsDifferent {
                return true
            }
        }
        
        return false
    }
    
    private func toggleDay(_ day: SchedulableDay) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    private func toggleReminders() {
        
    }
    
    private func saveReminders() {
        Task {
            isLoading = true
            
            let days = selectedDays.map { $0.rawValue }
            let hour = Calendar.current.component(.hour, from: selectedTime)
            let minutes = Calendar.current.component(.minute, from: selectedTime)
            await NotificationsReminderManager.shared.updateSchedule(days: days, hour: hour, minutes: minutes)
            
            isLoading = false
            shouldSaveChanges = false
        }
    }
}
