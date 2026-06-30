import XCTest
@testable import Orb

final class URLNormalizerIntegrationTests: XCTestCase {
    func testURLItemGetsDomainPreview() {
        let url = URLNormalizer.normalize("https://kinddesigns.com/research")
        XCTAssertEqual(URLNormalizer.domain(from: url), "kinddesigns.com")
    }
}
