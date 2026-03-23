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
            Text("\(activities.count) \(String(localized: activities.count > 1 ? "activity.plural" : "activity.singular"))")
                .frame(maxWidth: .infinity, alignment: .leading)

            DurationView(duration: totalTime)
        }
        .font(.headline)
    }

}
