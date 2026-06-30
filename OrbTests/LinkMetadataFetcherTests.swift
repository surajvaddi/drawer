import XCTest
@testable import Orb

final class LinkMetadataFetcherTests: XCTestCase {
    func testParseTitleFromHTML() {
        let fetcher = LinkMetadataFetcher()
        let html = "<html><head><title>Orb Docs</title></head><body></body></html>"
        XCTAssertEqual(fetcher.parseTitle(from: html), "Orb Docs")
    }

    func testFaviconURLConstruction() {
        let fetcher = LinkMetadataFetcher()
        let url = URL(string: "https://example.com/path")!
        XCTAssertEqual(fetcher.faviconURL(for: url)?.absoluteString, "https://example.com/favicon.ico")
    }
}
