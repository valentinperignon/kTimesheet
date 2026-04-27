//
//  FormView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import AlertToast
import RealmSwift
import SwiftUI

struct FormView: View {
    @Environment(JiraManager.self) private var jiraManager

    @ObservedResults(
        Epic.self,
        filter: NSPredicate(format: "showing == true"),
        sortDescriptor: SortDescriptor(keyPath: "summary", ascending: true)
    ) var epics

    @State private var epicID = Epic.unknown.id
    @State private var subjectID = Subject.unknown.id
    @State private var duration = Calendar.current.startOfDay(for: .now)
    @State private var date = Date.now
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
            Picker(.fieldEpic, selection: $epicID) {
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
                guard !selectedEpic.subjects.contains(where: { $0.id == subjectID }) else { return }
                subjectID = Subject.unknown.id
            }

            Picker(.fieldSubject, selection: $subjectID) {
                Text(Subject.unknown.summary)
                    .tag(Subject.unknown.id)

                ForEach(selectedEpic.subjects) { subject in
                    Text(subject.summary)
                        .tag(subject.id)
                }
            }
            .disabled(selectedEpic.subjects.isEmpty)

            DatePicker(.fieldTime, selection: $duration, displayedComponents: .hourAndMinute)

            DatePicker(.fieldDate, selection: $date)

            TextField(.fieldComment, text: $comment, axis: .vertical)
                .lineLimit(2...)
                .padding(.bottom, 8)

            HStack {
                LoadingButton(
                    label: LocalizedStringResource.buttonSend,
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
        .onAppear {
            setStateWithLastSelection()
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
                try await jiraManager.sendTime(
                    ofSubject: selectedSubject.id,
                    hours: hours,
                    minutes: minutes,
                    date: date,
                    comment: comment
                )
                ActivityRepository.addActivity(
                    subject: selectedSubject,
                    duration: timeInterval,
                    comment: comment,
                    date: date,
                    draft: false
                )
                isSendingForm = false

                isShowingSendSuccess = true

                resetForm()
            } catch {
                isShowingError = true
            }

            saveChoice()
        }
    }

    private func saveDraft() {
        guard isFormValid, let selectedSubject else { return }

        let durationHelper = DurationHelper(date: duration)
        let timeInterval = durationHelper.transformToTimeInterval()

        ActivityRepository.addActivity(subject: selectedSubject, duration: timeInterval, comment: comment, date: date, draft: true)

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
        date = .now
        comment = ""
    }
}

#Preview {
    FormView()
        .environment(PreviewHelper.jiraManager)
}
