import XCTest
@testable import Orb

final class ThumbnailGeneratorIntegrationTests: XCTestCase {
    func testThumbnailSavedAsBlobKindThumbnail() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-thumb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let store = BlobStore(paths: paths)
        let generator = ThumbnailGenerator(maxDimension: 64)

        let image = NSImage(size: NSSize(width: 200, height: 100))
        image.lockFocus()
        NSColor.green.setFill()
        NSRect(x: 0, y: 0, width: 200, height: 100).fill()
        image.unlockFocus()
        let png = try generator.generatePNG(from: image)
        let stored = try store.write(data: png, kind: .thumbnail, preferredName: "thumb.png")
        XCTAssertTrue(stored.path.contains("thumbnails"))
        try? FileManager.default.removeItem(at: root)
    }
}

import AppKit
