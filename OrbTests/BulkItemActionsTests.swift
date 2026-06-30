import XCTest
@testable import Orb

final class BulkItemActionsTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var actions: BulkItemActions!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-bulk-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        actions = BulkItemActions(items: coordinator.items, blobs: BlobRepository(manager: manager), blobStore: coordinator.blobStore)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testBulkArchiveSetsFlag() throws {
        let items = ItemRepository(manager: manager)
        let a = try items.create(Item(type: .text, title: "A"))
        let b = try items.create(Item(type: .text, title: "B"))
        try actions.archive(itemIDs: [a.id, b.id])
        XCTAssertTrue(try items.fetch(id: a.id)?.isArchived == true)
        XCTAssertTrue(try items.fetch(id: b.id)?.isArchived == true)
    }

    func testBulkDeleteRemovesAll() throws {
        let items = ItemRepository(manager: manager)
        let a = try items.create(Item(type: .text, title: "A"))
        try actions.delete(itemIDs: [a.id])
        XCTAssertNil(try items.fetch(id: a.id))
    }
}
