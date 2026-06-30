import XCTest
@testable import Orb

final class FTSQueryBuilderTests: XCTestCase {
    func testEscapeSpecialCharacters() {
        let builder = FTSQueryBuilder()
        XCTAssertFalse(builder.escape("hello:world*").contains(":"))
    }

    func testPrefixSearchQuery() {
        let builder = FTSQueryBuilder()
        XCTAssertEqual(builder.build(from: "design modal"), "design* modal*")
    }
}
