import XCTest
@testable import Orb

final class ItemCardViewTests: XCTestCase {
    func testCardRendersLinkIcon() {
        let item = Item(type: .url, title: "Example", preview: "https://example.com", sourceApp: "Safari")
        XCTAssertEqual(item.type.iconName, "link")
        let view = ItemCardView(item: item)
        XCTAssertEqual(view.item.title, "Example")
    }

    func testCardRendersScreenshotThumbnail() {
        let png = TestFixtures.pngData()
        let item = Item(type: .screenshot, title: "Shot", preview: "Screenshot")
        let view = ItemCardView(item: item, thumbnailData: png)
        XCTAssertNotNil(NSImage(data: png))
        XCTAssertEqual(view.thumbnailData, png)
    }
}
