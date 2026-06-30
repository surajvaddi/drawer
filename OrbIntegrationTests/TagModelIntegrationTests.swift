import XCTest

final class TagModelIntegrationTests: XCTestCase {
    func testTagsDecodeFromFixtureJSON() throws {
        let json = """
        {"id":"t1","name":"Research","color":"#00FF00"}
        """
        let tag = try JSONDecoder().decode(Tag.self, from: Data(json.utf8))
        XCTAssertEqual(tag.name, "research")
    }
}
