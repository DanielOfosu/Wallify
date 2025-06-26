//
//  ContentView.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI
import AVKit

// MARK: - Main Content View with Navigation
struct ContentView: View {
    @State private var selectedCategory: Category? = .video
    @EnvironmentObject var wallpaperManager: WallpaperManager

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory)
        } detail: {
            DetailView(selectedCategory: $selectedCategory)
                .environmentObject(wallpaperManager)
        }
        .navigationTitle("Wallify")
        .frame(minWidth: 800, minHeight: 600)
        .accessibilityIdentifier("settings_view")
    }
}

// MARK: - Sidebar Navigation
struct SidebarView: View {
    @Binding var selectedCategory: Category?

    var body: some View {
        List(Category.allCases, selection: $selectedCategory) { category in
            NavigationLink(value: category) {
                Label(category.rawValue, systemImage: category.icon)
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - Detail View Router
struct DetailView: View {
    @Binding var selectedCategory: Category?
    @EnvironmentObject var wallpaperManager: WallpaperManager

    var body: some View {
        switch selectedCategory {
        case .video:
            VideoSettingsView()
                .environmentObject(wallpaperManager)
        case .youtube:
            YouTubeView()
        case .web:
            WebView()
        case .preference:
            PreferenceView()
        case .about:
            AboutView()
        case .none:
            Text("Select a category from the sidebar.")
                .font(.largeTitle)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Video Settings View
struct VideoSettingsView: View {
    @EnvironmentObject var wallpaperManager: WallpaperManager
    private let fileSelectionManager = FileSelectionManager()
    @StateObject private var recentWallpapersManager = RecentWallpapersManager.shared
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Video Wallpaper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Select New Video...", action: selectVideo)
            }

            if recentWallpapersManager.recentWallpapers.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "film.fill")
                        .font(.system(size: 50))
                        .padding(.bottom, 10)
                    Text("No Recent Videos")
                        .font(.title3)
                    Text("Drop a video file here to get started.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RecentWallpapersView(
                    recentWallpapers: recentWallpapersManager.recentWallpapers,
                    onSelect: { url in
                        wallpaperManager.setContentURL(url)
                    }
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isTargeted ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(12)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func selectVideo() {
        fileSelectionManager.selectVideoFile { url in
            if let url = url {
                wallpaperManager.setContentURL(url)
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            if let url = url {
                DispatchQueue.main.async {
                    wallpaperManager.setContentURL(url)
                }
            }
        }
        return true
    }
}

// MARK: - Recent Wallpapers View
struct RecentWallpapersView: View {
    let recentWallpapers: [URL]
    let onSelect: (URL) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 180))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(recentWallpapers, id: \.self) { url in
                    Button(action: { onSelect(url) }) {
                        VideoThumbnailView(url: url)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
        }
    }
}

// MARK: - Video Thumbnail View
struct VideoThumbnailView: View {
    let url: URL
    @State private var thumbnail: NSImage?

    var body: some View {
        VStack {
            if let thumbnail = thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 120)
                        .cornerRadius(8)
                    ProgressView()
                }
            }
            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .onAppear(perform: generateThumbnail)
    }

    private func generateThumbnail() {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                DispatchQueue.main.async {
                    self.thumbnail = nsImage
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - VideoPlayer compatibility
struct VideoPlayerView: NSViewRepresentable {
    var player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .inline
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}

// MARK: - Data Model for Sidebar
enum Category: String, CaseIterable, Identifiable {
    case video = "Video"
    case youtube = "YouTube"
    case web = "Web"
    case preference = "Preference"
    case about = "About"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .video: return "video"
        case .youtube: return "play.tv"
        case .web: return "safari"
        case .preference: return "gear"
        case .about: return "info.circle"
        }
    }
}

// MARK: - SwiftUI Preview
#Preview("No video selected") {
    ContentView()
        .environmentObject(WallpaperManager(workspaceManager: WorkspaceManager()))
}

#Preview("Video selected") {
    let manager = WallpaperManager(workspaceManager: WorkspaceManager())
    // Use a placeholder URL to test the UI without needing a real file
    manager.contentURL = URL(fileURLWithPath: "/path/to/your/awesome_wallpaper.mp4")
    
    return ContentView()
        .environmentObject(manager)
}
