import Foundation

/// Paginated search result containing emote items.
public struct EmoteSearchResult: Hashable, Codable, Sendable {
    public let items: [EmoteItem]
    public let totalCount: Int
    public let pageCount: Int
    public let currentPage: Int
    
    public init(
        items: [EmoteItem],
        totalCount: Int,
        pageCount: Int,
        currentPage: Int
    ) {
        self.items = items
        self.totalCount = totalCount
        self.pageCount = pageCount
        self.currentPage = currentPage
    }
}
