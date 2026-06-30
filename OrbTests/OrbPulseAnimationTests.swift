import XCTest
@testable import Orb

final class OrbPulseAnimationTests: XCTestCase {
    func testPulseTriggersOncePerEvent() {
        var animation = OrbPulseAnimation(cooldown: 1)
        XCTAssertTrue(animation.shouldPulse())
        XCTAssertFalse(animation.shouldPulse())
    }

    func testPulseDoesNotRepeatWhileIdle() {
        var animation = OrbPulseAnimation(cooldown: 10)
        XCTAssertEqual(animation.scale(forPulseTriggered: false), 1.0)
        XCTAssertEqual(animation.scale(forPulseTriggered: true), 1.12)
    }
}
