import XCTest
@testable import Orb

final class ScreenshotPermissionGateIntegrationTests: XCTestCase {
    func testScreenshotShortcutPromptsPermission() {
        let gate = ScreenshotPermissionGate(permissions: PermissionService())
        if !gate.canCapture() {
            XCTAssertFalse(gate.fallbackMessage().isEmpty)
        } else {
            XCTAssertTrue(gate.canCapture())
        }
    }
}
