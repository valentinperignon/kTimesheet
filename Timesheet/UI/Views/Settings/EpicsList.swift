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

    var body: some View {
        #if os(iOS)
        List(epics) { epic in
            EpicToggle(epic: epic)
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
