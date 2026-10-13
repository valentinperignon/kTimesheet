import SwiftUI

/// Keeps form actions visible above the keyboard and the bottom safe area.
struct FormActionBar<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 12) {
            content
        }
        .font(.headline)
        .controlSize(.large)
        .frame(maxWidth: 600)
        .padding()
    }
}
