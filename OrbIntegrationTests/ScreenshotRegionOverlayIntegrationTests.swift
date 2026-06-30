import XCTest
@testable import Orb

final class ScreenshotRegionOverlayIntegrationTests: XCTestCase {
    func testOverlayCapturesRegionCoordinates() {
        let overlay = ScreenshotRegionOverlay()
        let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let selection = overlay.selection(from: CGPoint(x: 100, y: 100), to: CGPoint(x: 400, y: 300), screenBounds: screen)
        XCTAssertEqual(selection.rect.width, 300, accuracy: 0.1)
        XCTAssertEqual(selection.rect.height, 200, accuracy: 0.1)
    }
}
