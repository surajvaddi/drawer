import XCTest
@testable import Orb

final class OCRServiceTests: XCTestCase {
    func testOCRReturnsTextForSampleImage() throws {
        let image = NSImage(size: NSSize(width: 200, height: 60))
        image.lockFocus()
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24),
            .foregroundColor: NSColor.black
        ]
        "ORB".draw(at: NSPoint(x: 20, y: 20), withAttributes: attrs)
        image.unlockFocus()
        guard let tiff = image.tiffRepresentation else {
            XCTFail("missing image")
            return
        }
        let service = OCRService()
        let text = try service.recognizeText(in: tiff)
        XCTAssertFalse(text.isEmpty)
    }

    func testOCREmptyForBlankImage() throws {
        let service = OCRService()
        let text = try service.recognizeText(in: TestFixtures.pngData())
        XCTAssertTrue(text.isEmpty)
    }
}

import AppKit
