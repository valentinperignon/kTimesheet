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
    @Environment(JiraManager.self) private var jiraManager
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

    @State private var isShowingSendSuccess = false
    @State private var isShowingSaveSuccess = false
    @State private var isShowingError = false

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
                guard selectedEpic != .unknown else { return }
                try? await jiraManager.fetchSubjects(of: epicID)
            }
            .onChange(of: epicID) { _, _ in
                subjectID = Subject.unknown.id
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
                LoadingButton(
                    label: "Envoyer",
                    systemImage: "checkmark.circle",
                    isLoading: isSendingForm,
                    action: sendTimesheet
                )

                Button(action: saveDraft) {
                    Label("Enregistrer", systemImage: "plus.circle")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!isFormValid)
        }
        .onAppear {
            setStateWithLastSelection()
        }
        .simpleToast(isPresented: $isShowingError, options: .timesheet) {
            Label("Error", systemImage: "xmark.circle")
                .toast()
        }
        .simpleToast(isPresented: $isShowingSendSuccess, options: .timesheet) {
            Label("Envoyé", systemImage: "checkmark.circle")
                .toast()
        }
        .simpleToast(isPresented: $isShowingSaveSuccess, options: .timesheet) {
            Label("Enregistré", systemImage: "checkmark.circle")
                .toast()
        }
    }

    private func setStateWithLastSelection() {
        guard let lastSelectedEpic = UserDefaults.standard.lastSelectedEpic,
              let lastSelectedSubject = UserDefaults.standard.lastSelectedSubject else { return }

        epicID = lastSelectedEpic
        subjectID = lastSelectedSubject
    }

    private func sendTimesheet() {
        guard isFormValid, let selectedSubject else { return }

        Task {
            do {
                let durationHelper = DurationHelper(date: duration)
                let (hours, minutes) = durationHelper.transformToHoursAndMinutes()
                let timeInterval = durationHelper.transformToTimeInterval()

                isSendingForm = true
                try await jiraManager.sendTime(subject: selectedSubject, hours: hours, minutes: minutes, comment: comment)
                activityManager.addActivity(
                    subject: selectedSubject,
                    duration: timeInterval,
                    comment: comment,
                    date: .now,
                    draft: false
                )
                isSendingForm = false

                isShowingSendSuccess = true
            } catch {
                isShowingError = true
            }

            saveChoice()
            resetForm()
        }
    }

    private func saveDraft() {
        guard isFormValid, let selectedSubject else { return }

        let durationHelper = DurationHelper(date: duration)
        let timeInterval = durationHelper.transformToTimeInterval()

        activityManager.addActivity(subject: selectedSubject, duration: timeInterval, comment: comment, date: .now, draft: true)

        isShowingSaveSuccess = true

        saveChoice()
        resetForm()
    }

    private func saveChoice() {
        UserDefaults.standard.lastSelectedEpic = selectedEpic.id
        UserDefaults.standard.lastSelectedSubject = selectedSubject?.id
    }

    private func resetForm() {
        duration = Calendar.current.startOfDay(for: .now)
        comment = ""
    }
}

#Preview {
    FormView()
        .environment(PreviewHelper.jiraManager)
        .environment(PreviewHelper.activityManager)
}
