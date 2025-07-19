import Foundation
import AVFoundation

struct VideoItem: Identifiable, Codable, Equatable {
    let id: UUID
    let url: URL
    let thumbnailURL: URL?
    let duration: TimeInterval
    let fileSize: Int64
    let dateAdded: Date
    let isFavorite: Bool
    let fileName: String
    
    init(url: URL, thumbnailURL: URL? = nil, duration: TimeInterval = 0, fileSize: Int64 = 0, isFavorite: Bool = false) {
        self.id = UUID()
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.fileSize = fileSize
        self.dateAdded = Date()
        self.isFavorite = isFavorite
        self.fileName = url.lastPathComponent
    }
    
    // Computed properties for UI
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    // Codable conformance for URL
    enum CodingKeys: String, CodingKey {
        case id, url, thumbnailURL, duration, fileSize, dateAdded, isFavorite, fileName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(string: urlString) ?? URL(fileURLWithPath: "")
        let thumbnailString = try container.decodeIfPresent(String.self, forKey: .thumbnailURL)
        thumbnailURL = thumbnailString.flatMap { URL(string: $0) }
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        fileSize = try container.decode(Int64.self, forKey: .fileSize)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        fileName = try container.decode(String.self, forKey: .fileName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encode(thumbnailURL?.absoluteString, forKey: .thumbnailURL)
        try container.encode(duration, forKey: .duration)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(fileName, forKey: .fileName)
    }
}

struct VideoMetadata {
    let duration: TimeInterval
    let fileSize: Int64
    let dimensions: CGSize?
} 