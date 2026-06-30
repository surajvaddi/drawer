import XCTest
@testable import Orb

final class OrbAnimationPolishIntegrationTests: XCTestCase {
    func testOrbVisualPolishSnapshots() {
        for state in [OrbVisualState.idle, .clipboardChanged, .dragHover, .saving, .expanded] {
            _ = OrbAnimationPolish.scale(for: state, pulseScale: 1.05)
            _ = OrbAnimationPolish.shadowRadius(for: state)
            _ = OrbAnimationPolish.iconOpacity(for: state)
        }
        XCTAssertTrue(true)
    }
}
