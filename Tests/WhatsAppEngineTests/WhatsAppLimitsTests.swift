import XCTest
@testable import WhatsAppEngine
@testable import StickerCore

final class WhatsAppLimitsTests: XCTestCase {
    
    func testValidationFailsWithLessThanThreeStickers() {
        var pack = StickerPack(name: "Test", publisher: "Me")
        pack.stickers = [
            StickerItem(emote: EmoteItem(id: "1", sourceId: "7tv", name: "e1", isAnimated: false), emojis: ["🔥"]),
            StickerItem(emote: EmoteItem(id: "2", sourceId: "7tv", name: "e2", isAnimated: false), emojis: ["❤️"])
        ]
        
        let result = WhatsAppValidationEngine.validate(pack: pack)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(where: { $0.contains("en az 3 çıkartma") }))
    }
    
    func testValidationSucceedsWithThreeToThirtyStickers() {
        var pack = StickerPack(name: "Valid Pack", publisher: "Valid Publisher")
        pack.stickers = (1...5).map { i in
            StickerItem(
                emote: EmoteItem(id: "\(i)", sourceId: "7tv", name: "emote\(i)", isAnimated: false),
                emojis: ["😀"]
            )
        }
        
        let result = WhatsAppValidationEngine.validate(pack: pack)
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
    
    func testValidationFailsWithEmptyTitleOrPublisher() {
        let pack = StickerPack(name: "", publisher: "")
        let result = WhatsAppValidationEngine.validate(pack: pack)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(where: { $0.contains("Paket adı boş olamaz") }))
        XCTAssertTrue(result.errors.contains(where: { $0.contains("Yayıncı adı boş olamaz") }))
    }
    
    func testValidationFailsWithMixedAnimatedAndStaticStickers() {
        var pack = StickerPack(name: "Mixed Pack", publisher: "Publisher")
        pack.stickers = [
            StickerItem(emote: EmoteItem(id: "1", sourceId: "7tv", name: "static1", isAnimated: false), emojis: ["😀"]),
            StickerItem(emote: EmoteItem(id: "2", sourceId: "7tv", name: "static2", isAnimated: false), emojis: ["😀"]),
            StickerItem(emote: EmoteItem(id: "3", sourceId: "7tv", name: "anim1", isAnimated: true), emojis: ["🔥"])
        ]
        
        let result = WhatsAppValidationEngine.validate(pack: pack)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(where: { $0.contains("hem hareketli hem statik") }))
    }
}
