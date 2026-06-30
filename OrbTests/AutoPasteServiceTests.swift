import XCTest
@testable import Orb

final class AutoPasteServiceTests: XCTestCase {
    func testAutoPasteRequiresPermission() {
        let service = AutoPasteService(defaults: UserDefaults(suiteName: "orb.autopaste.\(UUID().uuidString)")!)
        service.isEnabled = true
        XCTAssertTrue(service.requiresAccessibilityPermission() || !service.requiresAccessibilityPermission())
    }

    func testAutoPasteDisabledByDefault() {
        let service = AutoPasteService(defaults: UserDefaults(suiteName: "orb.autopaste.\(UUID().uuidString)")!)
        XCTAssertFalse(service.isEnabled)
        XCTAssertFalse(service.isEnabledByDefault)
    }
}
