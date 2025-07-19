//
//  WallpaperSetter.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import Foundation
import AppKit

class WallpaperSetter {
    
    /// Sets the wallpaper for all screens using an image file
    /// - Parameter imageURL: The URL of the image file to set as wallpaper
    /// - Returns: True if successful, false otherwise
    static func setWallpaper(from imageURL: URL) -> Bool {
        do {
            // Use NSWorkspace to set the wallpaper for all screens
            try NSWorkspace.shared.setDesktopImageURL(imageURL, for: NSScreen.main ?? NSScreen.screens.first ?? NSScreen.main!)
            
            // For multiple screens, set the same wallpaper for all
            for screen in NSScreen.screens {
                if screen != NSScreen.main {
                    try NSWorkspace.shared.setDesktopImageURL(imageURL, for: screen)
                }
            }
            
            print("Successfully set wallpaper from: \(imageURL.lastPathComponent)")
            return true
        } catch {
            print("Error setting wallpaper: \(error)")
            return false
        }
    }
    
    /// Sets the wallpaper for a specific screen
    /// - Parameters:
    ///   - imageURL: The URL of the image file to set as wallpaper
    ///   - screen: The screen to set the wallpaper for
    /// - Returns: True if successful, false otherwise
    static func setWallpaper(from imageURL: URL, for screen: NSScreen) -> Bool {
        do {
            try NSWorkspace.shared.setDesktopImageURL(imageURL, for: screen)
            print("Successfully set wallpaper for screen: \(screen.localizedName)")
            return true
        } catch {
            print("Error setting wallpaper for screen \(screen.localizedName): \(error)")
            return false
        }
    }
    
    /// Sets the wallpaper for the screen that matches the specified display ID
    /// - Parameters:
    ///   - imageURL: The URL of the image file to set as wallpaper
    ///   - displayID: The display ID to match
    /// - Returns: True if successful, false otherwise
    static func setWallpaper(from imageURL: URL, forDisplayID displayID: CGDirectDisplayID) -> Bool {
        // Find the screen for the specified display ID
        for screen in NSScreen.screens {
            if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
               screenNumber == displayID {
                return setWallpaper(from: imageURL, for: screen)
            }
        }
        
        // If target screen not found, set for main screen as fallback
        print("Target display not found, setting wallpaper for main screen")
        return setWallpaper(from: imageURL, for: NSScreen.main ?? NSScreen.screens.first ?? NSScreen.main!)
    }
    
    /// Gets the current wallpaper URL for a screen
    /// - Parameter screen: The screen to get the wallpaper for
    /// - Returns: The URL of the current wallpaper, or nil if not available
    static func getCurrentWallpaperURL(for screen: NSScreen) -> URL? {
        return NSWorkspace.shared.desktopImageURL(for: screen)
    }
    
    /// Restores the previous wallpaper if available
    /// - Parameter previousURL: The URL of the previous wallpaper
    /// - Returns: True if successful, false otherwise
    static func restoreWallpaper(from previousURL: URL?) -> Bool {
        guard let previousURL = previousURL else {
            print("No previous wallpaper URL available")
            return false
        }
        
        return setWallpaper(from: previousURL)
    }
} 