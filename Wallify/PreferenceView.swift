//
//  PreferenceView.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI

struct PreferenceView: View {
    @State private var launchAtLogin = true
    @ObservedObject private var settingsManager = SettingsManager.shared

    var body: some View {
        Form {
            Section(header: Text("General").font(.headline)) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
            }
            
            Section(header: Text("Performance").font(.headline)) {
                VStack {
                    HStack {
                        Text("Video Quality")
                        Spacer()
                        Text(String(format: "%.2f", settingsManager.videoQuality))
                    }
                    Slider(value: $settingsManager.videoQuality, in: 0.1...1.0, step: 0.1)
                }
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 400)
        .navigationTitle("Preferences")
    }
}

#Preview {
    PreferenceView()
} 