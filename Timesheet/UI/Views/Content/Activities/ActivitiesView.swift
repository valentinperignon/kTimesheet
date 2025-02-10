//
//  ActivitiesView.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import RealmSwift
import ToastView
import SwiftUI

struct ActivitiesView: View {
    @State private var date = Date.now

    var body: some View {
        VStack {
            DatePicker("Date à afficher", selection: $date, displayedComponents: .date)
                .datePickerStyle(.stepperField)
                .labelsHidden()

            ActivitiesListView(date: date)
        }
    }
}

#Preview {
    ActivitiesView()
        .environment(PreviewHelper.jiraManager)
        .environment(PreviewHelper.activityManager)
}

