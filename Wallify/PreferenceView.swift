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
                Text("Start Wallify automatically when you log in.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Performance").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Video Quality: \(Int(settingsManager.videoQuality * 100))%")
                    Slider(value: $settingsManager.videoQuality, in: 0.1...1.0)
                    Text("Higher quality may increase CPU usage.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Picker("Scaling Mode:", selection: $settingsManager.videoGravity) {
                    ForEach(VideoGravity.allCases) { gravity in
                        Text(gravity.rawValue).tag(gravity)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("Determines how the wallpaper fits your screen.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Toggle("Mute Video", isOn: $settingsManager.isMuted)
                Text("Mutes the audio of video wallpapers.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("System Stats").font(.headline)) {
                Toggle("Show System Stats Overlay", isOn: $settingsManager.showSystemStats)
                Text("Display CPU and memory usage on your desktop.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 500)
        .navigationTitle("Preferences")
        .padding()
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView()
    }
} 