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
            
            // For sandboxed apps, copy the file to a temporary directory
            // to ensure we have persistent access.
            let tempDir = FileManager.default.temporaryDirectory
            let tempUrl = tempDir.appendingPathComponent(selectedUrl.lastPathComponent)
            
            do {
                // If a file already exists, remove it.
                if FileManager.default.fileExists(atPath: tempUrl.path) {
                    try FileManager.default.removeItem(at: tempUrl)
                }
                
                try FileManager.default.copyItem(at: selectedUrl, to: tempUrl)
                completion(tempUrl)
            } catch {
                print("Error copying file: \(error)")
                completion(nil)
            }
        }
    }
}
