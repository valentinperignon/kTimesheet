//
//  TimesheetViewModel.swift
//  Timesheet
//
//  Created by Valentin Perignon on 04.02.2025.
//

import Foundation

struct ApiFetcher {
    private let baseURL = "https://infomaniak.atlassian.net"

    private var authenticatedSession: URLSession!

    enum DomainError: Error {
        case invalidURL
    }

    init() {
        createAuthenticatedSession()
    }

    func makeRequest(path: String, parameters: Codable? = nil) throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path.append(path)

        guard let url = urlComponents?.url else {
            throw DomainError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let parameters {
            let encoder = JSONEncoder()
            let data = try encoder.encode(parameters)
            urlRequest.httpBody = data
        }

        return urlRequest
    }

    func performRequest(_ request: URLRequest) async throws {
        let (data, _) = try await authenticatedSession.data(for: request)
    }

    func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, _) = try await authenticatedSession.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private mutating func createAuthenticatedSession() {
        let username = "valentin.perignon@infomaniak.com"
        let token = "ATATT3xFfGF0gCTblLrJbVFPFHr5oHpbLdHB26yNar_bEN0_HkKXdrZ3fTV06EWjHrcaXmc_RIItf3z8bpZQTR9R3eFWgQ1jttLf1x-xYlWAiuHqj2YT7fKxwSjbXnvaI7Id_0LnKqAvv2s8cazPAkKDbXD6bHNvm9S61E-vci-ZWGVhNIaSgow=DB106DF1"

        let authorizationData = Data("\(username):\(token)".utf8)
        let base64Authorization = authorizationData.base64EncodedString()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Basic \(base64Authorization)"
        ]

        authenticatedSession = URLSession(configuration: configuration)
    }
}

struct SearchResultAPI: Codable, Sendable {
    let issues: [IssueAPI]
}

struct IssueAPI: Codable, Sendable {
    let key: String
    let fields: FieldsAPI
}

struct FieldsAPI: Codable, Sendable {
    let summary: String
}

struct Epic: Sendable, Hashable, Identifiable {
    var id: String { key }
    let key: String
    let summary: String

    init(from issue: IssueAPI) {
        key = issue.key
        summary = issue.fields.summary
    }
}

@Observable
final class TimesheetViewModel {
    private(set) var epics = [Epic]()
    private(set) var issues = [Epic]()

    private let apiFetcher = ApiFetcher()

    func fetchEpics() async throws {
        let request = try apiFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND issueType=Epic"]
        )
        let result: SearchResultAPI = try await apiFetcher.performRequest(request)

        epics = result.issues
            .map { Epic(from: $0) }
            .sorted { $0.summary < $1.summary }
    }

    func fetchIssues(of parent: String) async throws {
        let request = try apiFetcher.makeRequest(
            path: "/rest/api/2/search",
            parameters: ["jql": "project=TIM AND parentEpic=\(parent)"]
        )
        let result: SearchResultAPI = try await apiFetcher.performRequest(request)

        issues = result.issues
            .map { Epic(from: $0) }
            .sorted { $0.summary < $1.summary }
    }

    func validate(issue: String, time: Int) async throws {
        let request = try apiFetcher.makeRequest(
            path: "/rest/api/2/issue/\(issue)/worklog",
            parameters: TimeSpent(timeSpent: time)
        )
        let _ = try await apiFetcher.performRequest(request)
    }
}

struct TimeSpent: Codable {
    let timeSpent: Int
}
