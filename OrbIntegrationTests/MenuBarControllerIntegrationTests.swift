import XCTest
@testable import Orb

final class MenuBarControllerIntegrationTests: XCTestCase {
    func testMenuBarActionsWorkWithoutOrbClick() {
        var drawerToggled = false
        var libraryOpened = false
        let controller = MenuBarController(
            onToggleDrawer: { drawerToggled = true },
            onOpenLibrary: { libraryOpened = true },
            onQuit: {}
        )
        controller.install()
        controller.uninstall()
        XCTAssertFalse(drawerToggled)
        XCTAssertFalse(libraryOpened)
    }
}
