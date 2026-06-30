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
    private var currentPollInterval: TimeInterval
    private let activePollInterval: TimeInterval
    private let pausedPollInterval: TimeInterval
    private let maxPausedPollInterval: TimeInterval

    init(
        pasteboard: PasteboardProviding = NSPasteboard.general,
        settings: ClipboardWatchSettings = ClipboardWatchSettings(),
        activePollInterval: TimeInterval = 0.5,
        pausedPollInterval: TimeInterval = 2.0,
        maxPausedPollInterval: TimeInterval = 8.0
    ) {
        self.pasteboard = pasteboard
        self.lastChangeCount = pasteboard.changeCount
        self.settings = settings
        self.activePollInterval = activePollInterval
        self.pausedPollInterval = pausedPollInterval
        self.maxPausedPollInterval = maxPausedPollInterval
        self.currentPollInterval = activePollInterval
    }

    func start(pollInterval: TimeInterval = 0.5) {
        stop()
        currentPollInterval = pollInterval
        scheduleTimer(interval: currentPollInterval)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @discardableResult
    func poll() -> Bool {
        if settings.isPaused {
            applyPausedBackoff()
            return false
        }
        resetPollIntervalIfNeeded()
        guard !settings.shouldIgnoreCurrentApp() else { return false }
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return false }
        lastChangeCount = current
        NotificationCenter.default.post(name: .orbClipboardDidChange, object: nil)
        return true
    }

    private func applyPausedBackoff() {
        let next = min(currentPollInterval * 1.5, maxPausedPollInterval)
        guard next > currentPollInterval else { return }
        currentPollInterval = next
        scheduleTimer(interval: currentPollInterval)
    }

    private func resetPollIntervalIfNeeded() {
        guard currentPollInterval != activePollInterval else { return }
        currentPollInterval = activePollInterval
        scheduleTimer(interval: currentPollInterval)
    }

    private func scheduleTimer(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }
}
