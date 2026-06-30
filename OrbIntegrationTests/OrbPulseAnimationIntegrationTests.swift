import XCTest
@testable import Orb

final class OrbPulseAnimationIntegrationTests: XCTestCase {
    func testClipboardChangeTriggersPulseAnimation() {
        var animation = OrbPulseAnimation()
        var machine = OrbStateMachine()
        XCTAssertTrue(animation.shouldPulse())
        try? machine.transition(to: .clipboardChanged)
        let view = OrbView(state: machine.state, pulseScale: animation.scale(forPulseTriggered: true))
        XCTAssertEqual(view.pulseScale, 1.12)
    }
}
