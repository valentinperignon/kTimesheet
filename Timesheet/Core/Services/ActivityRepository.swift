//
//  ActivityManager.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 07.02.2025.
//

import Foundation
import Observation
import RealmSwift

enum ActivityRepository: Sendable {
    static func addActivity(subject: Subject, duration: TimeInterval, comment: String, date: Date, draft: Bool) {
        let realm = try! Realm()
        try? realm.write {
            guard let liveSubject = realm.object(ofType: Subject.self, forPrimaryKey: subject.id) else { return }

            let activity = Activity(subject: liveSubject, duration: duration, comment: comment, date: date, draft: draft)
            realm.add(activity)
        }
    }

    static func markAsSent(activity: Activity) {
        let realm = try! Realm()
        try? realm.write {
            guard let liveActivity = realm.object(ofType: Activity.self, forPrimaryKey: activity.id) else { return }
            liveActivity.draft = false
        }
    }

    static func deleteActivity(activity: Activity) {
        let realm = try! Realm()
        try? realm.write {
            guard let liveActivity = realm.object(ofType: Activity.self, forPrimaryKey: activity.id) else { return }
            realm.delete(liveActivity)
        }
    }

    static func hasActivities(forDate date: Date, draft: Bool) -> Bool {
        let realm = try! Realm()
        let foundActivities = realm.objects(Activity.self).filter { activity in
            return Calendar.current.isDate(activity.date, inSameDayAs: date) && activity.draft == draft
        }

        return foundActivities.count > 0
    }
}
