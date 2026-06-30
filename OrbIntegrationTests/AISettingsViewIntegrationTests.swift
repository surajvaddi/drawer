import XCTest
@testable import Orb

final class AISettingsViewIntegrationTests: XCTestCase {
    func testAISettingsAffectPrivacyGate() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiLocalOnly = true
        var gate = AIPrivacyGate(settings: settings)
        XCTAssertNotEqual(gate.canRunWithCloud(operation: "tags"), .allowed)

        settings.aiLocalOnly = false
        settings.aiAskBeforeCloud = false
        gate = AIPrivacyGate(settings: settings)
        XCTAssertEqual(gate.canRunWithCloud(operation: "tags"), .allowed)
    }
}
