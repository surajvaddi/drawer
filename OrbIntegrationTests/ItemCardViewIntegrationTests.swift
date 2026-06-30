import XCTest
@testable import Orb

final class ItemCardViewIntegrationTests: XCTestCase {
    func testItemCardSnapshotForEachType() {
        for type in ItemType.allCases {
            let item = Item(type: type, title: type.displayName, preview: "preview")
            let view = ItemCardView(item: item)
            XCTAssertEqual(view.item.type, type)
        }
    }
}
