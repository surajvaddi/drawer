import Foundation

struct DrawerToggleShortcut: Sendable {
    let hotkeys: HotkeyService
  var isDrawerOpen: () -> Bool
    var setDrawerOpen: (Bool) -> Void

    func register() {
        hotkeys.register(.toggleDrawer) {
            toggle()
        }
    }

    func toggle() {
        setDrawerOpen(!isDrawerOpen())
    }
}
