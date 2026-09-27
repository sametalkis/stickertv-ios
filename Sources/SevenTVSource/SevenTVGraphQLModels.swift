import Foundation
import StickerCore

// MARK: - GraphQL Request Envelope

public struct SevenTVGraphQLRequest<V: Encodable & Sendable>: Encodable, Sendable {
    public let operationName: String
    public let query: String
    public let variables: V
    
    public init(operationName: String, query: String, variables: V) {
        self.operationName = operationName
        self.query = query
        self.variables = variables
    }
}

// MARK: - GraphQL Response Envelope

public struct SevenTVGraphQLResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let data: T?
    public let errors: [SevenTVGraphQLError]?
}

public struct SevenTVGraphQLError: Decodable, Sendable {
    public let message: String
}

// MARK: - Search Variables & Data

public struct SevenTVSearchVariables: Encodable, Sendable {
    public let query: String?
    public let tags: [String]
    public let sortBy: String
    public let filters: SevenTVFiltersInput?
    public let page: Int?
    public let perPage: Int?
    
    public init(
        query: String?,
        tags: [String] = [],
        sortBy: String,
        filters: SevenTVFiltersInput? = nil,
        page: Int? = 1,
        perPage: Int? = 30
    ) {
        self.query = query
        self.tags = tags
        self.sortBy = sortBy
        self.filters = filters
        self.page = page
        self.perPage = perPage
    }
}

public struct SevenTVFiltersInput: Encodable, Sendable {
    public let animated: Bool?
    public let nsfw: Bool?
    public let exactMatch: Bool?
    
    public init(animated: Bool? = nil, nsfw: Bool? = nil, exactMatch: Bool? = nil) {
        self.animated = animated
        self.nsfw = nsfw
        self.exactMatch = exactMatch
    }
}

// MARK: - SevenTV v4 Data Models

public struct SevenTVSearchResponseData: Decodable, Sendable {
    public let emotes: SevenTVEmotesContainer
}

public struct SevenTVEmotesContainer: Decodable, Sendable {
    public let search: SevenTVSearchPayload
}

public struct SevenTVSearchPayload: Decodable, Sendable {
    public let totalCount: Int
    public let pageCount: Int
    public let items: [SevenTVEmoteNode]
}

public struct SevenTVEmoteResponseData: Decodable, Sendable {
    public let emotes: SevenTVSingleEmoteContainer
}

public struct SevenTVSingleEmoteContainer: Decodable, Sendable {
    public let emote: SevenTVEmoteNode?
}

public struct SevenTVEmoteNode: Decodable, Sendable {
    public let id: String
    public let defaultName: String
    public let tags: [String]?
    public let flags: SevenTVFlags?
    public let images: [SevenTVImage]?
    public let aspectRatio: Double?
    public let owner: SevenTVOwner?
    
    /// Converts SevenTV GraphQL node to generic domain `EmoteItem`.
    public func toDomainItem() -> EmoteItem {
        let domainImages: [EmoteImage] = (images ?? []).compactMap { img in
            guard let url = URL(string: img.url) else { return nil }
            return EmoteImage(
                url: url,
                mimeType: img.mime,
                scale: img.scale,
                width: img.width,
                height: img.height,
                fileSize: img.size
            )
        }
        
        let isAnimated = (flags?.animated ?? false) || domainImages.contains(where: {
            $0.mimeType.contains("gif") || $0.mimeType.contains("webp")
        }) && (flags?.animated != false)
        
        return EmoteItem(
            id: id,
            sourceId: "7tv",
            name: defaultName,
            isAnimated: flags?.animated ?? false,
            aspectRatio: aspectRatio ?? 1.0,
            tags: tags ?? [],
            images: domainImages,
            ownerName: owner?.mainConnection?.platformDisplayName
        )
    }
}

public struct SevenTVFlags: Decodable, Sendable {
    public let animated: Bool?
    public let nsfw: Bool?
    public let defaultZeroWidth: Bool?
    public let `private`: Bool?
    public let publicListed: Bool?
}

public struct SevenTVImage: Decodable, Sendable {
    public let url: String
    public let mime: String
    public let scale: Int
    public let width: Int?
    public let height: Int?
    public let size: Int?
    public let frameCount: Int?
}

public struct SevenTVOwner: Decodable, Sendable {
    public let id: String?
    public let mainConnection: SevenTVConnection?
}

public struct SevenTVConnection: Decodable, Sendable {
    public let platformDisplayName: String?
}
