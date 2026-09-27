import Foundation

/// Represents a single image asset of an emote in a specific scale/resolution.
public struct EmoteImage: Identifiable, Hashable, Codable, Sendable {
    public var id: String { url.absoluteString }
    public let url: URL
    public let mimeType: String
    public let scale: Int
    public let width: Int?
    public let height: Int?
    public let fileSize: Int?
    
    public init(
        url: URL,
        mimeType: String,
        scale: Int,
        width: Int? = nil,
        height: Int? = nil,
        fileSize: Int? = nil
    ) {
        self.url = url
        self.mimeType = mimeType
        self.scale = scale
        self.width = width
        self.height = height
        self.fileSize = fileSize
    }
}
