import XCTest
@testable import Orb

final class ClipboardPreviewCleanerTests: XCTestCase {
    func testPreviewClearsAfterTimeout() {
        let cleaner = ClipboardPreviewCleaner(timeout: 30)
        let state = ClipboardPreviewState(previewText: "temp", capturedAt: Date(timeIntervalSinceNow: -60))
        XCTAssertTrue(cleaner.shouldClear(state: state, now: Date(), isPaused: false))
    }

    func testPreviewClearsOnPause() {
        let cleaner = ClipboardPreviewCleaner()
        let state = ClipboardPreviewState(previewText: "temp", capturedAt: Date())
        XCTAssertTrue(cleaner.shouldClear(state: state, isPaused: true))
    }
}
