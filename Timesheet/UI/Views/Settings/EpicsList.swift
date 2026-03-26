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
        Table(epics) {
            TableColumn(.tableName, value: \.summary)
            TableColumn(.tableShowing) { EpicToggle(epic: $0) }
                .width(50)
        }
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
        Toggle(.settingsEpicShowing, isOn: $isShowing)
            .toggleStyle(.checkbox)
            .labelsHidden()
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
