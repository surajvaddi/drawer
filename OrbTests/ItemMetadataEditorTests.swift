import XCTest
@testable import Orb

final class ItemMetadataEditorTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var repository: ItemRepository!
    private var editor: ItemMetadataEditor!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-meta-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = ItemRepository(manager: manager)
        editor = ItemMetadataEditor(repository: repository)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testRenameUpdatesItemTitle() throws {
        let saved = try repository.create(Item(type: .text, title: "Before"))
        let updated = try editor.rename(item: saved, title: "After")
        XCTAssertEqual(updated.title, "After")
        XCTAssertEqual(try repository.fetch(id: saved.id)?.title, "After")
    }

    func testNotePersistsOnSave() throws {
        let saved = try repository.create(Item(type: .text, title: "Note"))
        let updated = try editor.setNote(item: saved, note: "remember this")
        XCTAssertEqual(updated.userNote, "remember this")
        XCTAssertEqual(try repository.fetch(id: saved.id)?.userNote, "remember this")
    }
}
