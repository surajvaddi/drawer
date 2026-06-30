import XCTest
@testable import Orb

final class EdgeSnapControllerIntegrationTests: XCTestCase {
    func testSnapRespectsVisibleFrame() {
        guard let screen = NSScreen.main else {
            XCTFail("no main screen")
            return
        }
        let controller = EdgeSnapController()
        let snapped = controller.snappedOrigin(
            for: screen.visibleFrame.origin,
            windowSize: NSSize(width: 48, height: 48),
            in: screen
        )
        XCTAssertGreaterThanOrEqual(snapped.x, screen.visibleFrame.minX)
        XCTAssertGreaterThanOrEqual(snapped.y, screen.visibleFrame.minY)
    }
}

import AppKit
