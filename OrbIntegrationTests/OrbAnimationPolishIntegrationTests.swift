import XCTest
@testable import Orb

final class OrbAnimationPolishIntegrationTests: XCTestCase {
    func testOrbVisualPolishSnapshots() {
        for state in [OrbVisualState.idle, .clipboardChanged, .dragHover, .saving, .expanded] {
            XCTAssertGreaterThan(OrbAnimationPolish.scale(for: state, pulseScale: 1.05), 0)
            XCTAssertGreaterThan(OrbAnimationPolish.shadowRadius(for: state), 0)
            XCTAssertGreaterThan(OrbAnimationPolish.iconOpacity(for: state), 0)
        }
        XCTAssertEqual(OrbAnimationPolish.scale(for: .clipboardChanged, pulseScale: 1.05), 1.05)
        XCTAssertEqual(OrbAnimationPolish.shadowRadius(for: .dragHover), 12)
        XCTAssertEqual(OrbAnimationPolish.iconOpacity(for: .saving), 1.0)
    }
}
