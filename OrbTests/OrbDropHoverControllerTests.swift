import XCTest
@testable import Orb

final class OrbDropHoverControllerTests: XCTestCase {
    func testDragEnterSetsDragHover() throws {
        var controller = OrbDropHoverController()
        try controller.dragEntered()
        XCTAssertEqual(controller.stateMachine.state, .dragHover)
    }

    func testDragExitReturnsIdle() throws {
        var controller = OrbDropHoverController()
        try controller.dragEntered()
        try controller.dragExited()
        XCTAssertEqual(controller.stateMachine.state, .idle)
    }
}
