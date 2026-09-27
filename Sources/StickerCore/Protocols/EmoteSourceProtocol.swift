import Foundation

/// Defines the contract that every emote provider (7TV, BTTV, FFZ, custom) must conform to.
public protocol EmoteSourceProtocol: Sendable {
    /// Unique identifier of the provider (e.g. "7tv", "bttv").
    var sourceId: String { get }
    
    /// User-visible name of the provider (e.g. "SevenTV", "BetterTTV").
    var displayName: String { get }
    
    /// SF Symbol icon name or asset identifier for UI.
    var iconSystemName: String { get }
    
    /// Whether this source provides animated emotes.
    var supportsAnimation: Bool { get }
    
    /// Searches emotes using query string, sorting, and optional filters.
    func searchEmotes(
        query: String?,
        sort: EmoteSortOption,
        filters: EmoteFilters?,
        page: Int,
        perPage: Int
    ) async throws -> EmoteSearchResult
    
    /// Fetches trending emotes according to the given timeframe.
    func fetchTrending(
        sort: EmoteSortOption,
        page: Int,
        perPage: Int
    ) async throws -> EmoteSearchResult
    
    /// Fetches detailed information for a specific emote ID.
    func fetchEmoteDetails(id: String) async throws -> EmoteItem
}
