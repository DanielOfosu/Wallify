//
//  VideoFrameExtractor.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import Foundation
import AVFoundation
import AppKit

class VideoFrameExtractor {
    
    /// Extracts a still frame from a video at a specified time
    /// - Parameters:
    ///   - videoURL: The URL of the video file
    ///   - time: The time in seconds to extract the frame from (default: 1.0 second)
    /// - Returns: An NSImage of the extracted frame, or nil if extraction fails
    static func extractFrame(from videoURL: URL, at time: TimeInterval = 1.0) -> NSImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // Configure the image generator for better quality
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 1920, height: 1080) // HD resolution
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: time, preferredTimescale: 600), actualTime: nil)
            return NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        } catch {
            print("Error extracting frame from video: \(error)")
            return nil
        }
    }
    
    /// Extracts a still frame from a video and saves it to a temporary file
    /// - Parameters:
    ///   - videoURL: The URL of the video file
    ///   - time: The time in seconds to extract the frame from (default: 1.0 second)
    /// - Returns: The URL of the saved image file, or nil if extraction/saving fails
    static func extractAndSaveFrame(from videoURL: URL, at time: TimeInterval = 1.0) -> URL? {
        guard let image = extractFrame(from: videoURL, at: time) else {
            return nil
        }
        
        // Create a temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "wallify_frame_\(UUID().uuidString).jpg"
        let tempURL = tempDir.appendingPathComponent(fileName)
        
        // Convert NSImage to JPEG data
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [:]) else {
            print("Error converting image to JPEG format")
            return nil
        }
        
        do {
            try jpegData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving extracted frame: \(error)")
            return nil
        }
    }
} 