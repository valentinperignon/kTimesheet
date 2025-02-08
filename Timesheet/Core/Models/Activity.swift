//
//  Activity.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 07.02.2025.
//

import RealmSwift
import Foundation

final class Activity: Object {
    @Persisted var subject: Subject?
    @Persisted var duration: TimeInterval
    @Persisted var date: Date
    @Persisted var draft: Bool

    convenience init(subject: Subject, duration: TimeInterval, date: Date, draft: Bool) {
        self.init()
        self.subject = subject
        self.duration = duration
        self.date = date
        self.draft = draft
    }
}
