//
//  ActivitiesView.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import RealmSwift
import SwiftUI

struct ActivitiesView: View {
    @State private var date = Date.now

    var body: some View {
        VStack {
            ActivitiesDatePicker(date: $date)

            ActivitiesListView(date: date)
        }
    }
}

#Preview {
    ActivitiesView()
        .environment(PreviewHelper.jiraManager)
}

