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
}
