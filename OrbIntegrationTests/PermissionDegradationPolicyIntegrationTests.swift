import XCTest
@testable import Orb

final class PermissionDegradationPolicyIntegrationTests: XCTestCase {
    func testAppUsableWithAllPermissionsDenied() {
        let policy = PermissionDegradationPolicy(permissions: PermissionService())
        XCTAssertTrue(policy.appUsable())
    }
}
