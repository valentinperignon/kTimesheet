//
//  AccountStore.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation
import KeychainAccess

actor UserStore {
    private static let service = "fr.valentinperignon.kTimesheet"

    private let keychain = Keychain(service: "fr.valentinperignon.kTimesheet")

    enum DomainError: Error {
        case userNotFound
        case invalidUser
        case keychainError(Error)
    }

    func saveUser(username: String, token: String) throws {
        do {
            try keychain.set(token, key: username)
        } catch {
            throw DomainError.keychainError(error)
        }
    }

    func fetchUser(username: String) throws -> User {
        let token: String?
        do {
            token = try keychain.get(username)
        } catch {
            throw DomainError.keychainError(error)
        }

        guard let token else {
            throw DomainError.invalidUser
        }
        return User(username: username, token: token)
    }

    func removeUser(username: String) throws {
        do {
            try keychain.remove(username)
        } catch {
            throw DomainError.keychainError(error)
        }
    }
}
