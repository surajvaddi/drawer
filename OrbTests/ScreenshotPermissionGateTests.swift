import XCTest
@testable import Orb

final class ScreenshotPermissionGateTests: XCTestCase {
    func testCaptureBlockedWithoutPermission() {
        let gate = ScreenshotPermissionGate(permissions: PermissionService())
        if PermissionService().status(for: .screenRecording) != .granted {
            XCTAssertFalse(gate.canCapture())
        }
    }

    func testFallbackMessageShown() {
        let gate = ScreenshotPermissionGate(permissions: PermissionService())
        XCTAssertFalse(gate.fallbackMessage().isEmpty)
    }
}
