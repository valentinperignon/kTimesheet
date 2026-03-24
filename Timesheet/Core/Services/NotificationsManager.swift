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
            
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelReminderIfNecessary(for date: Date) {
        
    }
    
    private func identifier(for date: Date) -> String {
        return "\(Constants.notificationIdentifier)_\(date.formatted(.iso8601)))"
    }
}
