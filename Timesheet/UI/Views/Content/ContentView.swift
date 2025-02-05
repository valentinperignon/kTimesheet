//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import SwiftUI

extension Epic {
    static let unknown = Epic(id: "-1", summary: "-- Faites un choix", subjects: [])
}

extension Subject {
    static let unknown = Subject(id: "-1", summary: "-- Faites un choix")
}

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: TimesheetViewModel

    @State private var epic = Epic.unknown
    @State private var subject = Subject.unknown

    @State private var time = 0

    private var isFormValid: Bool {
        return epic != .unknown && subject != .unknown && time > 0
    }

    init(userManager: UserManager) {
        _viewModel = State(wrappedValue: TimesheetViewModel(userManager: userManager))
    }

    var body: some View {
        Form {
            Picker("Epic", selection: $epic) {
                Text(Epic.unknown.summary)
                    .tag(Epic.unknown)

                ForEach(viewModel.epics) { epic in
                    Text(epic.summary)
                        .tag(epic)
                }
            }
            .task {
                try? await viewModel.fetchEpics()
            }
            .task(id: epic) {
                guard epic != .unknown else { return }
                subject = .unknown
                try? await viewModel.fetchIssues(of: epic)
            }

            Picker("Sujet", selection: $subject) {
                Text(Subject.unknown.summary)
                    .tag(Subject.unknown)

                ForEach(epic.subjects) { epic in
                    Text(epic.summary)
                        .tag(epic)
                }
            }

            TextField("Temps", value: $time, format: .number)

            Button(action: validateTimesheet) {
                Label("Valider", systemImage: "checkmark.circle")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!isFormValid)
            .padding(.top, 8)
        }
        .padding()
    }

    private func validateTimesheet() {
        Task {
            try await viewModel.validate(issue: subject, time: time)

            epic = .unknown
            subject = .unknown
            time = 0
        }
    }
}

#Preview {
    ContentView(userManager: UserManager())
}
