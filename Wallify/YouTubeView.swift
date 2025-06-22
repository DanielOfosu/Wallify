//
//  YouTubeView.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI

struct YouTubeView: View {
    @EnvironmentObject var wallpaperManager: WallpaperManager
    @State private var youtubeUrl: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.tv")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("YouTube Wallpaper")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter a YouTube video URL below to set it as your wallpaper. This feature requires an active internet connection.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter YouTube URL", text: $youtubeUrl)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 400)
            
            Button("Set YouTube Wallpaper") {
                if let videoID = extractYouTubeVideoID(from: youtubeUrl) {
                    let embedURL = URL(string: "https://www.youtube.com/embed/\(videoID)?autoplay=1&loop=1&playlist=\(videoID)&controls=0&showinfo=0&autohide=1&modestbranding=1")
                    wallpaperManager.contentURL = embedURL
                } else {
                    // TODO: Show an error to the user
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(youtubeUrl.isEmpty)
            
            Spacer()
        }
        .padding()
    }

    private func extractYouTubeVideoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        // Standard URL: https://www.youtube.com/watch?v=VIDEO_ID
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                if item.name == "v" {
                    return item.value
                }
            }
        }
        
        // Shortened URL: https://youtu.be/VIDEO_ID
        if url.host == "youtu.be" {
            return url.lastPathComponent
        }
        
        return nil
    }
}

#Preview {
    YouTubeView()
        .environmentObject(WallpaperManager())
} 