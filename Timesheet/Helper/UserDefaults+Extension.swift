//
//  UserDefaults+Extension.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 07.02.2025.
//

import Foundation

extension UserDefaults {
    var currentUsername: String? {
        get {
            return string(forKey: "currentUsername")
        }
        set {
            set(newValue, forKey: "currentUsername")
        }
    }
}
