import Foundation
import Combine

class VideoLibraryManager: ObservableObject {
    @Published var videos: [VideoItem] = []
    @Published var selectedVideo: VideoItem?
    @Published var currentPage: Int = 0
    
    let itemsPerPage: Int = 8  // 2x4 grid
    let maxVideos: Int = 100   // Increased from 5
    
    private let saveKey = "videoLibrary"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadVideos()
        setupPublishers()
    }
    
    // MARK: - Pagination
    
    var totalPages: Int {
        return max(1, (videos.count + itemsPerPage - 1) / itemsPerPage)
    }
    
    var hasNextPage: Bool {
        return currentPage < totalPages - 1
    }
    
    var hasPreviousPage: Bool {
        return currentPage > 0
    }
    
    func nextPage() {
        if hasNextPage {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if hasPreviousPage {
            currentPage -= 1
        }
    }
    
    func videosForCurrentPage() -> [VideoItem] {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, videos.count)
        return Array(videos[startIndex..<endIndex])
    }
    
    // MARK: - Video Management
    
    func addVideo(_ url: URL) {
        // Check if video already exists
        if videos.contains(where: { $0.url == url }) {
            return
        }
        
        // Create initial video item
        let videoItem = VideoItem(url: url)
        videos.insert(videoItem, at: 0)
        
        // Extract metadata asynchronously
        Task {
            if let metadata = await VideoMetadataExtractor.extractMetadata(from: url) {
                await MainActor.run {
                    self.updateVideoMetadata(for: videoItem.id, metadata: metadata)
                }
            }
            
            // Generate and save thumbnail
            if let thumbnail = await VideoMetadataExtractor.generateThumbnail(for: url) {
                let thumbnailURL = VideoMetadataExtractor.saveThumbnail(thumbnail, for: url)
                await MainActor.run {
                    self.updateVideoThumbnail(for: videoItem.id, thumbnailURL: thumbnailURL)
                }
            }
        }
        
        // Limit the number of videos
        if videos.count > maxVideos {
            let removedVideos = videos.suffix(videos.count - maxVideos)
            videos = Array(videos.prefix(maxVideos))
            
            // Delete old files and thumbnails
            for video in removedVideos {
                deleteVideoFile(video)
            }
        }
        
        saveVideos()
    }
    
    func addNewVideoAction() {
        let fileSelectionManager = FileSelectionManager()
        fileSelectionManager.selectVideoFile { url in
            if let url = url {
                DispatchQueue.main.async {
                    self.addVideo(url)
                }
            }
        }
    }
    
    func removeVideo(_ video: VideoItem) {
        videos.removeAll { $0.id == video.id }
        
        // If we removed the selected video, select the first available
        if selectedVideo?.id == video.id {
            selectedVideo = videos.first
        }
        
        // Delete the file and thumbnail
        deleteVideoFile(video)
        
        // Adjust current page if needed
        if currentPage >= totalPages && totalPages > 0 {
            currentPage = totalPages - 1
        }
        
        saveVideos()
    }
    
    func selectVideo(_ video: VideoItem) {
        selectedVideo = video
    }
    
    func toggleFavorite(_ video: VideoItem) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index] = VideoItem(
                url: video.url,
                thumbnailURL: video.thumbnailURL,
                duration: video.duration,
                fileSize: video.fileSize,
                isFavorite: !video.isFavorite
            )
            saveVideos()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateVideoMetadata(for id: UUID, metadata: VideoMetadata) {
        if let index = videos.firstIndex(where: { $0.id == id }) {
            let video = videos[index]
            videos[index] = VideoItem(
                url: video.url,
                thumbnailURL: video.thumbnailURL,
                duration: metadata.duration,
                fileSize: metadata.fileSize,
                isFavorite: video.isFavorite
            )
            saveVideos()
        }
    }
    
    private func updateVideoThumbnail(for id: UUID, thumbnailURL: URL?) {
        if let index = videos.firstIndex(where: { $0.id == id }) {
            let video = videos[index]
            videos[index] = VideoItem(
                url: video.url,
                thumbnailURL: thumbnailURL,
                duration: video.duration,
                fileSize: video.fileSize,
                isFavorite: video.isFavorite
            )
            saveVideos()
        }
    }
    
    private func deleteVideoFile(_ video: VideoItem) {
        // Delete video file
        do {
            if FileManager.default.fileExists(atPath: video.url.path) {
                try FileManager.default.removeItem(at: video.url)
            }
        } catch {
            print("Error deleting video file: \(error)")
        }
        
        // Delete thumbnail
        if let thumbnailURL = video.thumbnailURL {
            do {
                if FileManager.default.fileExists(atPath: thumbnailURL.path) {
                    try FileManager.default.removeItem(at: thumbnailURL)
                }
            } catch {
                print("Error deleting thumbnail: \(error)")
            }
        }
    }
    
    private func setupPublishers() {
        // Auto-save when videos change
        $videos
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveVideos()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Persistence
    
    private func saveVideos() {
        do {
            let data = try JSONEncoder().encode(videos)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Error saving videos: \(error)")
        }
    }
    
    private func loadVideos() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            // Migrate from old RecentWallpapersManager if needed
            migrateFromRecentWallpapers()
            return
        }
        
        do {
            videos = try JSONDecoder().decode([VideoItem].self, from: data)
            selectedVideo = videos.first
        } catch {
            print("Error loading videos: \(error)")
            videos = []
        }
    }
    
    private func migrateFromRecentWallpapers() {
        let recentURLs = RecentWallpapersManager.shared.recentWallpapers
        for url in recentURLs {
            addVideo(url)
        }
    }
} 