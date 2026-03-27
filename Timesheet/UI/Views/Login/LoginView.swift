//
//  LoginView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import ToastView
import SwiftUI

struct LoginView: View {
    @Environment(\.openURL) private var openURL
    @Environment(RootViewModel.self) private var rootViewModel

    @State private var username = ""
    @State private var token = ""
    @State private var isShowingError = false

    private var trimmedUsername: String {
        return username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedToken: String {
        return token.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isFormValid: Bool {
        return !trimmedUsername.isEmpty && !trimmedToken.isEmpty
    }

    var body: some View {
        Form {
            Text(verbatim: Constants.appName)
                .font(.title)

            TextField(String(localized: .fieldEmail), text: $username)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .onSubmit(login)

            SecureField(.fieldToken, text: $token)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .onSubmit(login)

            Button(action: didTapHelpButton) {
                Text(.buttonNoAtlassianToken)
                    .font(.caption)
            }
            .buttonStyle(.link)
            .padding(.bottom, 8)

            Button(action: login) {
                Label(.buttonLogin, systemImage: "person")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!isFormValid)
        }
        .padding()
        .toast(isPresented: $isShowingError, title: String(localized: .toastError), icon: Image(systemName: "xmark"))
    }

    private func didTapHelpButton() {
        openURL(URL(string: "https://id.atlassian.com/manage-profile/security/api-tokens")!)
    }

    private func login() {
        guard isFormValid else { return }

        Task {
            do {
                try await UserManager.shared.saveUser(username: trimmedUsername, token: trimmedToken)
                guard let jiraManager = UserManager.shared.jiraManager else {
                    return
                }
                
                rootViewModel.transition(to: .content(jiraManager))
            } catch {
                isShowingError = true
            }
        }
    }
}

#Preview {
    LoginView()
}
