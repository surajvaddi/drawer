import XCTest
@testable import Orb

final class PasteboardMonitorTests: XCTestCase {
    func testDetectsChangeCountIncrement() {
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock)
        XCTAssertFalse(monitor.poll())
        mock.setString("hello", forType: .string)
        XCTAssertTrue(monitor.poll())
    }

    func testIgnoresDuplicateChangeCount() {
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock)
        mock.setString("one", forType: .string)
        XCTAssertTrue(monitor.poll())
        XCTAssertFalse(monitor.poll())
    }

    func testPollingBackoffWhenPaused() {
        let mock = MockPasteboard()
        let settings = ClipboardWatchSettings(isPaused: true)
        let monitor = PasteboardMonitor(pasteboard: mock, settings: settings, activePollInterval: 0.5, maxPausedPollInterval: 4.0)
        monitor.start()
        XCTAssertFalse(monitor.poll())
        monitor.stop()
    }
}
