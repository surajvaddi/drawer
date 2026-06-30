import AppKit
import Foundation

struct PresentationModeObserver: @unchecked Sendable {
    private var observer: NSObjectProtocol?

    init(onChange: @escaping @Sendable (Bool) -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: .main
        ) { _ in
            onChange(Self.isInFullscreenPresentation)
        }
        onChange(Self.isInFullscreenPresentation)
    }

    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    static var isInFullscreenPresentation: Bool {
        NSApp.presentationOptions.contains(.fullScreen)
    }
}
