import XCTest
@testable import Orb

final class OrbAnimationPolishTests: XCTestCase {
    func testAnimationStatesExist() {
        XCTAssertNotNil(OrbAnimationPolish.stateChange)
        XCTAssertNotNil(OrbAnimationPolish.pulse)
        XCTAssertNotNil(OrbAnimationPolish.saveSuccess)
        XCTAssertNotNil(OrbAnimationPolish.toastDismiss)
        XCTAssertEqual(OrbAnimationPolish.scale(for: .idle, pulseScale: 1.1), 1.0)
        XCTAssertEqual(OrbAnimationPolish.scale(for: .dragHover, pulseScale: 1.1), 1.08)
    }
}
