import XCTest
@testable import Orb

final class PrivateModeControllerTests: XCTestCase {
    func testPrivateModeBlocksSave() {
        let defaults = UserDefaults(suiteName: "orb.private.\(UUID().uuidString)")!
        var controller = PrivateModeController(defaults: defaults)
        controller.isEnabled = true
        XCTAssertTrue(controller.blocksSave())
    }

    func testPrivateModeBadgeOnOrb() {
        let defaults = UserDefaults(suiteName: "orb.private.badge.\(UUID().uuidString)")!
        var controller = PrivateModeController(defaults: defaults)
        controller.isEnabled = true
        XCTAssertTrue(controller.orbBadgeVisible())
    }
}
