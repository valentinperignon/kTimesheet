//
//  AccountStore.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation

actor UserStore {
    enum DomainError: Error {
        case userNotFound
        case invalidUser
        case keychainError(OSStatus)
    }

    func saveUser(username: String, token: String) throws {
        let tokenData = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "fr.valentinperignon.Timesheet",
            kSecAttrAccount as String: username,
            kSecValueData as String: tokenData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw DomainError.keychainError(status) }
    }

    func fetchUser(username: String) throws -> User {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "fr.valentinperignon.Timesheet",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else { throw DomainError.userNotFound }
        guard status == errSecSuccess else { throw DomainError.keychainError(status) }

        guard let foundItem = item as? [String: Any],
              let tokenData = foundItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8),
              let username = foundItem[kSecAttrAccount as String] as? String else {
            throw DomainError.invalidUser
        }

        return User(username: username, token: token)
    }
}
