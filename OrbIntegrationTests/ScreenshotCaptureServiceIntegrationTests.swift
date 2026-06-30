import XCTest
@testable import Orb

final class ScreenshotCaptureServiceIntegrationTests: XCTestCase {
    func testCaptureScreenRegionIntegration() throws {
        let service = ScreenshotCaptureService()
        do {
            let png = try service.captureRegion(CGRect(x: 0, y: 0, width: 8, height: 8))
            XCTAssertGreaterThan(png.count, 0)
        } catch {
            throw XCTSkip("Screen capture unavailable: \(error)")
        }
    }
}
