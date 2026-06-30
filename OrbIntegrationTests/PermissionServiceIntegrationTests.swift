import XCTest
@testable import Orb

final class PermissionServiceIntegrationTests: XCTestCase {
    func testPermissionServiceReadsSystemState() {
        let service = PermissionService()
        XCTAssertEqual(service.status(for: .clipboard), .granted)
        XCTAssertNotNil(service.allStatuses()[.screenRecording])
    }
}
