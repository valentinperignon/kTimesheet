//
//  NotificationsManager.swift
//  kTimesheet
//
//  Created by Valentin on 24/03/2026.
//

import Foundation
import UserNotifications
import Sentry

final class NotificationsManager: Sendable {
    var shouldSendNotifications: Bool {
        get { UserDefaults.standard.bool(forKey: "shouldSendNotifications") }
        set { UserDefaults.standard.set(newValue, forKey: "shouldSendNotifications") }
    }
    
    var scheduledDays: [Int] {
        get { UserDefaults.standard.array(forKey: "scheduledDaysForNotifications") as? [Int] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "scheduledDaysForNotifications") }
    }
    
    var scheduledHour: Int {
        get { UserDefaults.standard.integer(forKey: "scheduledHourForNotifications") }
        set { UserDefaults.standard.set(newValue, forKey: "scheduledHourForNotifications") }
    }
    
    var scheduledMinutes: Int {
        get { UserDefaults.standard.integer(forKey: "scheduledMinutesForNotifications") }
        set { UserDefaults.standard.set(newValue, forKey: "scheduledMinutesForNotifications") }
    }
    
    static let shared = NotificationsManager()
    
    enum Constants: Sendable {
        static let weeksToSchedule = 3
        static let notificationIdentifier = "kTimesheet.reminder"
    }
    
    init() {}
    
    func requestAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    func scheduleReminders() {
        cancelAllReminders()
        
        for week in 0..<Constants.weeksToSchedule {
            for day in scheduledDays {
                scheduleReminder(week: week, day: day, hour: scheduledHour, minutes: scheduledMinutes)
            }
        }
    }
    
    private func scheduleReminder(week: Int, day: Int, hour: Int, minutes: Int) {
        var dateComponents = DateComponents()
        dateComponents.weekday = day
        dateComponents.hour = hour
        dateComponents.minute = minutes
        dateComponents.weekOfYear = Calendar.current.component(.weekOfYear, from: .now) + week
        
        guard let date = Calendar.current.date(from: dateComponents), date > Date.now else { return }
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: .notificationReminderTitle)
        content.body = String(localized: .notificationReminderBody)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = identifier(for: date)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelReminderIfNecessary(at date: Date) {
        let identifier = identifier(for: date)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func identifier(for date: Date) -> String {
        let formattedDate = date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
        return "\(Constants.notificationIdentifier)_\(formattedDate))"
    }
}
