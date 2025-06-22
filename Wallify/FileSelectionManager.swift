//
//  FileSelectionManager.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import AppKit
import Foundation

class FileSelectionManager {

    func selectVideoFile(completion: @escaping (URL?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.movie]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        openPanel.begin { response in
            guard response == .OK, let selectedUrl = openPanel.urls.first else {
                completion(nil)
                return
            }
            
            do {
                let wallpapersDir = try self.getWallpapersDirectory()
                let destinationUrl = wallpapersDir.appendingPathComponent(selectedUrl.lastPathComponent)

                // If a file with the same name already exists, you might want to handle it,
                // for example, by removing the old one or creating a unique name.
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }

                try FileManager.default.copyItem(at: selectedUrl, to: destinationUrl)
                RecentWallpapersManager.shared.addWallpaper(destinationUrl)
                completion(destinationUrl)
            } catch {
                print("Error handling file: \(error)")
                completion(nil)
            }
        }
    }

    private func getWallpapersDirectory() throws -> URL {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileSelectionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find Application Support directory."])
        }

        // Use the bundle identifier to create a unique directory for the app.
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.yourcompany.Wallify"
        let appDirectoryURL = appSupportURL.appendingPathComponent(bundleIdentifier)
        let wallpapersDirectoryURL = appDirectoryURL.appendingPathComponent("Wallpapers")

        // Create the directory if it doesn't exist.
        if !FileManager.default.fileExists(atPath: wallpapersDirectoryURL.path) {
            try FileManager.default.createDirectory(at: wallpapersDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }

        return wallpapersDirectoryURL
    }
}
