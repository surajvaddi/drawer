import XCTest
@testable import Orb

final class DrawerModelTests: XCTestCase {
    func testDrawerRootAndNestedPaths() {
        let root = Drawer(id: "r", name: "Jobs", sortOrder: 0)
        let child = Drawer(id: "c", name: "Modal", parentDrawerId: "r", sortOrder: 1)
        XCTAssertEqual(child.path(in: [root, child]), "Jobs / Modal")
    }

    func testDrawerSortOrderComparison() {
        let a = Drawer(name: "B", sortOrder: 2)
        let b = Drawer(name: "A", sortOrder: 1)
        XCTAssertTrue(Drawer.sortByOrder(b, a))
    }
}
