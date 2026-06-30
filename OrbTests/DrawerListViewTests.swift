import XCTest
@testable import Orb

final class DrawerListViewTests: XCTestCase {
    func testNestedDrawerIndentation() {
        let parent = Drawer(id: "p", name: "Jobs", sortOrder: 0)
        let child = Drawer(id: "c", name: "Modal", parentDrawerId: "p", sortOrder: 1)
        XCTAssertEqual(child.path(in: [parent, child]), "Jobs / Modal")
    }

    func testDrawerSelectionFiltersItems() {
        let d1 = Drawer(id: "d1", name: "Research", sortOrder: 0)
        let items = [
            Item(type: .text, title: "A", preview: "", drawerId: "d1"),
            Item(type: .text, title: "B", preview: "", drawerId: "inbox")
        ]
        let model = DrawerViewModel(items: items, drawers: [d1], selectedDrawerID: "d1")
        XCTAssertEqual(model.items(for: "d1").count, 1)
    }
}
