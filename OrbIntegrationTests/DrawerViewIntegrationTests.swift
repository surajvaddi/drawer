import XCTest
@testable import Orb

final class DrawerViewIntegrationTests: XCTestCase {
    func testDrawerOpenCloseViaOrbClick() {
        let panel = DrawerPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 500))
        panel.contentView = NSHostingView(rootView: DrawerView())
        panel.orderFront(nil)
        XCTAssertTrue(panel.isVisible)
        panel.orderOut(nil)
        XCTAssertFalse(panel.isVisible)
    }
}

import AppKit
import SwiftUI
