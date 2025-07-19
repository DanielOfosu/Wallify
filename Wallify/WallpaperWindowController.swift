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

        // Set initial display
        updateDisplay()
        
        window?.orderBack(nil)
    }
    
    private func updateDisplay() {
        let settings = SettingsManager.shared
        let targetDisplayID = settings.selectedDisplayID
        
        // Find the screen for the selected display
        var targetScreen: NSScreen?
        for screen in NSScreen.screens {
            if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
               screenNumber == targetDisplayID {
                targetScreen = screen
                break
            }
        }
        
        // Fallback to main screen if target not found
        let screen = targetScreen ?? NSScreen.main ?? NSScreen.screens.first
        
        if let screen = screen {
            window?.setFrame(screen.frame, display: true)
            playerLayer?.frame = screen.frame
        }
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
        
        // Apply playback speed
        player.rate = Float(settings.playbackSpeed)
        
        // Apply mute setting
        player.isMuted = settings.isMuted
        
        // Adjust preferredPeakBitRate based on quality setting
        let quality = settings.videoQuality
        if quality > 0.8 {
            item.preferredPeakBitRate = 0 // Unrestricted
        } else if quality > 0.5 {
            item.preferredPeakBitRate = 2_000_000 // High
        } else {
            item.preferredPeakBitRate = 1_000_000 // Medium
        }
        
        // Apply video gravity
        switch settings.videoGravity {
        case .fill:
            playerLayer?.videoGravity = .resizeAspectFill
        case .fit:
            playerLayer?.videoGravity = .resizeAspect
        case .stretch:
            playerLayer?.videoGravity = .resize
        }
        
        // Update display if needed
        updateDisplay()
    }

    func stop() {
        player?.pause()
        player = nil
        playerLayer?.player = nil
    }
}
