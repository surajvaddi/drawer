import XCTest
@testable import Orb

final class QuickPastePanelTests: XCTestCase {
    func testPanelOpensOnShortcut() {
        let panel = QuickPastePanel()
        panel.openPanel()
        XCTAssertTrue(panel.isOpen)
    }

    func testPanelClosesOnEsc() {
        let panel = QuickPastePanel()
        panel.openPanel()
        panel.closeOnEscape()
        XCTAssertFalse(panel.isOpen)
    }
}
