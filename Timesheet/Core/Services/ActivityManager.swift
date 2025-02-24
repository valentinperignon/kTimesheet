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
    func addActivity(subject: Subject, duration: TimeInterval, comment: String, date: Date, draft: Bool) {
        let realm = try! Realm()
        try? realm.write {
            guard let liveSubject = realm.object(ofType: Subject.self, forPrimaryKey: subject.id) else { return }

            let activity = Activity(subject: liveSubject, duration: duration, comment: comment, date: date, draft: draft)
            realm.add(activity)
        }
    }

    func markAsSent(activity: Activity) {
        let realm = try! Realm()
        try? realm.write {
            guard let liveActivity = realm.object(ofType: Activity.self, forPrimaryKey: activity.id) else { return }
            liveActivity.draft = false
        }
    }

    func deleteActivity(activity: Activity) {
        let realm = try! Realm()
        try? realm.write {
            guard let liveActivity = realm.object(ofType: Activity.self, forPrimaryKey: activity.id) else { return }
            realm.delete(liveActivity)
        }
    }

    private func fetchActivity(subject: Subject, comment: String, date: Date, draft: Bool) -> Activity? {
        let realm = try! Realm()
        let foundActivities = realm.objects(Activity.self).filter { activity in
            activity.draft == draft
            && activity.subject?.id == subject.id
            && activity.comment == comment
            && Calendar.current.isDate(activity.date, inSameDayAs: date)
        }

        return foundActivities.first
    }
}
