import XCTest
@testable import Orb

final class AIPrivacyGateIntegrationTests: XCTestCase {
    func testSensitiveItemRequiresPermissionState() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiAskBeforeCloud = true
        settings.aiLocalOnly = false
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.evaluate(operation: "facts", usesCloud: true)
        if case .requiresConfirmation(let reason) = decision {
            XCTAssertTrue(reason.lowercased().contains("cloud"))
        } else {
            XCTFail("Expected confirmation for sensitive cloud operation")
        }
    }
}
