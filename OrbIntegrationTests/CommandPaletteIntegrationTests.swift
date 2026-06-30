import XCTest
@testable import Orb

final class CommandPaletteIntegrationTests: XCTestCase {
    func testCommandPaletteSaveClipboard() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-palette-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let mock = MockPasteboard()
        mock.setFixture(text: "palette save")
        let pipeline = ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        )
        let palette = CommandPalette(handlers: [
            "save_clipboard": { _ = try? pipeline.saveCurrentClipboard() }
        ])
        let command = palette.filter(query: "save").first!
        palette.execute(command)
        XCTAssertFalse(try ItemRepository(manager: manager).listRecent().isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
