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
        epics.first { $0.id == epicID } ?? .unknown
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
        Task {
            do {
                let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: duration)

                isSendingForm = true
                try await jiraManager.sendTime(
                    issueID: subjectID,
                    hours: dateComponents.hour ?? 0,
                    minutes: dateComponents.minute ?? 0,
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
