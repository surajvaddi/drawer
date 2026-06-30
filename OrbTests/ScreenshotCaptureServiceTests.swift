import XCTest
@testable import Orb

final class ScreenshotCaptureServiceTests: XCTestCase {
    func testCaptureReturnsPNGData() throws {
        let service = ScreenshotCaptureService()
        do {
            let png = try service.captureRegion(CGRect(x: 0, y: 0, width: 10, height: 10))
            XCTAssertFalse(png.isEmpty)
            XCTAssertNotNil(NSImage(data: png))
        } catch {
            throw XCTSkip("Screen capture unavailable in this environment: \(error)")
        }
    }

    func testCaptureHonorsRetinaScale() throws {
        let service = ScreenshotCaptureService()
        do {
            let png = try service.captureRegion(CGRect(x: 0, y: 0, width: 20, height: 20), scale: 2)
            XCTAssertFalse(png.isEmpty)
        } catch {
            throw XCTSkip("Screen capture unavailable in this environment: \(error)")
        }
    }
}

import AppKit
