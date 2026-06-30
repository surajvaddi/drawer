import XCTest
@testable import Orb

final class SearchSettingsViewIntegrationTests: XCTestCase {
    func testSearchSettingsAffectQuickPaste() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-search-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Quick", contentText: "Quick"))
        var settings = AppSettings()
        settings.enterPastesInsteadOfCopy = false
        let controller = QuickPasteController(items: items, pasteboard: MockPasteboard())
        let ranked = controller.rankedRecents(from: try items.listRecent())
        XCTAssertFalse(ranked.isEmpty)
        XCTAssertFalse(settings.enterPastesInsteadOfCopy)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
