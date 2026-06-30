import XCTest
@testable import Orb

final class SearchRankerIntegrationTests: XCTestCase {
    func testRankerOrdersRealResultSet() throws {
        let items = [
            Item(id: "1", type: .text, title: "other", preview: "", contentText: "design"),
            Item(id: "2", type: .text, title: "design guide", preview: "", isPinned: true)
        ]
        let ranked = SearchRanker().rank(items: items, query: "design")
        XCTAssertEqual(ranked.first?.itemID, "2")
    }
}
