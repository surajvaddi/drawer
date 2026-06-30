import XCTest
@testable import Orb

final class ItemMetadataEditorIntegrationTests: XCTestCase {
    func testEditedTitleReflectsInSearchIndex() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-meta-fts-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let repository = ItemRepository(manager: manager)
        let saved = try repository.create(Item(type: .text, title: "Alpha", contentText: "Alpha"))
        let editor = ItemMetadataEditor(repository: repository)
        _ = try editor.rename(item: saved, title: "Beta Title")
        XCTAssertGreaterThan(try coordinator.ftsRowCount(for: saved.id), 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
