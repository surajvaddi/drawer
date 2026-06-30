import XCTest
@testable import Orb

final class DrawerPanelIntegrationTests: XCTestCase {
    func testDrawerOpensWithin100ms() {
        let start = Date()
        let panel = DrawerPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 400))
        panel.contentView = NSHostingView(rootView: DrawerView())
        panel.orderFrontRegardless()
        XCTAssertLessThan(Date().timeIntervalSince(start), 0.1)
    }
}

import AppKit
import SwiftUI
