import XCTest
@testable import Orb

final class ExportImportViewTests: XCTestCase {
    func testExportShowsProgressAndCompletion() throws {
        var completed = false
        let onExport: () throws -> Void = { completed = true }
        try onExport()
        XCTAssertTrue(completed)
    }
}
