import XCTest
@testable import Orb

final class FuzzySearchServiceIntegrationTests: XCTestCase {
    func testFuzzyFindsModalWhenTypedModl() {
        let items = [Item(type: .text, title: "Modal dialog", preview: "")]
        let results = FuzzySearchService().search(query: "modl", in: items)
        XCTAssertEqual(results.first?.title, "Modal dialog")
    }
}
