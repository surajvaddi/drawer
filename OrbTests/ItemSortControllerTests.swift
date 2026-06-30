import XCTest
@testable import Orb

final class ItemSortControllerTests: XCTestCase {
    func testSortByLastAccessed() {
        let old = Item(type: .text, title: "Old", lastAccessedAt: Date(timeIntervalSince1970: 1))
        let recent = Item(type: .text, title: "Recent", lastAccessedAt: Date())
        var controller = ItemSortController()
        controller.option = .lastAccessed
        XCTAssertEqual(controller.sort([old, recent]).first?.title, "Recent")
    }

    func testSortByTitleCaseInsensitive() {
        var controller = ItemSortController()
        controller.option = .alphabetical
        let items = [Item(type: .text, title: "beta"), Item(type: .text, title: "Alpha")]
        XCTAssertEqual(controller.sort(items).first?.title, "Alpha")
    }
}
