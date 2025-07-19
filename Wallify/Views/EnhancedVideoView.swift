import SwiftUI
import UniformTypeIdentifiers

struct EnhancedVideoView: View {
    @StateObject private var videoLibraryManager = VideoLibraryManager()
    @EnvironmentObject var wallpaperManager: WallpaperManager
    @State private var isTargeted = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top section: Preview + Controls
                HStack(spacing: 20) {
                    // Live video preview (takes up less space)
                    VideoPreviewView(videoItem: videoLibraryManager.selectedVideo)
                        .frame(minWidth: 350, maxWidth: .infinity)
                        .layoutPriority(1)
                    
                    // Video controls (takes up more space, positioned more to the left)
                    VideoControlsPanel()
                        .frame(minWidth: 250, maxWidth: 400)
                        .frame(width: min(400, geometry.size.width * 0.4))
                        .layoutPriority(2)
                }
                .frame(height: 400)
                .padding()
                
                Divider()
                
                // Bottom section: Video library
                VideoLibraryGrid(videoLibraryManager: videoLibraryManager)
                    .frame(height: 320)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        .onDrop(of: [.movie, .fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onAppear {
            loadVideoLibrary()
        }
        .onChange(of: wallpaperManager.contentURL) { newURL in
            // When wallpaper manager gets a new URL, add it to the library
            if let url = newURL {
                videoLibraryManager.addVideo(url)
                // Find and select the video in the library
                if let video = videoLibraryManager.videos.first(where: { $0.url == url }) {
                    videoLibraryManager.selectVideo(video)
                }
            }
        }
        .trueBlackBackground()

    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handledCount = 0
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                _ = provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            self.videoLibraryManager.addVideo(url)
                            self.wallpaperManager.contentURL = url
                            handledCount += 1
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                _ = provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        // Check if it's a video file
                        let pathExtension = url.pathExtension.lowercased()
                        let videoExtensions = ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v"]
                        
                        if videoExtensions.contains(pathExtension) {
                            DispatchQueue.main.async {
                                self.videoLibraryManager.addVideo(url)
                                self.wallpaperManager.contentURL = url
                                handledCount += 1
                            }
                        }
                    }
                }
            }
        }
        
        return handledCount > 0
    }
    
    private func loadVideoLibrary() {
        // Load existing videos from RecentWallpapersManager if this is the first time
        if videoLibraryManager.videos.isEmpty {
            let recentURLs = RecentWallpapersManager.shared.recentWallpapers
            for url in recentURLs {
                videoLibraryManager.addVideo(url)
            }
        }
        
        // Select the currently active video if any
        if let currentURL = wallpaperManager.contentURL,
           let video = videoLibraryManager.videos.first(where: { $0.url == currentURL }) {
            videoLibraryManager.selectVideo(video)
        }
    }
}

// MARK: - Enhanced Video View with Advanced Features
struct AdvancedEnhancedVideoView: View {
    @StateObject private var videoLibraryManager = VideoLibraryManager()
    @EnvironmentObject var wallpaperManager: WallpaperManager
    @State private var isTargeted = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section: Preview + Controls
            HStack(spacing: 20) {
                // Live video preview (60% width)
                VideoPreviewView(videoItem: videoLibraryManager.selectedVideo)
                    .frame(maxWidth: .infinity)
                
                // Video controls (40% width)
                VideoControlsPanel()
                    .frame(width: 300)
            }
            .frame(height: 400)
            .padding()
            
            Divider()
            
            // Bottom section: Tabbed interface
            VStack(spacing: 0) {
                // Tab bar
                HStack(spacing: 0) {
                    TabButton(title: "Library", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "Favorites", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "Recently Added", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Divider()
                
                // Tab content
                TabView(selection: $selectedTab) {
                    VideoLibraryGrid(videoLibraryManager: videoLibraryManager)
                        .tag(0)
                    
                    FavoritesView(videoLibraryManager: videoLibraryManager)
                        .tag(1)
                    
                    RecentlyAddedView(videoLibraryManager: videoLibraryManager)
                        .tag(2)
                }
                .tabViewStyle(.automatic)
                .frame(height: 320)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        .onDrop(of: [.movie, .fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onAppear {
            loadVideoLibrary()
        }
        .trueBlackBackground()
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        // Same implementation as EnhancedVideoView
        var handledCount = 0
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                _ = provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            self.videoLibraryManager.addVideo(url)
                            self.wallpaperManager.contentURL = url
                            handledCount += 1
                        }
                    }
                }
            }
        }
        
        return handledCount > 0
    }
    
    private func loadVideoLibrary() {
        if videoLibraryManager.videos.isEmpty {
            let recentURLs = RecentWallpapersManager.shared.recentWallpapers
            for url in recentURLs {
                videoLibraryManager.addVideo(url)
            }
        }
        
        if let currentURL = wallpaperManager.contentURL,
           let video = videoLibraryManager.videos.first(where: { $0.url == currentURL }) {
            videoLibraryManager.selectVideo(video)
        }
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .primary : .secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Rectangle()
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                )
        }
        .buttonStyle(.borderless)
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @ObservedObject var videoLibraryManager: VideoLibraryManager
    
    var body: some View {
        VStack {
            Text("Favorites")
                .font(.title)
                .padding()
            Spacer()
        }
        .trueBlackBackground()
    }
}

// MARK: - Recently Added View
struct RecentlyAddedView: View {
    @ObservedObject var videoLibraryManager: VideoLibraryManager
    
    var body: some View {
        VStack {
            Text("Recently Added")
                .font(.title)
                .padding()
            Spacer()
        }
        .trueBlackBackground()
    }
}

// MARK: - Preview
struct EnhancedVideoView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedVideoView()
            .environmentObject(WallpaperManager())
    }
} 