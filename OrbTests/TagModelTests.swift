import XCTest
@testable import Orb

final class TagModelTests: XCTestCase {
    func testTagNameNormalization() {
        XCTAssertEqual(Tag.normalize("  Concrete  "), "concrete")
    }

    func testItemTagLinkage() {
        let link = ItemTag(itemId: "item-1", tagId: "tag-1")
        XCTAssertEqual(link.itemId, "item-1")
        XCTAssertEqual(link.tagId, "tag-1")
    }
}
