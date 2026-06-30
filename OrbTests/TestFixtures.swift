import Foundation
@testable import Orb

struct MockLinkMetadataFetcher: LinkMetadataFetching {
    var metadata: LinkMetadata

    init(title: String? = "Example Site", faviconURL: URL? = URL(string: "https://example.com/favicon.ico")) {
        metadata = LinkMetadata(title: title, faviconURL: faviconURL)
    }

    func fetchMetadata(for urlString: String) async throws -> LinkMetadata {
        metadata
    }
}

final class MockWorkspaceOpener: WorkspaceOpening {
    private(set) var openedURLs: [URL] = []

    func open(_ url: URL) {
        openedURLs.append(url)
    }
}

enum TestFixtures {
    static func pngData(width: Int = 40, height: Int = 20, color: NSColor = .white) -> Data {
        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()
        color.setFill()
        NSRect(x: 0, y: 0, width: width, height: height).fill()
        image.unlockFocus()
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            fatalError("unable to build png")
        }
        return png
    }

    static func minimalPDFData() -> Data {
        let document = PDFDocument()
        let page = PDFPage(image: NSImage(size: NSSize(width: 100, height: 100))) ?? PDFPage()
        document.insert(page, at: 0)
        return document.dataRepresentation() ?? Data()
    }
}

import AppKit
import PDFKit
