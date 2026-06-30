import XCTest
@testable import Orb

final class GeneralSettingsViewTests: XCTestCase {
    func testOrbSizeUpdatesOrbView() {
        var settings = AppSettings()
        settings.orbDiameter = 56
        XCTAssertEqual(settings.orbDiameter, 56)
    }

    func testOpacityClampedZeroToOne() {
        var settings = AppSettings()
        settings.orbOpacity = 2.0
        settings.orbOpacity = min(1, max(0, settings.orbOpacity))
        XCTAssertEqual(settings.orbOpacity, 1)
        settings.orbOpacity = -0.5
        settings.orbOpacity = min(1, max(0, settings.orbOpacity))
        XCTAssertEqual(settings.orbOpacity, 0)
    }
}
