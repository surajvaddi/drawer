import XCTest
@testable import Orb

final class AIPrivacyGateTests: XCTestCase {
    func testPrivateDrawerSkipsCloud() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiLocalOnly = true
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.canRunWithCloud(operation: "title")
        if case .blocked(let reason) = decision {
            XCTAssertTrue(reason.lowercased().contains("cloud") || reason.lowercased().contains("local"))
        } else {
            XCTFail("Expected blocked for local-only mode")
        }
    }

    func testAskModeRequiresApproval() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiLocalOnly = false
        settings.aiAskBeforeCloud = true
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.canRunWithCloud(operation: "summary")
        if case .requiresConfirmation = decision {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected requiresConfirmation")
        }
    }
}
