import XCTest
@testable import Orb

final class AISettingsViewTests: XCTestCase {
    func testDisableAIStopsEnqueue() {
        var settings = AppSettings()
        settings.aiEnabled = false
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.evaluate(operation: "title", usesCloud: false)
        if case .blocked(let reason) = decision {
            XCTAssertTrue(reason.lowercased().contains("disabled"))
        } else {
            XCTFail("Disabled AI should block operations")
        }
    }
}
