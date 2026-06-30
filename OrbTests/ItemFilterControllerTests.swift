import XCTest
@testable import Orb

final class ItemFilterControllerTests: XCTestCase {
    func testFilterByScreenshotType() {
        var controller = ItemFilterController()
        controller.criteria.types = [.screenshot]
        let items = [Item(type: .text, title: "t"), Item(type: .screenshot, title: "s")]
        XCTAssertEqual(controller.filter(items).count, 1)
    }

    func testFilterBySourceApp() {
        var controller = ItemFilterController()
        controller.criteria.sourceApps = ["safari"]
        let items = [Item(type: .text, title: "a", sourceApp: "Safari"), Item(type: .text, title: "b", sourceApp: "Notes")]
        XCTAssertEqual(controller.filter(items).first?.title, "a")
    }
}
