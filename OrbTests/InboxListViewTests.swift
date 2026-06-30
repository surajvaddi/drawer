import XCTest
@testable import Orb

final class InboxListViewTests: XCTestCase {
    func testInboxListsMostRecentFirst() {
        let old = Item(type: .text, title: "Old", preview: "", createdAt: Date(timeIntervalSince1970: 1), drawerId: DefaultDataSeeder.inboxDrawerID)
        let new = Item(type: .text, title: "New", preview: "", createdAt: Date(), drawerId: DefaultDataSeeder.inboxDrawerID)
        let model = DrawerViewModel(items: [old, new])
        XCTAssertEqual(model.inboxItems.first?.title, "New")
    }

    func testEmptyInboxShowsPlaceholder() {
        let model = DrawerViewModel(items: [])
        XCTAssertTrue(model.inboxItems.isEmpty)
    }
}
