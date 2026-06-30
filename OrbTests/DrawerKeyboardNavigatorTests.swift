import XCTest
@testable import Orb

final class DrawerKeyboardNavigatorTests: XCTestCase {
    func testArrowMovesSelection() {
        let items = [
            Item(type: .text, title: "A"),
            Item(type: .text, title: "B"),
            Item(type: .text, title: "C")
        ]
        var navigator = DrawerKeyboardNavigator()
        navigator.moveDown(itemCount: items.count)
        navigator.moveDown(itemCount: items.count)
        XCTAssertEqual(navigator.selectedIndex, 2)
        navigator.moveUp()
        XCTAssertEqual(navigator.selectedItem(in: items)?.title, "B")
    }

    func testSpaceOpensPreview() {
        var navigator = DrawerKeyboardNavigator()
        navigator.openPreview()
        XCTAssertTrue(navigator.previewOpen)
    }

    func testDeleteArchivesItem() {
        let items = [Item(type: .text, title: "Archive me")]
        var navigator = DrawerKeyboardNavigator()
        XCTAssertEqual(navigator.archiveTarget(in: items)?.title, "Archive me")
    }
}
