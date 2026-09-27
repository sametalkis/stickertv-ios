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
    
    /// Finds the best WebP image URL for WhatsApp sticker generation (prefers 4x/3x/2x WebP).
    public var preferredStickerImageURL: URL? {
        let webpImages = images.filter {
            $0.mimeType.contains("webp") || $0.url.absoluteString.hasSuffix(".webp")
        }
        
        let candidateImages: [EmoteImage]
        if isAnimated {
            let animatedCandidates = webpImages.filter { !$0.url.absoluteString.contains("static") }
            candidateImages = animatedCandidates.isEmpty ? webpImages : animatedCandidates
        } else {
            candidateImages = webpImages
        }
        
        // WhatsApp sticker is 512x512.
        // Prefer 4x, then 3x, then 2x, then 1x.
        let limit = isAnimated ? 480 * 1024 : 100 * 1024
        
        for scale in [4, 3, 2, 1] {
            if let img = candidateImages.first(where: { $0.scale == scale }) {
                if let size = img.fileSize, size > limit {
                    continue
                }
                return img.url
            }
        }
        
        return candidateImages.first?.url ?? images.first?.url
    }
    
    /// Preview image URL for quick UI display (prefers 2x or 1x for performance).
    public var thumbnailURL: URL? {
        let candidateImages: [EmoteImage]
        if isAnimated {
            let nonStatic = images.filter { !$0.url.absoluteString.contains("static") }
            candidateImages = nonStatic.isEmpty ? images : nonStatic
        } else {
            candidateImages = images
        }
        
        let preferredFormatImages = candidateImages.filter {
            $0.mimeType.contains("webp") || $0.mimeType.contains("gif") ||
            $0.url.absoluteString.hasSuffix(".webp") || $0.url.absoluteString.hasSuffix(".gif")
        }
        let pool = preferredFormatImages.isEmpty ? candidateImages : preferredFormatImages
        
        for scale in [2, 1, 3, 4] {
            if let img = pool.first(where: { $0.scale == scale }) {
                return img.url
            }
        }
        return pool.first?.url ?? images.first?.url
    }
}
