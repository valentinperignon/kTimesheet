//
//  ActivitiesView.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import RealmSwift
import Sentry
import SwiftUI

struct ActivitiesView: View {
    @Environment(JiraManager.self) private var jiraManager

    @Binding var date: Date

    @State private var isFetching = false

    var body: some View {
        content
            .task(id: Calendar.current.startOfDay(for: date)) {
                isFetching = true
                do {
                    try await jiraManager.fetchActivities(of: date)
                } catch {
                    guard !Task.isCancelled else { return }
                    SentrySDK.capture(error: error)
                }
                // A cancelled fetch leaves the loader to the one replacing it
                if !Task.isCancelled {
                    isFetching = false
                }
            }
    }

    private var datePicker: some View {
        HStack {
            ActivitiesDatePicker(date: $date)

            // Kept in the layout so the date picker does not move when fetching
            ProgressView()
                .controlSize(.small)
                .opacity(isFetching ? 1 : 0)
        }
    }

    @ViewBuilder
    private var content: some View {
        #if os(iOS)
        ActivitiesListView(date: date)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                datePicker
                    .padding()
                    .background(.bar, in: .containerRelative)
                    .padding()
            }
        #else
        VStack {
            datePicker
            ActivitiesListView(date: date)
        }
        #endif
    }
}

#Preview {
    @Previewable @State var date = Date.now
    ActivitiesView(date: $date)
        .environment(PreviewHelper.jiraManager)
}

