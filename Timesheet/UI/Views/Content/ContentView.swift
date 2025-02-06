//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//


import SimpleToast
import RealmSwift
import SwiftUI

struct ContentView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(RootViewModel.self) private var rootViewModel

    @State private var viewModel: TimesheetViewModel

    @State private var epicID = Epic.unknown.id
    @State private var subjectID = Subject.unknown.id
    @State private var time = 0.0

    @State private var isShowingSuccess = false
    @State private var isShowingError = false

    @ObservedResults(Epic.self, sortDescriptor: SortDescriptor(keyPath: "summary", ascending: true)) var epics

    private var selectedEpic: Epic {
        epics.first { $0.id == epicID } ?? .unknown
    }

    private var isFormValid: Bool {
        return epicID != Epic.unknown.id && subjectID != Subject.unknown.id && time > 0
    }

    init(userManager: UserManager) {
        _viewModel = State(wrappedValue: TimesheetViewModel(userManager: userManager))
    }

    var body: some View {
        VStack {
            HStack {
                Text("Timesheet")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: logout) {
                    Label("Se Déconnecter", systemImage: "person.slash")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.accessoryBar)
            }
            .padding(.bottom, 8)

            Form {
                Picker("Epic", selection: $epicID) {
                    Text(Epic.unknown.summary)
                        .tag(Epic.unknown.id)

                    ForEach(epics, id: \.self) { epic in
                        Text(epic.summary)
                            .tag(epic.id)
                    }
                }
                .disabled(epics.isEmpty)
                .task {
                    try? await viewModel.fetchEpics()
                }
                .task(id: epicID) {
                    guard epicID != Epic.unknown.id else { return }
                    subjectID = Subject.unknown.id
                    try? await viewModel.fetchIssues(of: epicID)
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

                TextField("Temps", value: $time, format: .number)

                Button(action: validateTimesheet) {
                    Label("Valider", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(!isFormValid)
                .padding(.top, 8)
            }
        }
        .padding()
        .simpleToast(isPresented: $isShowingError, options: .timesheet) {
            Label("Error", systemImage: "xmark.circle")
                .toast()
        }
        .simpleToast(isPresented: $isShowingSuccess, options: .timesheet) {
            Label("Envoyé", systemImage: "checkmark.circle")
                .toast()
        }
    }

    private func validateTimesheet() {
        Task {
            do {
                try await viewModel.validate(issueID: subjectID, time: time)
                isShowingSuccess = true
            } catch {
                isShowingError = true
            }

            epicID = Epic.unknown.id
            subjectID = Epic.unknown.id
            time = 0
        }
    }

    private func logout() {
        Task {
            try await userManager.removeUser()
            rootViewModel.transition(to: .login)
        }
    }
}

#Preview {
   ContentView(userManager: UserManager())
}
