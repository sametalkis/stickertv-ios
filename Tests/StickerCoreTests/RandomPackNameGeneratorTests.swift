import XCTest
@testable import StickerCore

final class RandomPackNameGeneratorTests: XCTestCase {
    
    func testGenerateReturnsNonEmptyString() {
        let name = RandomPackNameGenerator.generate()
        XCTAssertFalse(name.isEmpty)
        let components = name.split(separator: " ")
        XCTAssertEqual(components.count, 2, "Generated name should consist of two parts (e.g., 'Neon Pepe')")
    }
    
    func testGenerateReturnsVariedNames() {
        var names = Set<String>()
        for _ in 1...20 {
            names.insert(RandomPackNameGenerator.generate())
        }
        XCTAssertGreaterThan(names.count, 1, "Random generator should produce distinct names across multiple calls")
    }
}
