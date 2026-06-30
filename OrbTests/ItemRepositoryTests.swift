import XCTest
@testable import Orb

final class ItemRepositoryTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var repository: ItemRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-item-repo-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = ItemRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testCreateItemAssignsIDAndTimestamps() throws {
        let saved = try repository.create(Item(type: .text, title: "Hello"))
        XCTAssertFalse(saved.id.isEmpty)
        XCTAssertLessThanOrEqual(saved.createdAt.timeIntervalSinceNow, 0)
        XCTAssertLessThanOrEqual(saved.updatedAt.timeIntervalSinceNow, 0)
    }

    func testUpdateItemUpdatesUpdatedAt() throws {
        let saved = try repository.create(Item(type: .text, title: "Before"))
        let originalUpdated = saved.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        let updated = try repository.update(Item(id: saved.id, type: .text, title: "After", createdAt: saved.createdAt))
        XCTAssertEqual(updated.title, "After")
        XCTAssertGreaterThan(updated.updatedAt, originalUpdated)
    }

    func testDeleteItemRemovesRow() throws {
        let saved = try repository.create(Item(type: .text, title: "Delete me"))
        try repository.delete(id: saved.id)
        XCTAssertNil(try repository.fetch(id: saved.id))
    }
}
