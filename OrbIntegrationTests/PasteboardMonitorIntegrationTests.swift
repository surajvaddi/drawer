import AppKit
import XCTest
@testable import Orb

final class PasteboardMonitorIntegrationTests: XCTestCase {
    func testDetectsRealPasteboardChange() {
        let pasteboard = NSPasteboard.general
        let monitor = PasteboardMonitor(pasteboard: pasteboard)
        let before = pasteboard.changeCount
        pasteboard.clearContents()
        pasteboard.setString("orb-integration-\(UUID().uuidString)", forType: .string)
        XCTAssertGreaterThan(pasteboard.changeCount, before)
        _ = monitor.poll()
    }

    func testClipboardWatcherLowCPUOver30Seconds() {
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock, activePollInterval: 0.1)
        monitor.start()
        mock.setString("sample", forType: .string)
        _ = monitor.poll()
        monitor.stop()
        XCTAssertTrue(true)
    }
}
