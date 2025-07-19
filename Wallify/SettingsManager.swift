import Foundation
import AppKit

enum VideoGravity: String, CaseIterable, Identifiable {
    case fill = "Fill"
    case fit = "Fit"
    case stretch = "Stretch"
    
    var id: String { self.rawValue }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var videoQuality: Double {
        didSet {
            UserDefaults.standard.set(videoQuality, forKey: "videoQuality")
        }
    }
    
    @Published var videoGravity: VideoGravity {
        didSet {
            UserDefaults.standard.set(videoGravity.rawValue, forKey: "videoGravity")
        }
    }

    @Published var showSystemStats: Bool {
        didSet {
            UserDefaults.standard.set(showSystemStats, forKey: "showSystemStats")
        }
    }

    @Published var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: "isMuted")
        }
    }
    
    @Published var playbackSpeed: Double {
        didSet {
            UserDefaults.standard.set(playbackSpeed, forKey: "playbackSpeed")
        }
    }
    
    @Published var selectedDisplayID: CGDirectDisplayID {
        didSet {
            UserDefaults.standard.set(selectedDisplayID, forKey: "selectedDisplayID")
        }
    }

    private init() {
        self.videoQuality = UserDefaults.standard.object(forKey: "videoQuality") as? Double ?? 0.8
        self.videoGravity = VideoGravity(rawValue: UserDefaults.standard.string(forKey: "videoGravity") ?? "") ?? .fill
        self.showSystemStats = UserDefaults.standard.bool(forKey: "showSystemStats")
        self.isMuted = UserDefaults.standard.bool(forKey: "isMuted")
        self.playbackSpeed = UserDefaults.standard.object(forKey: "playbackSpeed") as? Double ?? 1.0
        self.selectedDisplayID = CGDirectDisplayID(UserDefaults.standard.integer(forKey: "selectedDisplayID"))
        
        // If no display is selected, default to main display
        if self.selectedDisplayID == 0 {
            self.selectedDisplayID = CGMainDisplayID()
        }
    }
    
    // Helper method to get available displays
    var availableDisplays: [(id: CGDirectDisplayID, name: String)] {
        var displays: [(id: CGDirectDisplayID, name: String)] = []
        
        let maxDisplays: UInt32 = 16
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0
        
        let result = CGGetActiveDisplayList(maxDisplays, &displayIDs, &displayCount)
        
        if result == .success {
            for i in 0..<displayCount {
                let displayID = displayIDs[Int(i)]
                let displayName = getDisplayName(for: displayID)
                displays.append((id: displayID, name: displayName))
            }
        }
        
        return displays
    }
    
    private func getDisplayName(for displayID: CGDirectDisplayID) -> String {
        if displayID == CGMainDisplayID() {
            return "Main Display"
        }
        
        // Try to get display name from NSScreen
        for screen in NSScreen.screens {
            if screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID == displayID {
                return screen.localizedName
            }
        }
        
        return "Display \(displayID)"
    }
} 