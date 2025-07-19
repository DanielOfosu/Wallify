import Foundation
import AVFoundation
import AppKit

class VideoMetadataExtractor {
    
    static func extractMetadata(from url: URL) async -> VideoMetadata? {
        let asset = AVAsset(url: url)
        
        // Get duration
        let duration = try? await asset.load(.duration)
        let durationSeconds = duration?.seconds ?? 0
        
        // Get file size
        let fileSize = getFileSize(for: url)
        
        // Get dimensions
        let tracks = try? await asset.loadTracks(withMediaType: .video)
        let videoTrack = tracks?.first
        let dimensions = try? await videoTrack?.load(.naturalSize)
        
        let metadata = VideoMetadata(
            duration: durationSeconds,
            fileSize: fileSize,
            dimensions: dimensions
        )
        
        return metadata
    }
    
    static func generateThumbnail(for url: URL) async -> NSImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 320, height: 240) // 2x for retina
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            return nsImage
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func getFileSize(for url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
            return 0
        }
    }
    
    static func saveThumbnail(_ image: NSImage, for videoURL: URL) -> URL? {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        let thumbnailURL = getThumbnailURL(for: videoURL)
        
        do {
            try pngData.write(to: thumbnailURL)
            return thumbnailURL
        } catch {
            print("Error saving thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func getThumbnailURL(for videoURL: URL) -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "com.wallify.app"
        let thumbnailsDir = appSupport.appendingPathComponent(bundleID).appendingPathComponent("Thumbnails")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: thumbnailsDir, withIntermediateDirectories: true)
        
        let fileName = videoURL.lastPathComponent.replacingOccurrences(of: ".", with: "_") + "_thumb.png"
        return thumbnailsDir.appendingPathComponent(fileName)
    }
} 