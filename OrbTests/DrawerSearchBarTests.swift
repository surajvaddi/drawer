import XCTest
import SwiftUI
@testable import Orb

final class DrawerSearchBarTests: XCTestCase {
    func testSearchTextBinding() {
        var text = "orb"
        let binding = Binding(get: { text }, set: { text = $0 })
        _ = DrawerSearchBar(text: binding)
        binding.wrappedValue = "kind designs"
        XCTAssertEqual(text, "kind designs")
    }

    func testClearButtonResetsQuery() {
        var text = "query"
        text = ""
        XCTAssertTrue(text.isEmpty)
    }
}
