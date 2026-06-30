import XCTest
@testable import Orb

final class AutoPasteServiceIntegrationTests: XCTestCase {
    func testAutoPasteSimulatedKeystroke() throws {
        let defaults = UserDefaults(suiteName: "orb.autopaste.int.\(UUID().uuidString)")!
        var service = AutoPasteService(defaults: defaults)
        service.isEnabled = false
        XCTAssertNoThrow(try service.simulatePaste())
    }
}
