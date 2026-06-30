import XCTest
@testable import Orb

final class ItemFactoryTests: XCTestCase {
    func testFactorySetsTypeAndTimestamps() {
        let item = ItemFactory().makeItem(
            from: CapturePayload(type: .text, title: "T", preview: "P", contentText: "body", method: .clipboardSave)
        )
        XCTAssertEqual(item.type, .text)
        XCTAssertFalse(item.id.isEmpty)
    }

    func testFactoryAssignsInboxDrawerByDefault() {
        let item = ItemFactory().makeItem(
            from: CapturePayload(type: .text, title: "T", preview: "P", method: .clipboardSave)
        )
        XCTAssertEqual(item.drawerId, DefaultDataSeeder.inboxDrawerID)
    }
}
