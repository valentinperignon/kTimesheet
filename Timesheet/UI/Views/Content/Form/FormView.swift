//
//  FormView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import RealmSwift
import SimpleToast
import SwiftUI

struct FormView: View {
    @Environment(ActivityManager.self) private var activityManager

    @ObservedResults(
        Epic.self,
        filter: NSPredicate(format: "showing == true"),
        sortDescriptor: SortDescriptor(keyPath: "summary", ascending: true)
    ) var epics

    @State private var epicID = Epic.unknown.id
    @State private var subjectID = Subject.unknown.id
    @State private var duration = Calendar.current.startOfDay(for: .now)
    @State private var comment = ""

    @State private var isSendingForm = false

    @State private var isShowingSuccess = false
    @State private var isShowingError = false

    let jiraManager: JiraManager

    private var selectedEpic: Epic {
        return epics.first { $0.id == epicID } ?? .unknown
    }

    private var selectedSubject: Subject? {
        return selectedEpic.subjects.first { $0.id == subjectID }
    }

    private var isFormValid: Bool {
        return epicID != Epic.unknown.id && subjectID != Subject.unknown.id
    }

    var body: some View {
        Form {
            Picker("Epic", selection: $epicID) {
                Text(Epic.unknown.summary)
                    .tag(Epic.unknown.id)

                ForEach(epics) { epic in
                    Text(epic.summary)
                        .tag(epic.id)
                }
            }
            .disabled(epics.isEmpty)
            .task(id: epicID) {
                guard epicID != Epic.unknown.id else { return }
                subjectID = Subject.unknown.id
                try? await jiraManager.fetchIssues(of: epicID)
            }

            Picker("Sujet", selection: $subjectID) {
                Text(Subject.unknown.summary)
                    .tag(Subject.unknown.id)

                ForEach(selectedEpic.subjects) { subject in
                    Text(subject.summary)
                        .tag(subject.id)
                }
            }
            .disabled(selectedEpic.subjects.isEmpty)

            DatePicker("Temps", selection: $duration, displayedComponents: .hourAndMinute)

            TextField("Commentaire", text: $comment)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 8)

            HStack {
                Button(action: sendTimesheet) {
                    ZStack {
                        Label("Envoyer", systemImage: "checkmark.circle")
                            .opacity(isSendingForm ? 0 : 1)

                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                            .opacity(isSendingForm ? 1 : 0)
                    }
                }

                Button(action: sendTimesheet) {
                    ZStack {
                        Label("Enregistrer", systemImage: "plus.circle")
                            .opacity(isSendingForm ? 0 : 1)
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!isFormValid)
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

    private func sendTimesheet() {
        guard isFormValid, let selectedSubject else { return }

        Task {
            do {
                let durationHelper = DurationHelper(date: duration)
                let (hours, minutes) = durationHelper.transformToHoursAndMinutes()

                isSendingForm = true
                try await jiraManager.sendTime(
                    subject: selectedSubject,
                    hours: hours,
                    minutes: minutes,
                    comment: comment
                )
                isSendingForm = false

                isShowingSuccess = true
            } catch {
                isShowingError = true
            }

            resetForm()
        }
    }

    private func saveDraft() async throws {
        guard isFormValid, let selectedSubject else { return }

        let durationHelper = DurationHelper(date: duration)
        let timeInterval = durationHelper.transformToTimeInterval()

        isSendingForm = true
        activityManager.addActivity(subject: selectedSubject, date: .now, duration: timeInterval, draft: true)
        isSendingForm = false
    }

    private func resetForm() {
        epicID = Epic.unknown.id
        subjectID = Epic.unknown.id
        duration = Calendar.current.startOfDay(for: .now)
        comment = ""
    }
}

#Preview {
    FormView(jiraManager: JiraManager(jiraFetcher: JiraFetcher(user: User(username: "a", token: "a"))))
}
