import XCTest
@testable import Orb

final class OrbStateMachineTests: XCTestCase {
    func testTransitionsFromIdleToClipboardChanged() throws {
        var machine = OrbStateMachine()
        try machine.transition(to: .clipboardChanged)
        XCTAssertEqual(machine.state, .clipboardChanged)
    }

    func testInvalidTransitionsRejected() {
        var machine = OrbStateMachine()
        XCTAssertThrowsError(try machine.transition(to: .saving))
    }
}
