import XCTest
@testable import Orb

final class HotkeyServiceTests: XCTestCase {
    func testRegisterDefaultShortcuts() {
        let service = HotkeyService()
        var saved = false
        service.registerDefaults(onSaveClipboard: { saved = true })
        XCTAssertEqual(service.registered.count, 4)
        service.invoke(.saveClipboard)
        XCTAssertTrue(saved)
    }

    func testUnregisterOnDeinit() {
        weak var weakService: HotkeyService?
        autoreleasepool {
            let service = HotkeyService()
            service.register(.quickPaste) {}
            weakService = service
            service.unregisterAll()
        }
        XCTAssertNil(weakService)
    }
}
