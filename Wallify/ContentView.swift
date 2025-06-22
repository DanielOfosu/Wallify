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
    @State private var isMuted = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Top Section: File Selection
            HStack(spacing: 15) {
                Image(systemName: "film")
                    .font(.system(size: 40))
                    .frame(width: 80, height: 60)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        fileSelectionManager.selectVideoFile { url in
                            wallpaperManager.contentURL = url
                        }
                    } label: {
                        Label("Select Video", systemImage: "folder")
                    }
                    
                    Text(wallpaperManager.contentURL?.lastPathComponent ?? "No file selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            .padding(.bottom)

            // Preview Section
            Text("Preview")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let player = wallpaperManager.contentURL.map({ AVPlayer(url: $0) }) {
                VideoPlayerView(player: player)
                    .frame(minHeight: 200, maxHeight: .infinity)
                    .background(Color.black)
                    .cornerRadius(8)
            } else {
                ZStack {
                    Color.black
                        .cornerRadius(8)
                    Text("Select a video to see a preview")
                        .foregroundColor(.secondary)
                }
            }
            
            // Bottom Controls
            HStack {
                Button {
                    // The wallpaper is already set automatically by the manager
                } label: {
                    Label("Set Wallpaper", systemImage: "display")
                }
                .buttonStyle(.borderedProminent)
                .disabled(wallpaperManager.contentURL == nil)
                
                Picker("Aspect Fill", selection: .constant("Aspect Fill")) {
                    Text("Aspect Fill").tag("Aspect Fill")
                    Text("Aspect Fit").tag("Aspect Fit")
                    Text("Stretch").tag("Stretch")
                }
                .pickerStyle(.menu)
                .frame(width: 140)

                Picker("All Monitors", selection: .constant("All Monitors")) {
                    Text("All Monitors").tag("All Monitors")
                }
                .pickerStyle(.menu)
                .frame(width: 140)
                
                Spacer()
                
                Toggle("Mute", isOn: $isMuted)
            }
        }
        .padding()
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
        .environmentObject(WallpaperManager())
}

#Preview("Video selected") {
    let manager = WallpaperManager()
    // Use a placeholder URL to test the UI without needing a real file
    manager.contentURL = URL(fileURLWithPath: "/path/to/your/awesome_wallpaper.mp4")
    
    return ContentView()
        .environmentObject(manager)
}
