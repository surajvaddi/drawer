import XCTest
@testable import Orb

final class FloatingOrbPanelTests: XCTestCase {
    func testPanelIsFloatingAndBorderless() {
        let panel = FloatingOrbPanel(contentRect: NSRect(x: 0, y: 0, width: 48, height: 48))
        XCTAssertTrue(panel.isFloatingPanel)
        XCTAssertEqual(panel.styleMask.contains(.borderless), true)
        XCTAssertEqual(panel.backgroundColor, .clear)
    }

    func testPanelDoesNotStealFocusByDefault() {
        let panel = FloatingOrbPanel(contentRect: .zero)
        XCTAssertFalse(panel.canBecomeKey)
        XCTAssertFalse(panel.canBecomeMain)
    }
}

import AppKit
