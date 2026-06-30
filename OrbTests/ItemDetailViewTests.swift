import XCTest
@testable import Orb

final class ItemDetailViewTests: XCTestCase {
    func testDetailShowsFullText() {
        let item = Item(type: .text, title: "Note", preview: "short", contentText: "full body text")
        let view = ItemDetailView(item: item)
        XCTAssertEqual(view.item.contentText, "full body text")
    }

    func testDetailShowsOCRForScreenshot() {
        let item = Item(type: .screenshot, title: "Shot", preview: "Screenshot")
        let view = ItemDetailView(item: item, ocrText: "detected words")
        XCTAssertEqual(view.ocrText, "detected words")
    }
}
