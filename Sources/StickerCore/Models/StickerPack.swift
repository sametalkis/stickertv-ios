import Foundation

/// Domain representation of a complete sticker pack.
public struct StickerPack: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var publisher: String
    public var trayEmote: EmoteItem?
    public var stickers: [StickerItem]
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String = "Yeni Paket",
        publisher: String = "7TV Sticker Studio",
        trayEmote: EmoteItem? = nil,
        stickers: [StickerItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.publisher = publisher
        self.trayEmote = trayEmote
        self.stickers = stickers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Returns true if at least one sticker in the pack is animated.
    public var isAnimatedPack: Bool {
        stickers.contains { $0.emote.isAnimated }
    }
    
    /// Current count of stickers.
    public var count: Int {
        stickers.count
    }
    
    /// Minimum stickers required by WhatsApp (3).
    public static let minimumStickersCount = 3
    
    /// Maximum stickers allowed by WhatsApp (30).
    public static let maximumStickersCount = 30
    
    /// Whether the pack meets WhatsApp minimum/maximum sticker quantity requirements.
    public var hasValidStickerCount: Bool {
        count >= Self.minimumStickersCount && count <= Self.maximumStickersCount
    }
    
    /// Returns the tray emote or falls back to the first sticker's emote.
    public var effectiveTrayEmote: EmoteItem? {
        trayEmote ?? stickers.first?.emote
    }
}
