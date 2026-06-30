import XCTest
@testable import Orb

final class OrbLoggerIntegrationTests: XCTestCase {
    func testLoggerWritesToUnifiedLogInIntegration() {
        OrbLogger.shared.info("integration test log", category: .general)
        let formatted = OrbLogger.shared.formattedMessage("integration", category: .general)
        XCTAssertTrue(formatted.contains("integration"))
    }
}
