import AppKit
import Foundation

extension Notification.Name {
    static let orbClipboardDidChange = Notification.Name("orb.clipboardDidChange")
}

final class PasteboardMonitor: @unchecked Sendable {
    private let pasteboard: PasteboardProviding
    private var lastChangeCount: Int
    private var timer: Timer?
    private let settings: ClipboardWatchSettings

    init(pasteboard: PasteboardProviding = NSPasteboard.general, settings: ClipboardWatchSettings = ClipboardWatchSettings()) {
        self.pasteboard = pasteboard
        self.lastChangeCount = pasteboard.changeCount
        self.settings = settings
    }

    func start(pollInterval: TimeInterval = 0.5) {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @discardableResult
    func poll() -> Bool {
        guard !settings.isPaused else { return false }
        guard !settings.shouldIgnoreCurrentApp() else { return false }
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return false }
        lastChangeCount = current
        NotificationCenter.default.post(name: .orbClipboardDidChange, object: nil)
        return true
    }
}
