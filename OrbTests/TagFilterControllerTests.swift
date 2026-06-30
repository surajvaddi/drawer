import XCTest
@testable import Orb

final class TagFilterControllerTests: XCTestCase {
    func testFilterReturnsOnlyTaggedItems() {
        let a = Item(type: .text, title: "A")
        let b = Item(type: .text, title: "B")
        let controller = TagFilterController(selectedTagID: "tag1")
        let filtered = controller.filter(items: [a, b], tagItemIDs: [a.id])
        XCTAssertEqual(filtered.map(\.id), [a.id])
    }

    func testClearFilterRestoresList() {
        let items = [Item(type: .text, title: "A"), Item(type: .text, title: "B")]
        let controller = TagFilterController(selectedTagID: controllerClear())
        XCTAssertEqual(controller.filter(items: items, tagItemIDs: []), items)
    }

    private func controllerClear() -> String? {
        TagFilterController().clear()
    }
}
