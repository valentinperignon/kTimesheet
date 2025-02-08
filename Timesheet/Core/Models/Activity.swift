//
//  Activity.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 07.02.2025.
//

import RealmSwift
import Foundation

final class Activity: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var subject: Subject?
    @Persisted var duration: TimeInterval
    @Persisted var comment: String
    @Persisted var date: Date
    @Persisted var draft: Bool

    var summary: String {
        subject?.summary ?? "Inconnu"
    }

    convenience init(subject: Subject, duration: TimeInterval, comment: String, date: Date, draft: Bool) {
        self.init()
        self.subject = subject
        self.duration = duration
        self.comment = comment
        self.date = date
        self.draft = draft
    }
}
