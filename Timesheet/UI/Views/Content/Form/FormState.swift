//
//  FormState.swift
//  kTimesheet
//
//  Created by Gibran Chevalley on 09.09.2026.
//

import Foundation
import Observation

/// What the user has filled in, held outside the view so that it survives switching tabs.
@Observable
final class FormState {
    var epicID = Epic.unknown.id
    var subjectID = Subject.unknown.id
    var preferredSubjectKind: SubjectKind?
    var duration = Calendar.current.startOfDay(for: .now)
    var date = Date.now
    var comment = ""

    init() {
        guard let lastSelectedEpic = UserDefaults.standard.lastSelectedEpic,
              let lastSelectedSubject = UserDefaults.standard.lastSelectedSubject else { return }

        epicID = lastSelectedEpic
        subjectID = lastSelectedSubject
    }

    /// Clears what belongs to a single entry, keeping the selection for the next one.
    func resetEntry() {
        duration = Calendar.current.startOfDay(for: .now)
        date = .now
        comment = ""
    }
}
