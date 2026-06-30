import XCTest
@testable import Orb

final class ErrorReporterIntegrationTests: XCTestCase {
    func testSaveFailureShowsToastWithoutCrash() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let reporter = ErrorReporter(paths: paths)
        struct SaveError: Error {}
        reporter.report(SaveError(), context: "save")
        XCTAssertFalse(reporter.recentReports().isEmpty)
        try? FileManager.default.removeItem(at: root)
    }
}
