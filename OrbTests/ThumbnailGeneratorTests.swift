import AppKit
import XCTest
@testable import Orb

final class ThumbnailGeneratorTests: XCTestCase {
    func testGenerateThumbnailFromPNG() throws {
        let image = NSImage(size: NSSize(width: 400, height: 200))
        image.lockFocus()
        NSColor.blue.setFill()
        NSRect(x: 0, y: 0, width: 400, height: 200).fill()
        image.unlockFocus()
        guard let tiff = image.tiffRepresentation else {
            XCTFail("missing tiff")
            return
        }
        let generator = ThumbnailGenerator(maxDimension: 128)
        let png = try generator.generatePNG(from: tiff)
        XCTAssertFalse(png.isEmpty)
        XCTAssertNotNil(NSImage(data: png))
    }

    func testThumbnailMaxDimensionRespected() throws {
        let image = NSImage(size: NSSize(width: 800, height: 400))
        image.lockFocus()
        NSColor.red.setFill()
        NSRect(x: 0, y: 0, width: 800, height: 400).fill()
        image.unlockFocus()
        let generator = ThumbnailGenerator(maxDimension: 100)
        let png = try generator.generatePNG(from: image)
        guard let thumb = NSImage(data: png) else {
            XCTFail("invalid thumb")
            return
        }
        XCTAssertLessThanOrEqual(max(thumb.size.width, thumb.size.height), 100.5)
    }
}
