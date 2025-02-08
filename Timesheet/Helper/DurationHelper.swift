//
//  DurationHelper.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import Foundation

struct DurationHelper {
    let date: Date

    func transformToHoursAndMinutes() -> (Int, Int) {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (dateComponents.hour ?? 0, dateComponents.minute ?? 0)
    }

    func transformToTimeInterval() -> TimeInterval {
        let (hours, minutes) = transformToHoursAndMinutes()

        let hoursToSeconds = hours * 60 * 60
        let minutesToSeconds = minutes * 60
        let totalOfSeconds = hoursToSeconds + minutesToSeconds

        let timeInterval = TimeInterval(totalOfSeconds)
        return timeInterval
    }
}
