import XCTest
@testable import StickerCore

final class EmojiSuggesterTests: XCTestCase {
    
    func testSuggestCatEmotes() {
        let emojis = EmojiSuggester.suggest(for: "catJAM", tags: ["vibing"])
        XCTAssertTrue(emojis.contains("🐱") || emojis.contains("😻"))
        XCTAssertLessThanOrEqual(emojis.count, 3)
    }
    
    func testSuggestLaughterEmotes() {
        let emojis = EmojiSuggester.suggest(for: "KEKW", tags: ["laugh", "spanish"])
        XCTAssertTrue(emojis.contains("😂") || emojis.contains("🤣"))
    }
    
    func testSuggestPepeEmotes() {
        let emojis = EmojiSuggester.suggest(for: "pepega", tags: ["frog"])
        XCTAssertTrue(emojis.contains("🐸"))
    }
    
    func testFallbackEmojiForUnknownEmote() {
        let emojis = EmojiSuggester.suggest(for: "xyz123randomNonExistent", tags: [])
        XCTAssertFalse(emojis.isEmpty)
        XCTAssertLessThanOrEqual(emojis.count, 3)
    }
}
