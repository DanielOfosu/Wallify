import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: NSViewRepresentable {
    let url: URL
    @ObservedObject private var settingsManager = SettingsManager.shared
    
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        let player = AVPlayer(url: url)
        
        player.isMuted = settingsManager.isMuted
        player.actionAtItemEnd = .none
        player.rate = Float(settingsManager.playbackSpeed)
        
        // Apply video gravity based on settings
        applyVideoGravity(to: playerView)
        
        playerView.player = player
        playerView.controlsStyle = .none
        playerView.showsFrameSteppingButtons = false
        playerView.showsSharingServiceButton = false
        playerView.showsFullScreenToggleButton = false
        
        // Start playback
        player.play()
        
        // Set up loop
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        // Check if URL has changed and recreate player if needed
        if nsView.player?.currentItem?.asset is AVURLAsset,
           let currentURL = (nsView.player?.currentItem?.asset as? AVURLAsset)?.url,
           currentURL != url {
            // URL has changed, create new player
            let newPlayer = AVPlayer(url: url)
            newPlayer.isMuted = settingsManager.isMuted
            newPlayer.actionAtItemEnd = .none
            newPlayer.rate = Float(settingsManager.playbackSpeed)
            
            // Remove old notification observer
            if let oldPlayer = nsView.player {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldPlayer.currentItem)
            }
            
            // Set up new notification observer
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: newPlayer.currentItem,
                queue: .main
            ) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
            
            nsView.player = newPlayer
            newPlayer.play()
        } else {
            // URL hasn't changed, just update settings
            nsView.player?.isMuted = settingsManager.isMuted
            nsView.player?.rate = Float(settingsManager.playbackSpeed)
        }
        
        applyVideoGravity(to: nsView)
    }
    
    private func applyVideoGravity(to playerView: AVPlayerView) {
        switch settingsManager.videoGravity {
        case .fill:
            playerView.videoGravity = .resizeAspectFill
        case .fit:
            playerView.videoGravity = .resizeAspect
        case .stretch:
            playerView.videoGravity = .resize
        }
    }
}

// MARK: - Video Preview Placeholder
struct VideoPreviewPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Video Selected")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Select a video from the library below to preview it here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .trueBlackBackground()
    }
}

// MARK: - Video Preview Container
struct VideoPreviewView: View {
    let videoItem: VideoItem?
    @EnvironmentObject var wallpaperManager: WallpaperManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Preview")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            if let videoItem = videoItem {
                VideoPlayerView(url: videoItem.url)
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                
                // Video info
                VStack(alignment: .leading, spacing: 4) {
                    Text(videoItem.fileName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    HStack {
                        Text(videoItem.formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(videoItem.formattedFileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if videoItem.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 4)
            } else {
                VideoPreviewPlaceholder()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .trueBlackBackground()
    }
} 