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
    private(set) var shouldSendNotifications: Bool {
        get { UserDefaults.standard.bool(forKey: "shouldSendNotifications") }
        set { UserDefaults.standard.set(newValue, forKey: "shouldSendNotifications") }
    }
    
    private(set) var selectedDays: [Int] {
        get {
            if UserDefaults.standard.object(forKey: "notificationsReminderSelectedDays") == nil {
                UserDefaults.standard.set(Constants.defaultDays, forKey: "notificationsReminderSelectedDays")
            }
            return UserDefaults.standard.array(forKey: "notificationsReminderSelectedDays") as? [Int] ?? Constants.defaultDays
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notificationsReminderSelectedDays")
        }
    }
    
    private(set) var selecteHour: Int {
        get {
            if UserDefaults.standard.object(forKey: "notificationsReminderSelectedHour") == nil {
                UserDefaults.standard.set(Constants.defaultHour, forKey: "notificationsReminderSelectedHour")
            }
            return UserDefaults.standard.integer(forKey: "notificationsReminderSelectedHour")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notificationsReminderSelectedHour")
        }
    }
    
    private(set) var selecteMinutes: Int {
        get {
            if UserDefaults.standard.object(forKey: "notificationsReminderSelectedMinutes") == nil {
                UserDefaults.standard.set(Constants.defaultMinutes, forKey: "notificationsReminderSelectedMinutes")
            }
            return UserDefaults.standard.integer(forKey: "notificationsReminderSelectedMinutes")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notificationsReminderSelectedMinutes")
        }
    }
    
    static let shared = NotificationsReminderManager()
    
    enum Constants: Sendable {
        static let weeksToSchedule = 3
        static let notificationIdentifier = "kTimesheet.reminder"
        
        static let defaultDays = [2, 3, 4, 5, 6]
        static let defaultHour = 16
        static let defaultMinutes = 30
    }
    
    init() {}
    
    func enableReminders(_ value: Bool) async {
        shouldSendNotifications = value
        
        if shouldSendNotifications {
            await scheduleAllReminders()
        } else {
            cancelAllReminders()
        }
    }
    
    func updateSchedule(days: [Int], hour: Int, minutes: Int) async {
        selectedDays = days
        selecteHour = hour
        selecteMinutes = minutes
        
        await scheduleAllReminders()
    }
    
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
        cancelAllReminders()
        
        for week in 0..<Constants.weeksToSchedule {
            guard !Task.isCancelled else { return }
            
            for day in selectedDays {
                guard !Task.isCancelled else { return }
                
                async let _ = scheduleReminderIfNecessary(
                    week: week,
                    day: day,
                    hour: selecteHour,
                    minutes: selecteMinutes
                )
            }
        }
    }
    
    private func scheduleReminderIfNecessary(week: Int, day: Int, hour: Int, minutes: Int) async {
        let dateComponents = generateDateComponents(week: week, day: day, hour: hour, minutes: minutes)
        guard let date = Calendar.current.date(from: dateComponents), date > Date.now else {
            return
        }
        
        guard !ActivityRepository.hasActivities(forDate: date) else {
            return
        }
        
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
        dateComponents.year = Calendar.current.component(.year, from: .now)
        dateComponents.timeZone = Calendar.current.timeZone
        
        return dateComponents
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelReminderIfNecessary(at date: Date) async {
        let identifier = getIdentifier(for: date)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func getIdentifier(for date: Date) -> String {
        let formattedDate = date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
        return "\(Constants.notificationIdentifier)_\(formattedDate)"
    }
}
