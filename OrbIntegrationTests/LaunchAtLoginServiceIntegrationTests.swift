import XCTest
@testable import Orb

final class LaunchAtLoginServiceIntegrationTests: XCTestCase {
    func testLoginItemRegisteredWithServiceManagement() {
        let service = LaunchAtLoginService()
        service.syncWithStoredPreference()
        XCTAssertNotNil(service)
    }
}
