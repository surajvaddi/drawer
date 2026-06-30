import XCTest
@testable import Orb

final class FuzzySearchServiceTests: XCTestCase {
    func testFuzzyMatchesTypos() {
        let service = FuzzySearchService(threshold: 0.5)
        let items = [Item(type: .text, title: "Modal component", preview: "")]
        let results = service.search(query: "modl", in: items)
        XCTAssertEqual(results.count, 1)
    }

    func testFuzzyRespectsThreshold() {
        let service = FuzzySearchService(threshold: 0.95)
        let items = [Item(type: .text, title: "abcdef", preview: "")]
        XCTAssertTrue(service.search(query: "zzzz", in: items).isEmpty)
    }
}
