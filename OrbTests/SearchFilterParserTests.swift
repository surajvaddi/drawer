import XCTest
@testable import Orb

final class SearchFilterParserTests: XCTestCase {
    func testParseTypeFilter() {
        let filters = SearchFilterParser().parse("type:screenshot design")
        XCTAssertTrue(filters.types.contains(.screenshot))
        XCTAssertEqual(filters.text, "design")
    }

    func testParseDateRangeFilters() {
        let filters = SearchFilterParser().parse("after:2026-01-01 before:2026-12-31 query")
        XCTAssertNotNil(filters.after)
        XCTAssertNotNil(filters.before)
    }

    func testParseTagFilter() {
        let filters = SearchFilterParser().parse("tag:design modal")
        XCTAssertTrue(filters.tags.contains("design"))
    }
}
