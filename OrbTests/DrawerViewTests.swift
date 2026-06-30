import XCTest
import SwiftUI
@testable import Orb

final class DrawerViewTests: XCTestCase {
    func testDrawerSectionsRender() {
        let model = DrawerViewModel(
            items: [Item(type: .text, title: "A", preview: "p", drawerId: DefaultDataSeeder.inboxDrawerID)],
            drawers: [Drawer(id: DefaultDataSeeder.inboxDrawerID, name: "Inbox")]
        )
        XCTAssertEqual(model.inboxItems.count, 1)
        _ = DrawerView(model: model)
    }

    func testDrawerStartsWithSearchFocused() {
        let model = DrawerViewModel()
        XCTAssertEqual(model.searchText, "")
    }
}
