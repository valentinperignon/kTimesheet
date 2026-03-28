//
//  NotificationsManager.swift
//  kTimesheet
//
//  Created by Valentin on 24/03/2026.
//

import Foundation
import RealmSwift
import UserNotifications
import Sentry

final class NotificationsReminderManager: Sendable {
    var shouldSendNotifications: Bool {
        get { UserDefaults.standard.bool(forKey: "shouldSendNotifications") }
        set { UserDefaults.standard.set(newValue, forKey: "shouldSendNotifications") }
    }
    
    static let shared = NotificationsReminderManager()
    
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
    
    func shouldRescheduleReminders() async -> Bool {
        guard shouldSendNotifications else {
            return false
        }
        
        let scheduledReminders = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return scheduledReminders.count <= 2
    }
    
    func scheduleAllReminders() async {
        let realm = try! await Realm()
        let notificationsSchedules = realm.objects(NotificationsSchedule.self)
        
        cancelAllReminders()
        
        for week in 0..<Constants.weeksToSchedule {
            for schedule in notificationsSchedules {
                for day in schedule.days {
                    async let _ = scheduleReminder(
                        week: week,
                        day: day,
                        hour: schedule.scheduledHour,
                        minutes: schedule.scheduledMinutes
                    )
                }
            }
        }
    }
    
    private func scheduleReminder(week: Int, day: Int, hour: Int, minutes: Int) async {
        let dateComponents = generateDateComponents(week: week, day: day, hour: hour, minutes: minutes)
        guard let date = Calendar.current.date(from: dateComponents), date > Date.now else { return }
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: .notificationReminderTitle)
        content.body = String(localized: .notificationReminderBody)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = getIdentifier(for: date)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    private func generateDateComponents(week: Int, day: Int, hour: Int, minutes: Int) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.weekday = day
        dateComponents.hour = hour
        dateComponents.minute = minutes
        dateComponents.weekOfYear = Calendar.current.component(.weekOfYear, from: .now) + week
        
        return dateComponents
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelReminderIfNecessary(at date: Date) async {
        let identifier = getIdentifier(for: date)
        
        let reminders = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let remindersToCancel = reminders
            .map(\.identifier)
            .filter { $0.hasPrefix(getIdentifier(for: date, short: true)) }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: remindersToCancel)
    }
    
    private func getIdentifier(for date: Date, short: Bool = false) -> String {
        let formattedDate = date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
        let formattedTime = date.formatted(.dateTime.hour().minute())
        
        let base = "\(Constants.notificationIdentifier)_\(formattedDate)"
        if short {
            return base
        } else {
            return "\(base)_\(formattedTime)"
        }
    }
}
