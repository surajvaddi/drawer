import XCTest
@testable import Orb

final class ItemCardContextMenuTests: XCTestCase {
    func testContextMenuActionsInvokeCallbacks() {
        var copied = false
        var moved = false
        var tagged = false
        var deleted = false
        let menu = ItemCardContextMenu(
            onCopy: { copied = true },
            onMove: { moved = true },
            onTag: { tagged = true },
            onDelete: { deleted = true }
        )
        menu.performCopy()
        menu.performMove()
        menu.performTag()
        menu.performDelete()
        XCTAssertTrue(copied && moved && tagged && deleted)
    }
}
