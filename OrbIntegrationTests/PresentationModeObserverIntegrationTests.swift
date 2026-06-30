import XCTest
@testable import Orb

final class PresentationModeObserverIntegrationTests: XCTestCase {
    func testOrbHiddenDuringPresentationMode() {
        var lastValue = false
        let observer = PresentationModeObserver { value in lastValue = value }
        XCTAssertEqual(lastValue, PresentationModeObserver.isInFullscreenPresentation)
        observer.stop()
    }
}
