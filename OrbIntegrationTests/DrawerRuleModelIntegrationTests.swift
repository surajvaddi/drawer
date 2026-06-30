import XCTest

final class DrawerRuleModelIntegrationTests: XCTestCase {
    func testAIAnnotationRoundTrip() throws {
        let annotation = AIAnnotation(
            itemId: "item",
            kind: .title,
            model: "mock",
            content: ["title": "Kind Designs"]
        )
        let data = try JSONEncoder().encode(annotation)
        let decoded = try JSONDecoder().decode(AIAnnotation.self, from: data)
        XCTAssertEqual(decoded.content["title"], "Kind Designs")
    }
}
