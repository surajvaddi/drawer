import XCTest

final class ModuleStructureIntegrationTests: XCTestCase {
    func testAppBuildsWithModuleStructure() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let pbxproj = projectRoot.appendingPathComponent("Orb.xcodeproj/project.pbxproj")
        let contents = try String(contentsOf: pbxproj, encoding: .utf8)
        for folder in ["Core", "Storage", "Capture", "UI", "Search", "AI", "Services"] {
            XCTAssertTrue(contents.contains("/* \(folder) */") || contents.contains("path = \(folder)"))
        }
    }
}
