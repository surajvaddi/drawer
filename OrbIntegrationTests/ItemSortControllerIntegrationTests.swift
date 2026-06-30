import XCTest
@testable import Orb

final class ItemSortControllerIntegrationTests: XCTestCase {
    func testSortPersistsPerDrawer() throws {
        let defaults = UserDefaults(suiteName: "orb.sort.\(UUID().uuidString)")!
        let controller = ItemSortController()
        controller.savePreference(for: "drawer-1", option: .alphabetical, defaults: defaults)
        XCTAssertEqual(controller.loadPreference(for: "drawer-1", defaults: defaults), .alphabetical)
    }
}
