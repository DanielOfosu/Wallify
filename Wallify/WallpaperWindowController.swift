import Cocoa
import AVKit
import Combine

class WallpaperWindowController: NSWindowController {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var settingsSubscription: AnyCancellable?

    convenience init() {
        let window = NSWindow(contentRect: .zero,
                              styleMask: [.borderless],
                              backing: .buffered,
                              defer: false)
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1) // Position below desktop icons
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        
        self.init(window: window)
        setupPlayerView()
        observeSettings()
    }

    private func setupPlayerView() {
        let playerView = NSView()
        playerView.wantsLayer = true
        window?.contentView = playerView
        
        playerLayer = AVPlayerLayer()
        playerLayer?.videoGravity = .resizeAspectFill
        playerView.layer?.addSublayer(playerLayer!)

        if let screen = NSScreen.main {
            window?.setFrame(screen.frame, display: true)
            playerLayer?.frame = screen.frame
        }
        
        window?.orderBack(nil)
    }
    
    func loadURL(_ url: URL) {
        player = AVPlayer(url: url)
        player?.isMuted = true
        player?.actionAtItemEnd = .none
        
        playerLayer?.player = player
        applySettings()
        player?.play()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @objc private func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    private func observeSettings() {
        settingsSubscription = SettingsManager.shared.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.applySettings()
            }
        }
    }
    
    private func applySettings() {
        guard let player = player, let item = player.currentItem else { return }
        
        let settings = SettingsManager.shared
        
        // Adjust preferredPeakBitRate based on quality setting
        let quality = settings.videoQuality
        if quality > 0.8 {
            item.preferredPeakBitRate = 0 // Unrestricted
        } else if quality > 0.5 {
            item.preferredPeakBitRate = 2_000_000 // High
        } else {
            item.preferredPeakBitRate = 1_000_000 // Medium
        }
    }

    func stop() {
        player?.pause()
        player = nil
        playerLayer?.player = nil
    }
}
