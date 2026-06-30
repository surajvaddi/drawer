import XCTest
@testable import Orb

final class AutoPastePermissionGateTests: XCTestCase {
    func testAutoPasteBlockedWithoutAXPermission() {
        let gate = AutoPastePermissionGate(permissions: PermissionService())
        if PermissionService().status(for: .accessibility) != .granted {
            XCTAssertFalse(gate.canAutoPaste())
        }
    }
}
