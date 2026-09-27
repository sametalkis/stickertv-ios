import XCTest
@testable import SevenTVSource
@testable import StickerCore

final class SevenTVProviderTests: XCTestCase {
    
    func testSevenTVNodeToDomainMapping() {
        let node = SevenTVEmoteNode(
            id: "60ae3d2890632a6be8b6d859",
            defaultName: "catJAM",
            tags: ["cat", "jam"],
            flags: SevenTVFlags(animated: true, nsfw: false, defaultZeroWidth: false, private: false, publicListed: true),
            images: [
                SevenTVImage(
                    url: "https://cdn.7tv.app/emote/60ae3d2890632a6be8b6d859/1x.webp",
                    mime: "image/webp",
                    scale: 1,
                    width: 32,
                    height: 32,
                    size: 1024,
                    frameCount: 16
                ),
                SevenTVImage(
                    url: "https://cdn.7tv.app/emote/60ae3d2890632a6be8b6d859/2x.webp",
                    mime: "image/webp",
                    scale: 2,
                    width: 64,
                    height: 64,
                    size: 4096,
                    frameCount: 16
                )
            ],
            aspectRatio: 1.0,
            owner: SevenTVOwner(id: "user123", mainConnection: SevenTVConnection(platformDisplayName: "Tester"))
        )
        
        let domainItem = node.toDomainItem()
        XCTAssertEqual(domainItem.id, "60ae3d2890632a6be8b6d859")
        XCTAssertEqual(domainItem.sourceId, "7tv")
        XCTAssertEqual(domainItem.name, "catJAM")
        XCTAssertTrue(domainItem.isAnimated)
        XCTAssertEqual(domainItem.images.count, 2)
        XCTAssertEqual(domainItem.preferredStickerImageURL?.absoluteString, "https://cdn.7tv.app/emote/60ae3d2890632a6be8b6d859/2x.webp")
        XCTAssertEqual(domainItem.ownerName, "Tester")
    }
}
