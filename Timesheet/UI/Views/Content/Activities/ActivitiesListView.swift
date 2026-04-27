//
//  ActivitiesListView.swift
//  kTimesheet
//
//  Created by Valentin on 10/02/2025.
//

import AlertToast
import RealmSwift
import SwiftUI

struct ActivitiesListView: View {
    @Environment(JiraManager.self) private var jiraManager

    @ObservedResults(Activity.self) private var activities

    @State private var isSendingForm = false
    @State private var isShowingSuccess = false
    @State private var isShowingError = false

    private var containsDraft: Bool {
        return activities.contains { $0.draft }
    }

    init(date: Date) {
        _activities = ObservedResults(
            Activity.self,
            filter: NSPredicate(
                format: "date >= %@ AND date < %@",
                Calendar.current.startOfDay(for: date) as CVarArg,
                Calendar.current.startOfFollowingDay(date) as CVarArg
            ),
            sortDescriptor: SortDescriptor(keyPath: "subject.summary", ascending: true)
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            if activities.isEmpty {
                ActivitiesEmptyState()
            } else {
                ActivitiesHeader(activities: activities)

                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(activities) { activity in
                            ActivityView(activity: activity)
                        }
                    }
                }

                if containsDraft {
                    LoadingButton(
                        label: .buttonSend,
                        systemImage: "checkmark.circle",
                        isLoading: isSendingForm,
                        action: sendDrafts
                    )
                    .controlSize(.large)
                }
            }
        }
        .toast(isPresenting: $isShowingError) {
            AlertToast(displayMode: .hud, type: .error(.red), title: String(localized: .toastError))
        }
        .toast(isPresenting: $isShowingSuccess) {
            AlertToast(displayMode: .hud, type: .complete(.accentColor), title: String(localized: .toastSent))
        }
    }

    private func sendDrafts() {
        Task {
            isSendingForm = true

            let drafts = Array(activities.where { $0.draft })
            for draft in drafts {
                do {
                    try await jiraManager.sendTime(for: draft.id)
                    ActivityRepository.markAsSent(activity: draft)
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
    ActivitiesListView(date: .now)
}
