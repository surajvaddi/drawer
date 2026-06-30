import XCTest
@testable import Orb

final class DrawerModelIntegrationTests: XCTestCase {
    func testDrawerTreeDecodesFromFixture() throws {
        let json = """
        [
          {"id":"1","name":"Jobs","sortOrder":0,"isPinned":true,"createdAt":"2026-01-01T00:00:00Z","updatedAt":"2026-01-01T00:00:00Z"},
          {"id":"2","name":"Modal","parentDrawerId":"1","sortOrder":0,"isPinned":false,"createdAt":"2026-01-01T00:00:00Z","updatedAt":"2026-01-01T00:00:00Z"}
        ]
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let drawers = try decoder.decode([Drawer].self, from: Data(json.utf8))
        XCTAssertEqual(drawers.count, 2)
        XCTAssertEqual(drawers[1].path(in: drawers), "Jobs / Modal")
    }
}
