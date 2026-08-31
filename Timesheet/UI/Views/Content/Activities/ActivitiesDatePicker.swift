//
//  ActivitiesDatePicker.swift
//  kTimesheet
//
//  Created by Gibran Chevalley on 31.08.2026.
//

import SwiftUI

/// Date picker showing the weekday of the selection, whose stepper moves by a whole day so that
/// month and year carry over on their own.
struct ActivitiesDatePicker: View {
    @Binding var date: Date

    private var weekday: String {
        return date.formatted(.dateTime.weekday(.wide))
    }

    var body: some View {
        HStack {
            DatePicker(.activitiesDatePicker, selection: $date, displayedComponents: .date)
                .datePickerStyle(.field)
                .labelsHidden()
                .fixedSize()

            Stepper(onIncrement: { shiftDate(byDays: 1) }, onDecrement: { shiftDate(byDays: -1) }) {
                Text(.activitiesDatePicker)
            }
            .labelsHidden()

            Text(weekday)
                .foregroundStyle(.secondary)
        }
    }

    private func shiftDate(byDays days: Int) {
        guard let shiftedDate = Calendar.current.date(byAdding: .day, value: days, to: date) else { return }
        date = shiftedDate
    }
}

#Preview {
    @Previewable @State var date = Date.now
    ActivitiesDatePicker(date: $date)
        .padding()
}
