import XCTest
@testable import Orb

final class ItemTypeIntegrationTests: XCTestCase {
    func testEnumsDecodeFromFixtureJSON() throws {
        let fixture = """
        {
          "itemType": "rich_clip",
          "sensitivity": "sensitive",
          "captureMethod": "drag_drop"
        }
        """
        struct Fixture: Decodable {
            let itemType: ItemType
            let sensitivity: SensitivityLevel
            let captureMethod: CaptureMethod
        }
        let decoded = try JSONDecoder().decode(Fixture.self, from: Data(fixture.utf8))
        XCTAssertEqual(decoded.itemType, .richClip)
        XCTAssertEqual(decoded.sensitivity, .sensitive)
        XCTAssertEqual(decoded.captureMethod, .dragDrop)
    }
}
