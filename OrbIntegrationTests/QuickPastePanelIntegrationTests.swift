import XCTest
@testable import Orb

final class QuickPastePanelIntegrationTests: XCTestCase {
    func testQuickPasteOpensWithoutMainWindow() {
        let panel = QuickPastePanel()
        panel.openPanel()
        XCTAssertTrue(panel.isVisible)
        panel.closeOnEscape()
    }
}
