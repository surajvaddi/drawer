import XCTest
@testable import Orb

final class TextNormalizerTests: XCTestCase {
    let normalizer = TextNormalizer()

    func testCollapseWhitespace() {
        XCTAssertEqual(normalizer.normalize("  hello   world \n\n test "), "hello world \n test")
    }

    func testPreviewTruncatesAtLimit() {
        let long = String(repeating: "a", count: 300)
        XCTAssertEqual(normalizer.preview(from: long).count, Item.previewLimit + 1)
    }
}
