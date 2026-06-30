import XCTest
@testable import Orb

final class ItemFactoryIntegrationTests: XCTestCase {
    func testFactoryProducesValidItemForEachType() {
        let factory = ItemFactory()
        for type in [ItemType.text, .url, .code, .file, .screenshot] {
            let item = factory.makeItem(
                from: CapturePayload(type: type, title: "Title", preview: "Preview", method: .manualNote)
            )
            XCTAssertEqual(item.type, type)
        }
    }
}
