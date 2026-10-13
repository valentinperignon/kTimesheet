//
//  EpicsList.swift
//  Timesheet
//
//  Created by Valentin Perignon on 06.02.2025.
//

import RealmSwift
import SwiftUI

struct EpicsList: View {
    @ObservedResults(Epic.self, sortDescriptor: SortDescriptor(keyPath: "summary", ascending: true)) var epics

    @State private var searchText = ""

    private var filteredEpics: [Epic] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return epics.filter { query.isEmpty || $0.summary.localizedStandardContains(query) }
    }

    var body: some View {
        #if os(iOS)
        List(filteredEpics) { epic in
            EpicToggle(epic: epic)
        }
        .searchable(text: $searchText)
        .overlay {
            if filteredEpics.isEmpty && !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        #else
        Table(epics) {
            TableColumn(.tableName, value: \.summary)
            TableColumn(.tableShowing) { EpicToggle(epic: $0) }
                .width(50)
        }
        #endif
    }
}

struct EpicToggle: View {
    @State private var isShowing: Bool

    private let epic: Epic

    init(epic: Epic) {
        self.epic = epic
        _isShowing = State(wrappedValue: epic.showing)
    }

    var body: some View {
        Toggle(isOn: $isShowing) {
            #if os(iOS)
            Text(epic.summary)
            #else
            Text(.settingsEpicShowing)
            #endif
        }
            #if os(macOS)
            .toggleStyle(.checkbox)
            .labelsHidden()
            #endif
            .onChange(of: isShowing) { _, newValue in
                let realm = try! Realm()
                try? realm.write {
                    guard let savedEpic = realm.object(ofType: Epic.self, forPrimaryKey: epic.id) else { return }
                    savedEpic.showing = newValue
                }
            }
    }
}

#Preview {
    EpicsList()
}
