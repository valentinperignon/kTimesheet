//
//  LoginView.swift
//  Timesheet
//
//  Created by Valentin Perignon on 05.02.2025.
//

import SimpleToast
import SwiftUI

struct LoginView: View {
    @Environment(\.openURL) private var openURL

    @Environment(UserManager.self) private var userManager
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
            TextField("Email", text: $username)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .onSubmit(login)

            SecureField("Token", text: $token)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .onSubmit(login)

            Button(action: didTapHelpButton) {
                Text("Pas de token Atlassian ?")
                    .font(.caption)
            }
            .buttonStyle(.link)
            .padding(.bottom, 8)

            Button(action: login) {
                Label("Se connecter", systemImage: "person")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!isFormValid)
        }
        .padding()
        .simpleToast(isPresented: $isShowingError, options: .timesheet) {
            Label("Erreur", systemImage: "xmark")
                .toast()
        }
    }

    private func didTapHelpButton() {

    }

    private func login() {
        guard isFormValid else { return }

        Task {
            do {
                try await userManager.saveUser(username: trimmedUsername, token: trimmedToken)
                guard let jiraManager = userManager.jiraManager else { return }
                rootViewModel.transition(to: .content(jiraManager))
            } catch {
                isShowingError = true
                print("The following error occurred: \(error)")
            }
        }
    }
}

#Preview {
    LoginView()
}
