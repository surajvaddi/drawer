import XCTest
@testable import Orb

final class QuickPasteEmptyStateViewTests: XCTestCase {
    func testEmptyQueryShowsRecents() {
        let model = QuickPasteEmptyStateModel()
        XCTAssertTrue(model.showsRecents(query: ""))
    }

    func testNoResultsShowsSuggestions() {
        let model = QuickPasteEmptyStateModel()
        XCTAssertTrue(model.showsNoResults(query: "missing", resultCount: 0))
    }
}
