import XCTest
@testable import Orb

final class OrbDragControllerIntegrationTests: XCTestCase {
    func testDragOrbAcrossMultipleDisplays() {
        let screens = NSScreen.screens
        XCTAssertFalse(screens.isEmpty)
        let controller = EdgeSnapController()
        let size = NSSize(width: 48, height: 48)
        let snapped = controller.snappedOrigin(for: NSPoint(x: 0, y: 0), windowSize: size, in: screens.first)
        XCTAssertGreaterThanOrEqual(snapped.x, 0)
    }
}

import AppKit
