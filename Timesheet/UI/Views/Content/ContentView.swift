//
//  ContentView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import SwiftUI

struct ContentView: View {
    let viewModel: TimesheetViewModel

    var body: some View {
        VStack {
            if viewModel.epics.isEmpty {
                Text("Loading...")
            } else {
                FormView(viewModel: viewModel, epics: viewModel.epics)
            }
        }
        .padding()
        .task {
            try? await viewModel.fetchEpics()
        }
    }
}

struct FormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var epic: Epic
    @State private var issue: Epic
    @State private var time = 0

    let viewModel: TimesheetViewModel
    let epics: [Epic]

    init(viewModel: TimesheetViewModel, epics: [Epic]) {
        self.viewModel = viewModel
        self.epics = epics

        _epic = .init(wrappedValue: epics.first!)
        _issue = .init(wrappedValue: epics.first!)
    }

    var body: some View {
        Form {
            Picker("Epic", selection: $epic) {
                ForEach(epics) { epic in
                    Text(epic.summary)
                        .tag(epic)
                }
            }
            .task(id: epic) {
                try? await viewModel.fetchIssues(of: epic.key)
            }

            if !viewModel.issues.isEmpty {
                Picker("Issues", selection: $issue) {
                    ForEach(viewModel.issues) { epic in
                        Text(epic.summary)
                            .tag(epic)
                    }
                }
                .onAppear {
                    issue = viewModel.issues.first!
                }

                TextField("Time", value: $time, format: .number)

                Button("Valider") {
                    Task {
                        try await viewModel.validate(issue: issue.key, time: time)
                    }
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: TimesheetViewModel())
}
