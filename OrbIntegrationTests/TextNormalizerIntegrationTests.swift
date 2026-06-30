import XCTest
@testable import Orb

final class TextNormalizerIntegrationTests: XCTestCase {
    func testTextItemPreviewMatchesNormalizedContent() {
        let normalizer = TextNormalizer()
        let text = "  line one \n line two  "
        let preview = normalizer.preview(from: text)
        XCTAssertTrue(preview.contains("line one"))
    }
}
