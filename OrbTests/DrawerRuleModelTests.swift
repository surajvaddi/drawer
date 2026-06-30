import XCTest
@testable import Orb

final class DrawerRuleModelTests: XCTestCase {
    func testDrawerRulePrioritySort() {
        let low = DrawerRule(drawerId: "d", name: "low", condition: [:], priority: 1)
        let high = DrawerRule(drawerId: "d", name: "high", condition: [:], priority: 10)
        XCTAssertTrue(high.priority > low.priority)
    }

    func testAIAnnotationKindParsing() throws {
        let json = "\"drawer_suggestion\""
        let kind = try JSONDecoder().decode(AIAnnotationKind.self, from: Data(json.utf8))
        XCTAssertEqual(kind, .drawerSuggestion)
    }
}
