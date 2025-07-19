import SwiftUI
import AppKit

struct VideoLibraryItem: View {
    let video: VideoItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onRemove: (() -> Void)?
    
    @State private var thumbnail: NSImage?
    @State private var isLoadingThumbnail = true
    @State private var showContextMenu = false
    
    init(video: VideoItem, isSelected: Bool, onSelect: @escaping () -> Void, onRemove: (() -> Void)? = nil) {
        self.video = video
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onRemove = onRemove
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Thumbnail container
            ZStack {
                // Thumbnail or placeholder
                if let thumbnail = thumbnail {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 120)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(width: 160, height: 120)
                    
                    if isLoadingThumbnail {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "video.slash")
                            .font(.system(size: 30))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 3)
                        .frame(width: 160, height: 120)
                    
                    // Selection checkmark
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .background(Color.white)
                                .clipShape(Circle())
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                    .frame(width: 160, height: 120)
                }
                
                // Favorite indicator
                if video.isFavorite {
                    VStack {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 16))
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .padding(4)
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: 160, height: 120)
                }
                
                // Duration overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(video.formattedDuration)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                            .padding(4)
                    }
                }
                .frame(width: 160, height: 120)
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            
            // Video info
            VStack(alignment: .leading, spacing: 2) {
                // Only show the date below the image
                Text(video.dateAdded, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 160, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onAppear {
            loadThumbnail()
        }
        .contextMenu {
            Button(action: onSelect) {
                Label("Select", systemImage: "play.fill")
            }
            
            Button(action: {
                // Toggle favorite - this would need to be passed from parent
            }) {
                Label(video.isFavorite ? "Remove from Favorites" : "Add to Favorites", 
                      systemImage: video.isFavorite ? "heart.slash" : "heart")
            }
            
            if let onRemove = onRemove {
                Divider()
                
                Button(role: .destructive, action: onRemove) {
                    Label("Remove from Library", systemImage: "trash")
                }
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
        .trueBlackBackground()
    }
    
    private func loadThumbnail() {
        isLoadingThumbnail = true
        
        // First try to load from saved thumbnail URL
        if let thumbnailURL = video.thumbnailURL {
            if let image = NSImage(contentsOf: thumbnailURL) {
                self.thumbnail = image
                self.isLoadingThumbnail = false
                return
            }
        }
        
        // Generate thumbnail asynchronously
        Task {
            if let thumbnail = await VideoMetadataExtractor.generateThumbnail(for: video.url) {
                let thumbnailURL = VideoMetadataExtractor.saveThumbnail(thumbnail, for: video.url)
                
                await MainActor.run {
                    self.thumbnail = thumbnail
                    self.isLoadingThumbnail = false
                }
            } else {
                await MainActor.run {
                    self.isLoadingThumbnail = false
                }
            }
        }
    }
}

// MARK: - Preview
struct VideoLibraryItem_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            VideoLibraryItem(
                video: VideoItem(url: URL(fileURLWithPath: "/path/to/video.mp4")),
                isSelected: true,
                onSelect: {}
            )
            
            VideoLibraryItem(
                video: VideoItem(url: URL(fileURLWithPath: "/path/to/another.mp4")),
                isSelected: false,
                onSelect: {}
            )
        }
        .padding()
    }
} 