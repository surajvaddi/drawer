import Foundation

struct ClipboardPreviewState: Equatable, Sendable {
    var previewText: String?
    var capturedAt: Date?
}

struct ClipboardPreviewCleaner: Sendable {
    let timeout: TimeInterval

    init(timeout: TimeInterval = 30) {
        self.timeout = timeout
    }

    func shouldClear(state: ClipboardPreviewState, now: Date = Date(), isPaused: Bool) -> Bool {
        if isPaused { return true }
        guard let capturedAt = state.capturedAt else { return false }
        return now.timeIntervalSince(capturedAt) >= timeout
    }

    func clearedState() -> ClipboardPreviewState {
        ClipboardPreviewState(previewText: nil, capturedAt: nil)
    }
}
