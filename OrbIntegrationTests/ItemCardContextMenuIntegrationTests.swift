import XCTest
@testable import Orb

final class ItemCardContextMenuIntegrationTests: XCTestCase {
    func testDeleteFromContextMenuRemovesItem() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-menu-del-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let repository = ItemRepository(manager: manager)
        let saved = try repository.create(Item(type: .text, title: "Delete"))
        try repository.delete(id: saved.id)
        XCTAssertNil(try repository.fetch(id: saved.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
