import Foundation

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

    private init() {
        self.videoQuality = UserDefaults.standard.object(forKey: "videoQuality") as? Double ?? 0.8
        self.videoGravity = VideoGravity(rawValue: UserDefaults.standard.string(forKey: "videoGravity") ?? "") ?? .fill
        self.showSystemStats = UserDefaults.standard.bool(forKey: "showSystemStats")
        self.isMuted = UserDefaults.standard.bool(forKey: "isMuted")
    }
} 