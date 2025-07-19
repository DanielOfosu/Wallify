//
//  PreferenceView.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI

// MARK: - Custom Form Section with True Black Background
struct TrueBlackFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
        .padding()
        .background(Color.black)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PreferenceView: View {
    @State private var launchAtLogin = true
    @ObservedObject private var settingsManager = SettingsManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TrueBlackFormSection("General") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Launch at Login", isOn: $launchAtLogin)
                        Text("Start Wallify automatically when you log in.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                TrueBlackFormSection("Performance") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Video Quality: \(Int(settingsManager.videoQuality * 100))%")
                                Spacer()
                            }
                            Slider(value: $settingsManager.videoQuality, in: 0.1...1.0)
                            Text("Higher quality may increase CPU usage.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Scaling Mode:")
                            Picker("Scaling Mode", selection: $settingsManager.videoGravity) {
                                ForEach(VideoGravity.allCases) { gravity in
                                    Text(gravity.rawValue).tag(gravity)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            Text("Determines how the wallpaper fits your screen.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Mute Video", isOn: $settingsManager.isMuted)
                            Text("Mutes the audio of video wallpapers.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                TrueBlackFormSection("System Stats") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Show System Stats Overlay", isOn: $settingsManager.showSystemStats)
                        Text("Display CPU and memory usage on your desktop.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 400, maxWidth: 500)
        .navigationTitle("Preferences")
        .trueBlackBackground()
        .onAppear {
            // Override form background colors
            if let window = NSApplication.shared.windows.first {
                window.backgroundColor = NSColor.black
            }
        }
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView()
    }
} 