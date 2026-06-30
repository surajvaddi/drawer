import XCTest
@testable import Orb

final class DrawerToggleShortcutIntegrationTests: XCTestCase {
    func testToggleDrawerShortcutEndToEnd() {
        let hotkeys = HotkeyService()
        var isOpen = false
        let shortcut = DrawerToggleShortcut(
            hotkeys: hotkeys,
            isDrawerOpen: { isOpen },
            setDrawerOpen: { isOpen = $0 }
        )
        shortcut.register()
        hotkeys.invoke(.toggleDrawer)
        XCTAssertTrue(isOpen)
        hotkeys.invoke(.toggleDrawer)
        XCTAssertFalse(isOpen)
    }
}
