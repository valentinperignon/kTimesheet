//
//  LoginView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import AlertToast
import Sentry
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
            #if os(macOS)
            Text(verbatim: Constants.appName)
                .font(.title)
            #endif

            TextField(String(localized: .fieldEmail), text: $username)
                #if os(macOS)
                .textFieldStyle(.roundedBorder)
                #endif
                .textContentType(.emailAddress)
                #if os(iOS)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                #endif
                .onSubmit(login)

            SecureField(.fieldToken, text: $token)
                #if os(macOS)
                .textFieldStyle(.roundedBorder)
                #endif
                .textContentType(.password)
                .onSubmit(login)

            Button(action: didTapHelpButton) {
                Text(.buttonNoAtlassianToken)
                    .font(.caption)
            }
            #if os(macOS)
            .buttonStyle(.link)
            #else
            .buttonStyle(.borderless)
            #endif
            .padding(.bottom, 8)

            #if os(macOS)
            loginButton
            #endif
        }
        #if os(macOS)
        .padding()
        #else
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FormActionBar {
                loginButton
            }
        }
        #endif
        .toast(isPresenting: $isShowingError) {
            AlertToast(displayMode: .hud, type: .error(.red), title: String(localized: .toastError))
        }
    }

    private var loginButton: some View {
        Button(action: login) {
            Label(.buttonLogin, systemImage: "person")
                #if os(iOS)
                .frame(maxWidth: .infinity, minHeight: 28)
                #endif
        }
        #if os(iOS)
        .buttonStyle(.borderedProminent)
        #else
        .buttonStyle(.bordered)
        #endif
        .controlSize(.large)
        .disabled(!isFormValid)
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
                SentrySDK.capture(error: error)
            }
        }
    }
}

#Preview {
    LoginView()
}
