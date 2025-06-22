import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var videoQuality: Double {
        didSet {
            UserDefaults.standard.set(videoQuality, forKey: "videoQuality")
        }
    }

    private init() {
        self.videoQuality = UserDefaults.standard.double(forKey: "videoQuality")

        if self.videoQuality == 0 {
            self.videoQuality = 0.5 // Default value
        }
    }
} 