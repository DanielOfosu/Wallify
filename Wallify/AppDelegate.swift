//
//  AppDelegate.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var wallpaperWindowController: WallpaperWindowController?
    let wallpaperManager = WallpaperManager()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create and set up the wallpaper window
        wallpaperWindowController = WallpaperWindowController()
        wallpaperWindowController?.setupContentView()
        
        // Observe video URL changes to control the wallpaper
        wallpaperManager.$contentURL
            .sink { [weak self] url in
                if let url = url {
                    self?.wallpaperWindowController?.loadURL(url)
                } else {
                    self?.wallpaperWindowController?.stop()
                }
            }
            .store(in: &cancellables)
    }
} 