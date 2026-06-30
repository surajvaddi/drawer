import XCTest
@testable import Orb

final class MenuBarControllerTests: XCTestCase {
    func testMenuBarToggleOrbVisibility() {
        var toggled = false
        let controller = MenuBarController(onToggleDrawer: { toggled = true }, onOpenLibrary: {})
        controller.install()
        controller.uninstall()
        XCTAssertFalse(toggled)
    }
}
