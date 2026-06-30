import XCTest
@testable import Orb

final class SearchRepositoryTests: XCTestCase {
    private var manager: DatabaseManager!
    private var repository: SearchRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-search-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = SearchRepository(manager: manager)
    }

    override func tearDownWithError() throws { manager.close() }

    func testSearchFindsTitleMatch() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "UniqueAlphaTitle", contentText: "body"))
        let results = try repository.search("UniqueAlphaTitle")
        XCTAssertFalse(results.isEmpty)
    }

    func testSearchFindsOCRText() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .screenshot, title: "Shot", contentText: "invoice-number-99"))
        let results = try repository.search("invoice-number-99")
        XCTAssertFalse(results.isEmpty)
    }
}
