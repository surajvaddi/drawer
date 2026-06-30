import XCTest
@testable import Orb

final class DrawerPanelTests: XCTestCase {
    func testDrawerAnchorsToOrbPosition() {
        let panel = DrawerPanel(contentRect: .zero)
        let screen = NSScreen.main
        panel.anchor(near: NSPoint(x: 100, y: 200), orbSize: NSSize(width: 48, height: 48), on: screen)
        XCTAssertEqual(panel.frame.width, DrawerPanel.defaultWidth, accuracy: 0.1)
        XCTAssertGreaterThan(panel.frame.minX, 100)
    }

    func testDrawerMaxHeight80PercentScreen() {
        let panel = DrawerPanel(contentRect: .zero)
        let screen = NSScreen.main
        panel.anchor(near: .zero, orbSize: NSSize(width: 48, height: 48), on: screen)
        guard let screen else { return }
        XCTAssertLessThanOrEqual(panel.frame.height, screen.visibleFrame.height * DrawerPanel.maxHeightRatio + 1)
    }
}

import AppKit
