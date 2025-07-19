//
//  AppDelegate.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI
import Combine
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var wallpaperWindowController: WallpaperWindowController?
    let wallpaperManager = WallpaperManager()
    private var cancellables = Set<AnyCancellable>()
    private var originalWallpaperURL: URL?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set app appearance to dark mode
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        // Override system appearance for true black
        overrideSystemAppearance()
        
        // Store the original wallpaper URL before making any changes
        if let mainScreen = NSScreen.main {
            originalWallpaperURL = WallpaperSetter.getCurrentWallpaperURL(for: mainScreen)
        }
        
        // Create and set up the wallpaper window
        wallpaperWindowController = WallpaperWindowController()
        
        // Observe video URL changes to control the wallpaper
        wallpaperManager.$contentURL
            .sink { [weak self] url in
                if let url = url {
                    // Set the wallpaper first, then start the video
                    self?.setWallpaperFromVideo(url) { success in
                        if success {
                            // Add a small delay to ensure wallpaper is fully set before video starts
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                self?.wallpaperWindowController?.loadURL(url)
                            }
                        } else {
                            // If wallpaper setting fails, still start the video
                            self?.wallpaperWindowController?.loadURL(url)
                        }
                    }
                } else {
                    self?.wallpaperWindowController?.stop()
                    self?.restorePreviousWallpaper()
                }
            }
            .store(in: &cancellables)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // By returning false, we prevent the app from quitting when the main window is closed.
        // This allows the menu bar icon and the wallpaper to remain active.
        return false
    }
    
    private func overrideSystemAppearance() {
        // Try to override the title bar appearance globally
        if let window = NSApplication.shared.windows.first {
            // Set window to use custom appearance
            window.appearance = NSAppearance(named: .darkAqua)
            window.backgroundColor = NSColor.black
            
            // Make title bar transparent and extend content
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
            
            // More comprehensive title bar styling with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Try to override the title bar view directly
                if let titlebarView = window.standardWindowButton(.closeButton)?.superview?.superview {
                    titlebarView.wantsLayer = true
                    titlebarView.layer?.backgroundColor = NSColor.black.cgColor
                    
                    // Also try to override the parent view
                    if let parentView = titlebarView.superview {
                        parentView.wantsLayer = true
                        parentView.layer?.backgroundColor = NSColor.black.cgColor
                    }
                    
                    // Try to style the entire title bar container
                    if let titlebarContainer = window.standardWindowButton(.closeButton)?.superview?.superview?.superview {
                        titlebarContainer.wantsLayer = true
                        titlebarContainer.layer?.backgroundColor = NSColor.black.cgColor
                    }
                }
                
                // Additional styling for the window's content view
                if let contentView = window.contentView {
                    contentView.wantsLayer = true
                    contentView.layer?.backgroundColor = NSColor.black.cgColor
                }
                
                // Force window to redraw
                window.invalidateShadow()
                window.display()
            }
        }
    }
    
    // MARK: - Wallpaper Management
    
    /// Sets the macOS wallpaper to a still frame from the selected video
    /// - Parameters:
    ///   - videoURL: The URL of the video file
    ///   - completion: Completion handler called when wallpaper setting is complete
    private func setWallpaperFromVideo(_ videoURL: URL, completion: @escaping (Bool) -> Void) {
        // Run on background queue to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            // Extract a frame from the video (1 second into the video)
            guard let frameURL = VideoFrameExtractor.extractAndSaveFrame(from: videoURL, at: 1.0) else {
                print("Failed to extract frame from video: \(videoURL.lastPathComponent)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Set the wallpaper on the main queue
            DispatchQueue.main.async {
                let settings = SettingsManager.shared
                let targetDisplayID = settings.selectedDisplayID
                
                // Set wallpaper for the target display
                let success = WallpaperSetter.setWallpaper(from: frameURL, forDisplayID: targetDisplayID)
                
                if success {
                    print("Successfully set wallpaper from video frame: \(videoURL.lastPathComponent)")
                } else {
                    print("Failed to set wallpaper from video frame: \(videoURL.lastPathComponent)")
                }
                
                // Clean up the temporary frame file after a delay
                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 5.0) {
                    try? FileManager.default.removeItem(at: frameURL)
                }
                
                // Add a small delay to ensure proper ordering when switching quickly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    completion(success)
                }
            }
        }
    }
    
    /// Restores the original wallpaper when video wallpaper is stopped
    private func restorePreviousWallpaper() {
        // Use the original wallpaper URL (from before any video wallpapers were set)
        guard let originalURL = originalWallpaperURL else {
            print("No original wallpaper to restore")
            return
        }
        
        // Run on background queue to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            let success = WallpaperSetter.restoreWallpaper(from: originalURL)
            
            DispatchQueue.main.async {
                if success {
                    print("Successfully restored original wallpaper")
                } else {
                    print("Failed to restore original wallpaper")
                }
            }
        }
    }
} 