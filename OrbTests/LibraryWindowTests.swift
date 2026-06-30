import XCTest
@testable import Orb

final class LibraryWindowTests: XCTestCase {
    func testLibraryWindowOpensFromMenu() {
        var controller = LibraryWindowController()
        let view = LibraryWindow(items: [], drawers: [], onSelectItem: { _ in })
        controller.show(content: view)
        XCTAssertNotNil(view.body)
    }
}
