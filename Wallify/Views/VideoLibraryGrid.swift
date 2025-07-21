import SwiftUI

struct VideoLibraryGrid: View {
    @ObservedObject var videoLibraryManager: VideoLibraryManager
    @EnvironmentObject var wallpaperManager: WallpaperManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Video Library")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Need new wallpapers button
                Button(action: {
                    if let url = URL(string: "https://www.pexels.com/search/videos/4k%20wallpapers/") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .font(.caption)
                        Text("Need new wallpapers?")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help("Browse 4K wallpapers on Pexels")
                
                // Page indicator
                if videoLibraryManager.totalPages > 1 {
                    Text("Page \(videoLibraryManager.currentPage + 1) of \(videoLibraryManager.totalPages)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Single row video library with horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Add New Video Card - always first (leftmost)
                    AddVideoLibraryItem(onAdd: {
                        videoLibraryManager.addNewVideoAction()
                    })
                    
                    // Existing video cards
                    ForEach(videoLibraryManager.videos) { video in
                        VideoLibraryItem(
                            video: video,
                            isSelected: videoLibraryManager.selectedVideo?.id == video.id,
                            onSelect: {
                                videoLibraryManager.selectVideo(video)
                                wallpaperManager.contentURL = video.url
                            },
                            onRemove: {
                                videoLibraryManager.removeVideo(video)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 180) // Fixed height for single row
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)
            
            // Empty state
            if videoLibraryManager.videos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Videos in Library")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Add your first video by dragging and dropping a video file here, or use the 'Add New Video' button above.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(height: 180)
            }
        }
        .padding()
        .trueBlackBackground()
    }
}

// Add New Video Card
struct AddVideoLibraryItem: View {
    let onAdd: () -> Void
    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(width: 160, height: 120)
                        .background(Color.secondary.opacity(0.05))
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.secondary)
                }
                Text("Add Video")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(Color.clear)
    }
}

// MARK: - Enhanced Video Library Grid with Search
struct EnhancedVideoLibraryGrid: View {
    @ObservedObject var videoLibraryManager: VideoLibraryManager
    @EnvironmentObject var wallpaperManager: WallpaperManager
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    var filteredVideos: [VideoItem] {
        var videos = videoLibraryManager.videos
        
        // Filter by search text
        if !searchText.isEmpty {
            videos = videos.filter { video in
                video.fileName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by favorites
        if showFavoritesOnly {
            videos = videos.filter { $0.isFavorite }
        }
        
        return videos
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search and filter controls
            HStack {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search videos...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                
                // Favorites toggle
                Button(action: { showFavoritesOnly.toggle() }) {
                    HStack {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundColor(showFavoritesOnly ? .red : .secondary)
                        Text("Favorites")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(showFavoritesOnly ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Sort options
                Menu {
                    Button("Date Added") { /* sort by date */ }
                    Button("Name") { /* sort by name */ }
                    Button("Duration") { /* sort by duration */ }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filteredVideos) { video in
                    VideoLibraryItem(
                        video: video,
                        isSelected: videoLibraryManager.selectedVideo?.id == video.id,
                        onSelect: {
                            videoLibraryManager.selectVideo(video)
                            wallpaperManager.contentURL = video.url
                        },
                        onRemove: {
                            videoLibraryManager.removeVideo(video)
                        }
                    )
                }
            }
            
            // Empty state for filtered results
            if filteredVideos.isEmpty && !videoLibraryManager.videos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Videos Found")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Try adjusting your search criteria or filters.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 280)
            }
        }
        .padding()
        .trueBlackBackground()
    }
}

// MARK: - Preview
struct VideoLibraryGrid_Previews: PreviewProvider {
    static var previews: some View {
        VideoLibraryGrid(videoLibraryManager: VideoLibraryManager())
            .environmentObject(WallpaperManager())
    }
} 