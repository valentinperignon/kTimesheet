//
//  ActivitiesView.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import RealmSwift
import SimpleToast
import SwiftUI

struct ActivitiesView: View {
    @Environment(JiraManager.self) private var jiraManager
    @Environment(ActivityManager.self) private var activityManager

    @ObservedResults(
        Activity.self,
        filter: NSPredicate(format: "date >= %@", Calendar.current.startOfDay(for: .now) as CVarArg),
        sortDescriptor: SortDescriptor(keyPath: "subject.summary", ascending: true)
    ) private var activities

    @State private var isSendingForm = false
    @State private var isShowingSuccess = false
    @State private var isShowingError = false

    private var containsDraft: Bool {
        return activities.contains { $0.draft }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    ActivitiesHeader(activities: activities)

                    ForEach(activities) { activity in
                        ActivityView(activity: activity)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if containsDraft {
                LoadingButton(
                    label: "Envoyer",
                    systemImage: "checkmark.circle",
                    isLoading: isSendingForm,
                    action: sendDrafts
                )
                .controlSize(.large)
            }
        }
        .simpleToast(isPresented: $isShowingError, options: .timesheet) {
            Label("Error", systemImage: "xmark.circle")
                .toast()
        }
        .simpleToast(isPresented: $isShowingSuccess, options: .timesheet) {
            Label("Envoyé", systemImage: "checkmark.circle")
                .toast()
        }
    }

    private func sendDrafts() {
        Task {
            isSendingForm = true

            let drafts = Array(activities.where { $0.draft })
            for draft in drafts {
                do {
                    guard let subject = draft.subject else { continue }

                    let (hours, minutes) = DurationHelper(duration: draft.duration).transformToHoursAndMinutes()
                    try await jiraManager.sendTime(subject: subject, hours: hours, minutes: minutes, comment: draft.comment)
                    activityManager.markAsSent(activity: draft)
                } catch {
                    isShowingError = true
                    break
                }
            }

            isSendingForm = false
        }
    }
}

#Preview {
    ActivitiesView()
        .environment(PreviewHelper.jiraManager)
        .environment(PreviewHelper.activityManager)
}

