import XCTest
@testable import StickerCore

final class EmoteSourceRegistryTests: XCTestCase {
    
    struct MockSource: EmoteSourceProtocol {
        let sourceId: String
        let displayName: String
        let iconSystemName: String = "star"
        let supportsAnimation: Bool = true
        
        func searchEmotes(query: String?, sort: EmoteSortOption, filters: EmoteFilters?, page: Int, perPage: Int) async throws -> EmoteSearchResult {
            return EmoteSearchResult(items: [], totalCount: 0, pageCount: 0, currentPage: 1)
        }
        
        func fetchTrending(sort: EmoteSortOption, page: Int, perPage: Int) async throws -> EmoteSearchResult {
            return EmoteSearchResult(items: [], totalCount: 0, pageCount: 0, currentPage: 1)
        }
        
        func fetchEmoteDetails(id: String) async throws -> EmoteItem {
            return EmoteItem(id: id, sourceId: sourceId, name: "Test", isAnimated: false)
        }
    }
    
    func testRegistryRegistrationAndRetrieval() {
        let registry = EmoteSourceRegistry()
        let source1 = MockSource(sourceId: "mock1", displayName: "Mock 1")
        let source2 = MockSource(sourceId: "mock2", displayName: "Mock 2")
        
        registry.register(source1)
        registry.register(source2)
        
        XCTAssertEqual(registry.allSources.count, 2)
        XCTAssertEqual(registry.source(for: "mock1")?.displayName, "Mock 1")
        XCTAssertEqual(registry.source(for: "mock2")?.displayName, "Mock 2")
        
        // Active source defaults to first registered
        XCTAssertEqual(registry.activeSource?.sourceId, "mock1")
        
        // Switching active source
        registry.setActiveSource(id: "mock2")
        XCTAssertEqual(registry.activeSource?.sourceId, "mock2")
    }
}
