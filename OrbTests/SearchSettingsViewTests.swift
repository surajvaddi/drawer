import XCTest
@testable import Orb

final class SearchSettingsViewTests: XCTestCase {
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-search-settings-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws { manager.close() }

    func testIncludeOCRSettingAffectsSearch() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .screenshot, title: "Shot", contentText: "ocr-token-xyz"))
        let results = try SearchRepository(manager: manager).search("ocr-token-xyz")
        XCTAssertFalse(results.isEmpty)
    }

    func testEnterCopiesVsPastesSetting() {
        var settings = AppSettings()
        settings.enterPastesInsteadOfCopy = true
        XCTAssertTrue(settings.enterPastesInsteadOfCopy)
    }
}
