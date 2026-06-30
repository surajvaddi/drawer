import XCTest
@testable import Orb

final class DrawerSearchBarIntegrationTests: XCTestCase {
    func testSearchBarAcceptsKeyboardInput() {
        var model = DrawerViewModel(searchText: "sensor")
        model.searchText = "concrete"
        XCTAssertEqual(model.searchText, "concrete")
    }
}
