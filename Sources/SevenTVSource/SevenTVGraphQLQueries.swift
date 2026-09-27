import Foundation

/// Holds raw GraphQL query strings for SevenTV v4 API.
public struct SevenTVGraphQLQueries {
    
    /// The standard EmoteSearch GraphQL operation matching SevenTV's official web client query.
    public static let emoteSearchQuery = """
    query EmoteSearch(
        $query: String
        $tags: [String!]!
        $sortBy: SortBy!
        $filters: Filters
        $page: Int
        $perPage: Int!
    ) {
        emotes {
            search(
                query: $query
                tags: { tags: $tags, match: ANY }
                sort: { sortBy: $sortBy, order: DESCENDING }
                filters: $filters
                page: $page
                perPage: $perPage
            ) {
                totalCount
                pageCount
                items {
                    id
                    defaultName
                    tags
                    aspectRatio
                    flags {
                        animated
                        defaultZeroWidth
                        nsfw
                        private
                        publicListed
                    }
                    images {
                        url
                        mime
                        scale
                        width
                        height
                        size
                        frameCount
                    }
                    owner {
                        id
                        mainConnection {
                            platformDisplayName
                        }
                    }
                }
            }
        }
    }
    """
    
    /// Query for fetching a single emote by ID.
    public static let emoteByIdQuery = """
    query EmoteById($id: Id!) {
        emotes {
            emote(id: $id) {
                id
                defaultName
                tags
                aspectRatio
                flags {
                    animated
                    defaultZeroWidth
                    nsfw
                    private
                    publicListed
                }
                images {
                    url
                    mime
                    scale
                    width
                    height
                    size
                    frameCount
                }
                owner {
                    id
                    mainConnection {
                        platformDisplayName
                    }
                }
            }
        }
    }
    """
}
