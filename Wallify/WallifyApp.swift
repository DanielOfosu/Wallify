//
//  WallifyApp.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI

@main
struct WallifyApp: App {
    // Use the App Delegate to manage the app's lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // The main window for the application
        WindowGroup(id: "main-window") {
            ContentView()
                .environmentObject(appDelegate.wallpaperManager)
        }
        
        // A menu bar icon with controls
        MenuBarExtra("Wallify", systemImage: "play.circle") {
            MenuContent()
        }
        .menuBarExtraStyle(.menu)
    }
}

// A view that defines the content of the menu bar menu
struct MenuContent: View {
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Group {
            Button("Configure Wallpaper...") {
                // This opens the main WindowGroup
                openWindow(id: "main-window")
            }

            Divider()

            Button("Quit Wallify") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
