//
//  JiraFetcher.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import Foundation

struct JiraFetcher {
    private let baseURL = "https://infomaniak.atlassian.net"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    private var authenticatedSession: URLSession!

    enum DomainError: Error {
        case invalidURL
    }

    enum RequestMethod: String {
        case post = "POST"
    }

    init(user: User) {
        setupAuthenticatedSession(for: user)
    }

    func makeRequest(path: String, method: RequestMethod = .post, queryItems: [URLQueryItem]? = nil, parameters: Codable? = nil) throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path.append(path)

        if let queryItems {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            throw DomainError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let parameters {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            let data = try encoder.encode(parameters)
            urlRequest.httpBody = data
        }

        return urlRequest
    }

    @discardableResult
    func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, _) = try await authenticatedSession.data(for: request)
        return data
    }

    func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data = try await performRequest(request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private mutating func setupAuthenticatedSession(for user: User) {
        let authorizationData = Data("\(user.username):\(user.token)".utf8)
        let base64Authorization = authorizationData.base64EncodedString()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Basic \(base64Authorization)"
        ]

        authenticatedSession = URLSession(configuration: configuration)
    }
}
