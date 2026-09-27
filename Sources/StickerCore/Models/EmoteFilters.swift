import Foundation

/// Unified search filters applicable to emote sources.
public struct EmoteFilters: Hashable, Codable, Sendable {
    public var isAnimated: Bool?
    public var isNsfw: Bool?
    public var exactMatch: Bool?
    public var tags: [String]
    
    public init(
        isAnimated: Bool? = nil,
        isNsfw: Bool? = false,
        exactMatch: Bool? = nil,
        tags: [String] = []
    ) {
        self.isAnimated = isAnimated
        self.isNsfw = isNsfw
        self.exactMatch = exactMatch
        self.tags = tags
    }
}
