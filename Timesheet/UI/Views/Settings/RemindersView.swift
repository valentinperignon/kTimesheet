//
//  RemindersView.swift
//  kTimesheet
//
//  Created by Valentin on 27/03/2026.
//

import SwiftUI

struct RemindersView: View {
    @AppStorage("shouldSendNotifications") private var shouldSendNotifications: Bool = true
    
    var body: some View {
        VStack {
            Toggle("Receive daily reminders", isOn: $shouldSendNotifications)
                .toggleStyle(.switch)
            
            Button(action: <#T##() -> Void#>, label: <#T##() -> View#>)
            
            ScrollView {
                
            }
        }
    }
    
    private func add
}
