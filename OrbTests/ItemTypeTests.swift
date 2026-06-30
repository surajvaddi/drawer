import XCTest
@testable import Orb

final class ItemTypeTests: XCTestCase {
    func testItemTypeCodableRoundTrip() throws {
        for type in ItemType.allCases {
            let data = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(ItemType.self, from: data)
            XCTAssertEqual(decoded, type)
        }
    }

    func testAllItemTypesHaveDisplayNames() {
        for type in ItemType.allCases {
            XCTAssertFalse(type.displayName.isEmpty)
            XCTAssertFalse(type.iconName.isEmpty)
        }
    }

    func testSensitivityLevelOrdering() {
        XCTAssertTrue(SensitivityLevel.normal < SensitivityLevel.sensitive)
        XCTAssertTrue(SensitivityLevel.sensitive < SensitivityLevel.privateContent)
    }
}
