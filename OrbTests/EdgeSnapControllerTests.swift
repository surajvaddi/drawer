import XCTest
@testable import Orb

final class EdgeSnapControllerTests: XCTestCase {
    func testSnapToNearestEdgeWithinThreshold() {
        let controller = EdgeSnapController(threshold: 20)
        guard let screen = NSScreen.main else {
            XCTFail("no screen")
            return
        }
        let nearOrigin = NSPoint(x: screen.visibleFrame.minX + 5, y: screen.visibleFrame.minY + 5)
        let snapped = controller.snappedOrigin(
            for: nearOrigin,
            windowSize: NSSize(width: 48, height: 48),
            in: screen
        )
        XCTAssertEqual(snapped.x, screen.visibleFrame.minX, accuracy: 0.1)
        XCTAssertEqual(snapped.y, screen.visibleFrame.minY, accuracy: 0.1)
    }

    func testNoSnapWhenDisabled() {
        let controller = EdgeSnapController(enabled: false)
        let origin = NSPoint(x: 123, y: 456)
        let snapped = controller.snappedOrigin(for: origin, windowSize: NSSize(width: 48, height: 48), in: NSScreen.main)
        XCTAssertEqual(snapped, origin)
    }
}

import AppKit
