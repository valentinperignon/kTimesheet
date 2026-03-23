//
//  ActivityView.swift
//  kTimesheet
//
//  Created by Valentin Perignon on 08.02.2025.
//

import SwiftUI

struct ActivityView: View {
    let activity: Activity

    private var color: Color {
        activity.draft ? .red : .blue
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(activity.summary)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if activity.draft {
                    Button(action: deleteActivity) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 2)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)

                    Text(activity.date, format: .dateTime.hour().minute())
                }

                DurationView(duration: activity.duration)
            }

            if !activity.comment.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble")
                        .foregroundStyle(.secondary)
                    Text(activity.comment)
                }
            }

            if activity.draft {
                Text("Brouillon")
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .background(color.opacity(0.8), in: .capsule)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(6)
        .padding(.leading, 4)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(color.tertiary)
                .frame(width: 4)
        }
        .background(color.quaternary.opacity(0.3))
        .clipShape(.rect(cornerRadius: 8))
    }

    private func deleteActivity() {
        ActivityManager.shared.deleteActivity(activity: activity)
    }
}

#Preview {
    VStack {
        ActivityView(activity: Activity(subject: .unknown, duration: 120, comment: "Hey", date: .now, draft: true))
        ActivityView(activity: Activity(subject: .unknown, duration: 120, comment: "Hey", date: .now, draft: true))
    }
}
