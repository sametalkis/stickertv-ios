import Foundation

/// Core domain entity representing an emote from any provider (7TV, BTTV, FFZ, etc.).
public struct EmoteItem: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let sourceId: String
    public let name: String
    public let isAnimated: Bool
    public let aspectRatio: Double
    public let tags: [String]
    public let images: [EmoteImage]
    public let ownerName: String?
    
    public init(
        id: String,
        sourceId: String,
        name: String,
        isAnimated: Bool,
        aspectRatio: Double = 1.0,
        tags: [String] = [],
        images: [EmoteImage] = [],
        ownerName: String? = nil
    ) {
        self.id = id
        self.sourceId = sourceId
        self.name = name
        self.isAnimated = isAnimated
        self.aspectRatio = aspectRatio
        self.tags = tags
        self.images = images
        self.ownerName = ownerName
    }
    
    /// Finds the best image URL for sticker generation (prefers 3x or 2x for optimal 512x512 quality).
    public var preferredStickerImageURL: URL? {
        // WhatsApp sticker is 512x512.
        // 7TV 1x is 32px, 2x is 64px, 3x is 96px, 4x is 128px+.
        // Prefer 4x, then 3x, then 2x, then highest available.
        if let img4x = images.first(where: { $0.scale == 4 }) {
            return img4x.url
        }
        if let img3x = images.first(where: { $0.scale == 3 }) {
            return img3x.url
        }
        if let img2x = images.first(where: { $0.scale == 2 }) {
            return img2x.url
        }
        return images.last?.url
    }
    
    /// Preview image URL for quick UI display (prefers 2x or 1x for performance).
    public var thumbnailURL: URL? {
        if let img2x = images.first(where: { $0.scale == 2 }) {
            return img2x.url
        }
        if let img1x = images.first(where: { $0.scale == 1 }) {
            return img1x.url
        }
        return images.first?.url
    }
}
