import XCTest
@testable import Orb

final class DrawerToggleShortcutTests: XCTestCase {
    func testToggleOpensClosedDrawer() {
        let hotkeys = HotkeyService()
        var isOpen = false
        let shortcut = DrawerToggleShortcut(
            hotkeys: hotkeys,
            isDrawerOpen: { isOpen },
            setDrawerOpen: { isOpen = $0 }
        )
        shortcut.toggle()
        XCTAssertTrue(isOpen)
    }

    func testToggleClosesOpenDrawer() {
        let hotkeys = HotkeyService()
        var isOpen = true
        let shortcut = DrawerToggleShortcut(
            hotkeys: hotkeys,
            isDrawerOpen: { isOpen },
            setDrawerOpen: { isOpen = $0 }
        )
        shortcut.toggle()
        XCTAssertFalse(isOpen)
    }
}
