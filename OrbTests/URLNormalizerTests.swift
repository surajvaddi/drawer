import XCTest
@testable import Orb

final class URLNormalizerTests: XCTestCase {
    func testDetectURLInText() {
        XCTAssertTrue(URLNormalizer.isURL("https://kinddesigns.com/research"))
        XCTAssertFalse(URLNormalizer.isURL("not a url"))
    }

    func testNormalizeRemovesTrackingParams() {
        let normalized = URLNormalizer.normalize("https://example.com/path?utm_source=twitter&id=1")
        XCTAssertFalse(normalized.contains("utm_source"))
        XCTAssertTrue(normalized.contains("id=1"))
    }
}
