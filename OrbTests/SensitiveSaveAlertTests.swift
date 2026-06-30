import XCTest
@testable import Orb

final class SensitiveSaveAlertTests: XCTestCase {
    func testDontSaveAbortsPipeline() {
        let controller = SensitiveSaveController()
        var drawerID: String? = DefaultDataSeeder.inboxDrawerID
        let shouldSave = controller.apply(choice: .dontSave, itemDrawerID: &drawerID)
        XCTAssertFalse(shouldSave)
    }

    func testSaveToPrivateRoutesToPrivateDrawer() {
        let controller = SensitiveSaveController()
        var drawerID: String? = DefaultDataSeeder.inboxDrawerID
        let shouldSave = controller.apply(choice: .saveToPrivateDrawer, itemDrawerID: &drawerID)
        XCTAssertTrue(shouldSave)
        XCTAssertEqual(drawerID, SensitiveSaveController.privateDrawerID)
    }
}
