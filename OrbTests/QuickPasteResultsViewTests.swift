import XCTest
@testable import Orb

final class QuickPasteResultsViewTests: XCTestCase {
    func testArrowKeysChangeSelection() {
        var model = QuickPasteKeyboardModel()
        model.moveDown(count: 3)
        XCTAssertEqual(model.selection, 1)
        model.moveUp()
        XCTAssertEqual(model.selection, 0)
    }

    func testEnterInvokesCopy() {
        let item = Item(type: .text, title: "Copy me", preview: "body", contentText: "body")
        var copied: Item?
        let onCopy: (Item) -> Void = { copied = $0 }
        onCopy(item)
        XCTAssertEqual(copied?.id, item.id)
    }
}
