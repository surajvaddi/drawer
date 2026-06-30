import XCTest

final class ItemModelIntegrationTests: XCTestCase {
    func testItemEncodesToJSONFixture() throws {
        let item = Item(type: .text, title: "Snippet", contentText: "body")
        let data = try JSONEncoder().encode(item)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(json?["type"] as? String, "text")
        XCTAssertEqual(json?["title"] as? String, "Snippet")
    }
}
