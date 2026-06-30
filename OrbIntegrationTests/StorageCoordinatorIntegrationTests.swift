import XCTest
@testable import Orb

final class StorageCoordinatorIntegrationTests: XCTestCase {
    func testSaveTextItemEndToEnd() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-coordinator-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try coordinator.saveTextItem(
            StorageCoordinator.SaveTextItemRequest(
                item: Item(type: .text, title: "End to end", contentText: "hello orb")
            )
        )
        let repo = ItemRepository(manager: manager)
        let fetched = try repo.fetch(id: saved.id)
        XCTAssertEqual(fetched?.title, "End to end")
        XCTAssertEqual(try coordinator.ftsRowCount(for: saved.id), 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
