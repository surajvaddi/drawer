import XCTest
@testable import Orb

final class TextItemActionsIntegrationTests: XCTestCase {
    func testEditTextUpdatesSearchIndex() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-text-edit-fts-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let repository = ItemRepository(manager: manager)
        let saved = try repository.create(Item(type: .text, title: "Old", contentText: "Old"))
        _ = try TextItemActions(pasteboard: MockPasteboard(), repository: repository)
            .editContent(saved, newText: "New searchable body")
        XCTAssertGreaterThan(try coordinator.ftsRowCount(for: saved.id), 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
