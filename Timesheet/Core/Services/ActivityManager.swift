//
//  ActivityManager.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 07.02.2025.
//

import Foundation
import Observation
import RealmSwift

@Observable
final class ActivityManager {
    func fetchActivity(subject: Subject, date: Date, draft: Bool) -> Activity? {
        let realm = try! Realm()
        let foundActivities = realm.objects(Activity.self).filter { activity in
            activity.draft == draft && activity.subject == subject && Calendar.current.isDate(activity.date, inSameDayAs: date)
        }

        return foundActivities.first
    }

    func addActivity(subject: Subject, date: Date, duration: TimeInterval, draft: Bool) {
        let foundActivity = fetchActivity(subject: subject, date: date, draft: draft)

        if let foundActivity {
            editActivity(activity: foundActivity, duration: duration)
        } else {
            createNewActivity(subject: subject, date: date, duration: duration, draft: draft)
        }
    }

    private func createNewActivity(subject: Subject, date: Date, duration: TimeInterval, draft: Bool) {
        let realm = try! Realm()
        try? realm.write {
            let activity = Activity(subject: subject, duration: duration, date: date, draft: draft)
            realm.add(activity)
        }
    }

    private func editActivity(activity: Activity, duration: TimeInterval) {
        let realm = try! Realm()
        try? realm.write {
            activity.duration += duration
        }
    }
}
