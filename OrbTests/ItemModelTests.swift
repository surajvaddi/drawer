import XCTest
@testable import Orb

final class ItemModelTests: XCTestCase {
    func testItemInitializationWithDefaults() {
        let item = Item(type: .text, title: "Hello")
        XCTAssertFalse(item.id.isEmpty)
        XCTAssertEqual(item.type, .text)
        XCTAssertFalse(item.isPinned)
        XCTAssertEqual(item.sensitivity, .normal)
    }

    func testItemPreviewTruncation() {
        let long = String(repeating: "a", count: 300)
        let item = Item(type: .text, title: "T", preview: itemPreview(long))
        XCTAssertEqual(item.preview.count, Item.previewLimit + 1)
        XCTAssertTrue(item.preview.hasSuffix("…"))
    }

    func testItemEquality() {
        let id = UUID().uuidString
        let a = Item(id: id, type: .url, title: "A")
        let b = Item(id: id, type: .url, title: "A")
        XCTAssertEqual(a, b)
    }

    private func itemPreview(_ text: String) -> String {
        Item(type: .text, title: "T").previewText(from: text)
    }
}
