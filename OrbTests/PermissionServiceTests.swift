import XCTest
@testable import Orb

final class PermissionServiceTests: XCTestCase {
    func testPermissionStatesMappedCorrectly() {
        let service = PermissionService()
        let statuses = service.allStatuses()
        XCTAssertEqual(statuses[.clipboard], .granted)
        XCTAssertTrue([.granted, .denied, .notDetermined, .restricted].contains(statuses[.accessibility]!))
        XCTAssertTrue([.granted, .denied].contains(statuses[.screenRecording]!))
        XCTAssertEqual(statuses[.files], .notDetermined)
    }
}
