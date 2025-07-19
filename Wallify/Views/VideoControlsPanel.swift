import SwiftUI

struct VideoControlsPanel: View {
    @ObservedObject private var settingsManager = SettingsManager.shared
    @EnvironmentObject var wallpaperManager: WallpaperManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Video Controls")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Quality Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Video Quality")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(settingsManager.videoQuality * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                
                Slider(value: $settingsManager.videoQuality, in: 0.1...1.0, step: 0.1)
                    .onChange(of: settingsManager.videoQuality) { _ in
                        updateActiveWallpaper()
                    }
                
                Text("Higher quality may increase CPU usage")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Scaling Mode
            VStack(alignment: .leading, spacing: 8) {
                Text("Scaling Mode")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Scaling Mode", selection: $settingsManager.videoGravity) {
                    ForEach(VideoGravity.allCases) { gravity in
                        HStack {
                            Image(systemName: scalingIcon(for: gravity))
                            Text(gravity.rawValue)
                        }
                        .tag(gravity)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: settingsManager.videoGravity) { _ in
                    updateActiveWallpaper()
                }
                
                Text(scalingDescription(for: settingsManager.videoGravity))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Mute Toggle
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: settingsManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundColor(settingsManager.isMuted ? .red : .green)
                    
                    Text("Audio")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.isMuted)
                        .onChange(of: settingsManager.isMuted) { _ in
                            updateActiveWallpaper()
                        }
                }
                
                Text(settingsManager.isMuted ? "Video audio is muted" : "Video audio is enabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quick Actions section removed
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .trueBlackBackground()
    }
    
    private func updateActiveWallpaper() {
        // Update the active wallpaper with new settings
        if let currentURL = wallpaperManager.contentURL {
            // Trigger a refresh by temporarily setting to nil and back
            let tempURL = wallpaperManager.contentURL
            wallpaperManager.contentURL = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                wallpaperManager.contentURL = tempURL
            }
        }
    }
    
    private func selectNewVideo() {
        let fileSelectionManager = FileSelectionManager()
        fileSelectionManager.selectVideoFile { url in
            if let url = url {
                wallpaperManager.contentURL = url
            }
        }
    }
    
    private func openPreferences() {
        // This would typically open the preferences window
        // For now, we'll just print a message
        print("Opening preferences...")
    }
    
    private func scalingIcon(for gravity: VideoGravity) -> String {
        switch gravity {
        case .fill:
            return "arrow.up.left.and.arrow.down.right"
        case .fit:
            return "arrow.down.right.and.arrow.up.left"
        case .stretch:
            return "arrow.left.and.right"
        }
    }
    
    private func scalingDescription(for gravity: VideoGravity) -> String {
        switch gravity {
        case .fill:
            return "Fills the entire screen, may crop video edges"
        case .fit:
            return "Fits the entire video, may show letterboxing"
        case .stretch:
            return "Stretches video to fill screen, may distort"
        }
    }
}

// MARK: - Preview
struct VideoControlsPanel_Previews: PreviewProvider {
    static var previews: some View {
        VideoControlsPanel()
            .environmentObject(WallpaperManager())
            .frame(width: 300, height: 500)
    }
} 