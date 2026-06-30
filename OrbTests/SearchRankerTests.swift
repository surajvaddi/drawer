import XCTest
@testable import Orb

final class SearchRankerTests: XCTestCase {
    func testTitleMatchRanksHigherThanContent() {
        let title = Item(id: "1", type: .text, title: "design", preview: "", contentText: "other")
        let content = Item(id: "2", type: .text, title: "other", preview: "", contentText: "design")
        let ranked = SearchRanker().rank(items: [content, title], query: "design")
        XCTAssertEqual(ranked.first?.itemID, "1")
    }

    func testPinnedBoostApplied() {
        let pinned = Item(id: "1", type: .text, title: "x", preview: "design", isPinned: true)
        let normal = Item(id: "2", type: .text, title: "x", preview: "design")
        let ranked = SearchRanker().rank(items: [normal, pinned], query: "design")
        XCTAssertEqual(ranked.first?.itemID, "1")
    }

    func testRecencyBoostApplied() {
        let recent = Item(id: "1", type: .text, title: "design", preview: "", lastAccessedAt: Date())
        let old = Item(id: "2", type: .text, title: "design", preview: "", lastAccessedAt: Date(timeIntervalSince1970: 1))
        let ranked = SearchRanker().rank(items: [old, recent], query: "design")
        XCTAssertEqual(ranked.first?.itemID, "1")
    }
}
