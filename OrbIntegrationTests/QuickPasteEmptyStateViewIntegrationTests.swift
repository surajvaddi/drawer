import XCTest
@testable import Orb

final class QuickPasteEmptyStateViewIntegrationTests: XCTestCase {
    func testNoResultDoesNotCrashOnEnter() throws {
        let model = QuickPasteEmptyStateModel()
        XCTAssertTrue(model.showsNoResults(query: "zzzz", resultCount: 0))
    }
}
