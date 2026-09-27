import Foundation
import StickerCore

/// SevenTV v4 GraphQL Provider implementation of `EmoteSourceProtocol`.
public final class SevenTVProvider: EmoteSourceProtocol, @unchecked Sendable {
    
    public let sourceId: String = "7tv"
    public let displayName: String = "SevenTV (7TV)"
    public let iconSystemName: String = "tv"
    public let supportsAnimation: Bool = true
    
    private let endpoint: URL
    private let networkClient: NetworkClient
    
    public init(
        endpoint: URL = URL(string: "https://7tv.io/v4/gql")!,
        networkClient: NetworkClient = NetworkClient()
    ) {
        self.endpoint = endpoint
        self.networkClient = networkClient
    }
    
    // MARK: - EmoteSourceProtocol
    
    public func searchEmotes(
        query: String?,
        sort: EmoteSortOption,
        filters: EmoteFilters?,
        page: Int,
        perPage: Int
    ) async throws -> EmoteSearchResult {
        let sevenTVSort = mapSortOption(sort)
        let sevenTVFilters = filters.map { f in
            SevenTVFiltersInput(
                animated: f.isAnimated,
                nsfw: f.isNsfw,
                exactMatch: f.exactMatch
            )
        }
        
        let variables = SevenTVSearchVariables(
            query: query?.isEmpty == true ? nil : query,
            tags: filters?.tags ?? [],
            sortBy: sevenTVSort,
            filters: sevenTVFilters,
            page: max(1, page),
            perPage: min(100, max(1, perPage))
        )
        
        let requestBody = SevenTVGraphQLRequest(
            operationName: "EmoteSearch",
            query: SevenTVGraphQLQueries.emoteSearchQuery,
            variables: variables
        )
        
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(requestBody)
        
        let response: SevenTVGraphQLResponse<SevenTVSearchResponseData> = try await networkClient.postJSON(
            to: endpoint,
            body: bodyData
        )
        
        if let errors = response.errors, !errors.isEmpty {
            throw NetworkError.graphQLErrors(errors.map(\.message))
        }
        
        guard let searchPayload = response.data?.emotes.search else {
            throw NetworkError.decodingError("GraphQL response missing emotes.search payload")
        }
        
        let domainItems = searchPayload.items.map { $0.toDomainItem() }
        
        return EmoteSearchResult(
            items: domainItems,
            totalCount: searchPayload.totalCount,
            pageCount: searchPayload.pageCount,
            currentPage: page
        )
    }
    
    public func fetchTrending(
        sort: EmoteSortOption = .trendingWeekly,
        page: Int = 1,
        perPage: Int = 30
    ) async throws -> EmoteSearchResult {
        try await searchEmotes(
            query: nil,
            sort: sort,
            filters: nil,
            page: page,
            perPage: perPage
        )
    }
    
    public func fetchEmoteDetails(id: String) async throws -> EmoteItem {
        struct EmoteByIdVariables: Encodable {
            let id: String
        }
        
        let requestBody = SevenTVGraphQLRequest(
            operationName: "EmoteById",
            query: SevenTVGraphQLQueries.emoteByIdQuery,
            variables: EmoteByIdVariables(id: id)
        )
        
        let bodyData = try JSONEncoder().encode(requestBody)
        let response: SevenTVGraphQLResponse<SevenTVEmoteResponseData> = try await networkClient.postJSON(
            to: endpoint,
            body: bodyData
        )
        
        if let errors = response.errors, !errors.isEmpty {
            throw NetworkError.graphQLErrors(errors.map(\.message))
        }
        
        guard let emoteNode = response.data?.emotes.emote else {
            throw NetworkError.unknown("Emote '\(id)' bulunamadı.")
        }
        
        return emoteNode.toDomainItem()
    }
    
    // MARK: - Sort Mapping
    
    private func mapSortOption(_ sort: EmoteSortOption) -> String {
        switch sort {
        case .trendingDaily: return "TRENDING_DAILY"
        case .trendingWeekly: return "TRENDING_WEEKLY"
        case .trendingMonthly: return "TRENDING_MONTHLY"
        case .topDaily: return "TOP_DAILY"
        case .topWeekly: return "TOP_WEEKLY"
        case .topMonthly: return "TOP_MONTHLY"
        case .topAllTime: return "TOP_ALL_TIME"
        case .nameAlphabetical: return "NAME_ALPHABETICAL"
        case .newest: return "UPLOAD_DATE"
        }
    }
}
