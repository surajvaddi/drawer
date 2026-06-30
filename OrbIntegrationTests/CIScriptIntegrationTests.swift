import XCTest

final class CIScriptIntegrationTests: XCTestCase {
    func testCIScriptExitsZeroOnGreenBuild() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let script = projectRoot.appendingPathComponent("scripts/test.sh")
        XCTAssertTrue(FileManager.default.fileExists(atPath: script.path))

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [script.path]
        process.currentDirectoryURL = projectRoot
        process.environment = ProcessInfo.processInfo.environment.merging([
            "ORB_CI_NESTED": "1"
        ]) { _, new in new }

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)
    }
}
