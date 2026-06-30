import Foundation

struct ScreenshotShortcut: Sendable {
    let hotkeys: HotkeyService
    var onStartCapture: () -> Void

    func register() {
        hotkeys.register(.screenshot, handler: onStartCapture)
    }
}
