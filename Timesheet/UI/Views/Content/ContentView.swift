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
    private static let minimumFetchDelay = TimeInterval(60 * 60 * 3) // 3 hours

    @Environment(UserManager.self) private var userManager
    @Environment(RootViewModel.self) private var rootViewModel

    @State private var epicID = Epic.unknown.id
    @State private var subjectID = Subject.unknown.id
    @State private var duration = Calendar.current.startOfDay(for: .now)
    @State private var comment = ""

    @State private var isSendingForm = false

    @State private var isShowingSuccess = false
    @State private var isShowingError = false

    @ObservedResults(Epic.self, sortDescriptor: SortDescriptor(keyPath: "summary", ascending: true)) var epics

    private let jiraManager: JiraManager

    private var selectedEpic: Epic {
        epics.first { $0.id == epicID } ?? .unknown
    }

    private var isFormValid: Bool {
        return epicID != Epic.unknown.id && subjectID != Subject.unknown.id
    }

    init(jiraManager: JiraManager) {
        self.jiraManager = jiraManager
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
        .task {
            await fetchEpics()
        }
    }

    private func fetchEpics() async {
        let lastFetchDate = UserDefaults.standard.object(forKey: "lastFetchDate") as? Date

        if let lastFetchDate, lastFetchDate.distance(to: .now) < Self.minimumFetchDelay {
            return
        }

        do {
            try await jiraManager.fetchEpics()
            UserDefaults.standard.set(Date.now, forKey: "lastFetchDate")
        } catch {
            print("Impossible to fetch epics")
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

    private func logout() {
        Task {
            try await userManager.removeUser()
            rootViewModel.transition(to: .login)
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
    ContentView(
        jiraManager: JiraManager(jiraFetcher: JiraFetcher(user: User(username: "a", token: "a")))
    )
}
