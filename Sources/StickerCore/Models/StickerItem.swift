import Foundation

/// Represents a single sticker inside a sticker pack, holding emote metadata and assigned WhatsApp emojis.
public struct StickerItem: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let emote: EmoteItem
    public var emojis: [String]
    public var localWebPURL: URL?
    public var processedFileSize: Int?
    
    public init(
        id: UUID = UUID(),
        emote: EmoteItem,
        emojis: [String] = [],
        localWebPURL: URL? = nil,
        processedFileSize: Int? = nil
    ) {
        self.id = id
        self.emote = emote
        self.emojis = emojis
        self.localWebPURL = localWebPURL
        self.processedFileSize = processedFileSize
    }
}
