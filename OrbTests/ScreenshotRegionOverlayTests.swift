import XCTest
@testable import Orb

final class ScreenshotRegionOverlayTests: XCTestCase {
    func testSelectionRectClampedToScreen() {
        let overlay = ScreenshotRegionOverlay()
        let screen = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let selection = overlay.selection(from: CGPoint(x: -50, y: 10), to: CGPoint(x: 1200, y: 900), screenBounds: screen)
        XCTAssertEqual(selection.rect.minX, 0)
        XCTAssertLessThanOrEqual(selection.rect.maxX, 1000)
        XCTAssertLessThanOrEqual(selection.rect.maxY, 800)
    }

    func testEscapeCancelsCapture() {
        let overlay = ScreenshotRegionOverlay()
        let cancelled = overlay.cancelSelection()
        XCTAssertTrue(cancelled.cancelled)
        XCTAssertEqual(cancelled.rect, .zero)
    }
}
