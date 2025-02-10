//
//  ActivitiesHeader.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import RealmSwift
import SwiftUI

struct ActivitiesHeader: View {
    let activities: Results<Activity>

    private var totalTime: TimeInterval {
        return activities.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        HStack {
            Text("\(activities.count) \(activities(activities.count))")
                .frame(maxWidth: .infinity, alignment: .leading)

            DurationView(duration: totalTime)
        }
        .font(.headline)
    }

    private func activities(_ count: Int) -> String {
        return count > 1 ? "activités" : "activité"
    }
}
