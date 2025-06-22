import Foundation

class RecentWallpapersManager: ObservableObject {
    static let shared = RecentWallpapersManager()
    private let key = "recentWallpapers"
    private let maxCount = 5

    @Published var recentWallpapers: [URL] = []

    private init() {
        loadWallpapers()
    }

    func addWallpaper(_ url: URL) {
        // Avoid adding duplicates
        if recentWallpapers.contains(url) {
            // Move it to the front
            recentWallpapers.removeAll { $0 == url }
        }

        recentWallpapers.insert(url, at: 0)

        // Limit the number of recent items and delete the oldest file if needed
        if recentWallpapers.count > maxCount {
            let oldestWallpaper = recentWallpapers.removeLast()
            deleteWallpaperFile(at: oldestWallpaper)
        }

        saveWallpapers()
    }

    private func saveWallpapers() {
        let urls = recentWallpapers.map { $0.absoluteString }
        UserDefaults.standard.set(urls, forKey: key)
    }

    private func loadWallpapers() {
        guard let urls = UserDefaults.standard.array(forKey: key) as? [String] else { return }
        recentWallpapers = urls.compactMap { URL(string: $0) }
    }

    private func deleteWallpaperFile(at url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("Deleted old wallpaper: \(url.lastPathComponent)")
            }
        } catch {
            print("Error deleting wallpaper file: \(error)")
        }
    }
} 