import XCTest
@testable import Orb

final class PermissionDegradationPolicyTests: XCTestCase {
    func testPolicyMatchesSpecSection21_3() {
        let policy = PermissionDegradationPolicy(permissions: PermissionService())
        let features = policy.availability()
        XCTAssertTrue(features.clipboardSave)
        XCTAssertTrue(features.fileImport)
        XCTAssertTrue(features.search)
    }
}
