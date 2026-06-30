import XCTest
@testable import Orb

final class SensitiveSaveAlertIntegrationTests: XCTestCase {
    func testSensitiveClipboardShowsWarning() {
        let alert = SensitiveSaveAlert(findings: [.awsAccessKey])
        XCTAssertFalse(alert.findings.isEmpty)
        var drawerID: String? = DefaultDataSeeder.inboxDrawerID
        XCTAssertTrue(SensitiveSaveController().apply(choice: .saveToPrivateDrawer, itemDrawerID: &drawerID))
    }
}
