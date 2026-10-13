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
        #if os(iOS)
        ActivitiesListView(date: date)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ActivitiesDatePicker(date: $date)
                    .padding()
                    .background(.bar, in: .containerRelative)
                    .padding()
            }
        #else
        VStack {
            ActivitiesDatePicker(date: $date)
            ActivitiesListView(date: date)
        }
        #endif
    }
}

#Preview {
    ActivitiesView()
        .environment(PreviewHelper.jiraManager)
}

