//
//  FormView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import AlertToast
import RealmSwift
import Sentry
import SwiftUI

struct FormView: View {
    @Environment(JiraManager.self) private var jiraManager

    @ObservedResults(
        Epic.self,
        filter: NSPredicate(format: "showing == true"),
        sortDescriptor: SortDescriptor(keyPath: "summary", ascending: true)
    ) var epics

    @Bindable var state: FormState

    @State private var isSendingForm = false

    @State private var isShowingSendSuccess = false
    @State private var isShowingSaveSuccess = false
    @State private var isShowingError = false

    private var selectedEpic: Epic {
        return epics.first { $0.id == state.epicID } ?? .unknown
    }

    private var selectedSubject: Subject? {
        return selectedEpic.subjects.first { $0.id == state.subjectID }
    }

    private var isFormValid: Bool {
        return state.epicID != Epic.unknown.id && state.subjectID != Subject.unknown.id
    }

    var body: some View {
        Form {
            Picker(.fieldEpic, selection: $state.epicID) {
                Text(Epic.unknown.summary)
                    .tag(Epic.unknown.id)

                ForEach(epics) { epic in
                    Text(epic.summary)
                        .tag(epic.id)
                }
            }
            .disabled(epics.isEmpty)
            .task(id: state.epicID) {
                guard selectedEpic != .unknown else { return }
                try? await jiraManager.fetchSubjects(of: state.epicID)
                selectPreferredSubject()
            }
            .onChange(of: state.epicID) { _, _ in
                guard !selectedEpic.subjects.contains(where: { $0.id == state.subjectID }) else { return }
                state.subjectID = Subject.unknown.id
                selectPreferredSubject()
            }

            Picker(.fieldSubject, selection: $state.subjectID) {
                Text(Subject.unknown.summary)
                    .tag(Subject.unknown.id)

                ForEach(selectedEpic.subjects) { subject in
                    Text(subject.summary)
                        .tag(subject.id)
                }
            }
            .disabled(selectedEpic.subjects.isEmpty)
            .onChange(of: state.subjectID) { _, _ in
                guard let kind = selectedSubject?.kind else { return }
                state.preferredSubjectKind = kind
            }

            DatePicker(.fieldTime, selection: $state.duration, displayedComponents: .hourAndMinute)

            DatePicker(.fieldDate, selection: $state.date)

            TextField(.fieldComment, text: $state.comment, axis: .vertical)
                .lineLimit(2...)
                .padding(.bottom, 8)

            HStack {
                LoadingButton(
                    label: .buttonSend,
                    systemImage: "checkmark.circle",
                    isLoading: isSendingForm,
                    action: sendTimesheet
                )

                Button(action: saveDraft) {
                    Label(.buttonSave, systemImage: "plus.circle")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!isFormValid)
        }
        .toast(isPresenting: $isShowingError) {
            AlertToast(displayMode: .hud, type: .error(.red), title: String(localized: .toastError))
        }
        .toast(isPresenting: $isShowingSendSuccess) {
            AlertToast(displayMode: .hud, type: .complete(.accentColor), title: String(localized: .toastSent))
        }
        .toast(isPresenting: $isShowingSaveSuccess) {
            AlertToast(displayMode: .hud, type: .complete(.accentColor), title: String(localized: .toastSaved))
        }
    }

    /// Carries the last picked kind over to the new epic, as it offers the same kinds under different subjects.
    private func selectPreferredSubject() {
        guard state.subjectID == Subject.unknown.id, let preferredSubjectKind = state.preferredSubjectKind else { return }
        guard let subject = selectedEpic.subjects.first(where: { $0.kind == preferredSubjectKind }) else { return }

        state.subjectID = subject.id
    }

    private func sendTimesheet() {
        guard isFormValid, let selectedSubject else { return }

        Task {
            do {
                let durationHelper = DurationHelper(date: state.duration)
                let (hours, minutes) = durationHelper.transformToHoursAndMinutes()
                let timeInterval = durationHelper.transformToTimeInterval()

                isSendingForm = true
                defer { isSendingForm = false }
                
                try await jiraManager.sendTime(
                    ofSubject: selectedSubject.id,
                    hours: hours,
                    minutes: minutes,
                    date: state.date,
                    comment: state.comment
                )
                ActivityRepository.addActivity(
                    subject: selectedSubject,
                    duration: timeInterval,
                    comment: state.comment,
                    date: state.date,
                    draft: false
                )

                isShowingSendSuccess = true
                state.resetEntry()
            } catch {
                isShowingError = true
                SentrySDK.capture(error: error)
            }

            saveChoice()
        }
    }

    private func saveDraft() {
        guard isFormValid, let selectedSubject else {
            return
        }

        let durationHelper = DurationHelper(date: state.duration)
        let timeInterval = durationHelper.transformToTimeInterval()

        ActivityRepository.addActivity(
            subject: selectedSubject,
            duration: timeInterval,
            comment: state.comment,
            date: state.date,
            draft: true
        )

        isShowingSaveSuccess = true

        saveChoice()
        state.resetEntry()
    }

    private func saveChoice() {
        UserDefaults.standard.lastSelectedEpic = selectedEpic.id
        UserDefaults.standard.lastSelectedSubject = selectedSubject?.id
    }
}

#Preview {
    FormView(state: FormState())
        .environment(PreviewHelper.jiraManager)
}
