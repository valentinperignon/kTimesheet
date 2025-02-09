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

    var lastSelectedEpic: String? {
        get {
            return string(forKey: "lastSelectedEpic")
        }
        set {
            set(newValue, forKey: "lastSelectedEpic")
        }
    }

    var lastSelectedSubject: String? {
        get {
            return string(forKey: "lastSelectedSubject")
        }
        set {
            set(newValue, forKey: "lastSelectedSubject")
        }
    }
}
