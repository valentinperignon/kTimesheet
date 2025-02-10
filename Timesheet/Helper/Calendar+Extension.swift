//
//  Calendar+Extension.swift
//  kTimesheet
//
//  Created by Valentin on 10/02/2025.
//

import Foundation

extension Calendar {
    func startOfFollowingDay(_ day: Date) -> Date {
        return date(byAdding: .day, value: 1, to: startOfDay(for: day))!
    }
}
