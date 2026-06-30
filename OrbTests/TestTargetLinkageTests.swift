import XCTest

final class TestTargetLinkageTests: XCTestCase {
    func testTestTargetsAreLinkedToOrb() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let pbxproj = projectRoot.appendingPathComponent("Orb.xcodeproj/project.pbxproj")
        let contents = try String(contentsOf: pbxproj, encoding: .utf8)
        XCTAssertTrue(contents.contains("OrbTests"))
        XCTAssertTrue(contents.contains("OrbIntegrationTests"))
        XCTAssertTrue(contents.contains("TEST_HOST"))
    }
}
