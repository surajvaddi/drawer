import XCTest
@testable import Orb

final class FloatingOrbPanelIntegrationTests: XCTestCase {
    func testFloatingPanelDisplaysInTestHost() {
        let panel = FloatingOrbPanel(contentRect: NSRect(x: 100, y: 100, width: 48, height: 48))
        panel.contentView = NSHostingView(rootView: OrbView())
        XCTAssertNotNil(panel.contentView)
        XCTAssertGreaterThan(panel.frame.width, 0)
    }
}

import AppKit
import SwiftUI
