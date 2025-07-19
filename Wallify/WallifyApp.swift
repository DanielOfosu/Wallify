//
//  WallifyApp.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI
import AppKit

// MARK: - Custom View Modifier for True Black Background
struct TrueBlackBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        Color.black
                    } else {
                        Color(NSColor.windowBackgroundColor)
                    }
                }
            )
    }
}

// MARK: - Custom View Modifier for True Black Form Background
struct TrueBlackFormBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        Color.black
                    } else {
                        Color(NSColor.controlBackgroundColor)
                    }
                }
            )
    }
}

extension View {
    func trueBlackBackground() -> some View {
        self.modifier(TrueBlackBackgroundModifier())
    }
    
    func trueBlackFormBackground() -> some View {
        self.modifier(TrueBlackFormBackgroundModifier())
    }
}

@main
struct WallifyApp: App {
    // Use the App Delegate to manage the app's lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // The main window for the application
        WindowGroup(id: "main-window") {
            ContentView()
                .environmentObject(appDelegate.wallpaperManager)
                .trueBlackBackground()
                .onAppear {
                    // Set window appearance to true black
                    if let window = NSApplication.shared.windows.first {
                        // Force dark appearance
                        window.appearance = NSAppearance(named: .darkAqua)
                        
                        // Set window background to black for content area
                        window.backgroundColor = NSColor.black
                        
                        // Make title bar transparent and extend content
                        window.titlebarAppearsTransparent = true
                        window.titleVisibility = .hidden
                        window.styleMask.insert(.fullSizeContentView)
                        
                        // Let the native toolbar handle the appearance
                        // Remove custom title bar styling for native toolbar
                    }
                }
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentSize)
        
        // A menu bar icon with controls
        MenuBarExtra {
            MenuContent()
        } label: {
            AdaptiveMenuBarIcon()
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
                // Bring existing window to front or create new one if none exists
                bringMainWindowToFront()
            }

            Divider()

            Button("Quit Wallify") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    private func bringMainWindowToFront() {
        // Find the main window and bring it to front
        if let mainWindow = NSApplication.shared.windows.first(where: { window in
            window.title == "Wallify" || window.identifier?.rawValue.contains("main-window") == true
        }) {
            // Window exists, bring it to front
            mainWindow.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        } else {
            // No window exists, create a new one
            openWindow(id: "main-window")
        }
    }
}

// Adaptive menu bar icon that uses SF Symbols
struct AdaptiveMenuBarIcon: View {
    var body: some View {
        Image(systemName: "photo.on.rectangle")
            .resizable()
            .frame(width: 16, height: 16)
    }
}
