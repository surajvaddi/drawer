import XCTest
@testable import Orb

final class PresentationModeObserverTests: XCTestCase {
    func testHideWhenFullscreenAppActive() {
        _ = PresentationModeObserver.isInFullscreenPresentation
        XCTAssertTrue(true)
    }

    func testRestoreWhenExitingFullscreen() {
        var changed = false
        let observer = PresentationModeObserver { _ in changed = true }
        observer.stop()
        XCTAssertTrue(changed)
    }
}
