import XCTest
@testable import Orb

final class FileImportValidatorIntegrationTests: XCTestCase {
    func testValidateRealPDFFixture() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("orb-real-\(UUID().uuidString).pdf")
        try TestFixtures.minimalPDFData().write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let result = try FileImportValidator().validate(url: url)
        XCTAssertTrue(result.allowed)
    }
}
