import AppKit
import XCTest
@testable import Orb

final class PresentationModeObserverTests: XCTestCase {
    func testHideWhenFullscreenAppActive() {
        let isFullscreen = PresentationModeObserver.isInFullscreenPresentation
        XCTAssertEqual(isFullscreen, NSApp.presentationOptions.contains(.fullScreen))
    }

    func testRestoreWhenExitingFullscreen() {
        var changed = false
        let observer = PresentationModeObserver { _ in changed = true }
        observer.stop()
        XCTAssertTrue(changed)
    }
}
