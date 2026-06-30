import XCTest
@testable import Orb

final class LinkMetadataFetcherIntegrationTests: XCTestCase {
    func testFetchMetadataForHTTPSURL() async throws {
        let fetcher = LinkMetadataFetcher()
        let html = "<html><head><title>Integration Title</title></head></html>"
        XCTAssertEqual(fetcher.parseTitle(from: html), "Integration Title")
        let favicon = fetcher.faviconURL(for: URL(string: "https://example.org/page")!)!
        XCTAssertTrue(favicon.absoluteString.contains("favicon.ico"))
    }
}
