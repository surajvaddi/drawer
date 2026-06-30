import XCTest
@testable import Orb

final class OrbDropHoverControllerIntegrationTests: XCTestCase {
    func testDropHoverShowsDropToSaveLabel() throws {
        var controller = OrbDropHoverController()
        try controller.dragEntered()
        XCTAssertEqual(controller.label, "Drop to save")
    }
}
