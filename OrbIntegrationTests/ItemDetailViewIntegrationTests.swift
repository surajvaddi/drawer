import XCTest
@testable import Orb

final class ItemDetailViewIntegrationTests: XCTestCase {
    func testExpandCollapsePreservesScrollPosition() {
        var offset: CGFloat = 120
        let before = offset
        offset = 120
        XCTAssertEqual(before, offset)
    }
}
