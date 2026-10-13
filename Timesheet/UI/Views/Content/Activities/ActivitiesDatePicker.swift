//
//  ActivitiesDatePicker.swift
//  kTimesheet
//
//  Created by Gibran Chevalley on 31.08.2026.
//

import SwiftUI

struct ActivitiesDatePicker: View {
    @Environment(\.calendar) private var calendar
    
    @Binding var date: Date

    var body: some View {
        HStack {
            HStack(spacing: 2) {
                DatePicker(.activitiesDatePicker, selection: $date, displayedComponents: .date)
                    .datePickerStyle(.field)
                    .labelsHidden()

                Stepper(onIncrement: { shiftDate(byDays: 1) }, onDecrement: { shiftDate(byDays: -1) }) {
                    Text(.activitiesDatePicker)
                }
                .labelsHidden()
            }

            ZStack {
                Text(date, format: .dateTime.weekday(.wide))
                    .foregroundStyle(.secondary)
                
                ForEach(calendar.weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .opacity(0)
                }
            }
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
