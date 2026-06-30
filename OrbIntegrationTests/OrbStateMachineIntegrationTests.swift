import XCTest
@testable import Orb

final class OrbStateMachineIntegrationTests: XCTestCase {
    func testOrbViewReflectsStateMachineChanges() throws {
        var machine = OrbStateMachine()
        try machine.transition(to: .dragHover)
        let view = OrbView(state: machine.state)
        XCTAssertEqual(view.state, .dragHover)
    }
}
