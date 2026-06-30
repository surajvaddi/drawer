import XCTest
@testable import Orb

final class ItemRepositoryIntegrationTests: XCTestCase {
    func testItemRepositoryPersistsAcrossReopen() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-item-repo-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)

        let manager1 = DatabaseManager(paths: paths)
        try manager1.open()
        try manager1.migrate(using: OrbMigrations.all)
        let repo1 = ItemRepository(manager: manager1)
        let saved = try repo1.create(Item(type: .url, title: "Kind Designs", sourceURL: "https://kinddesigns.com"))
        manager1.close()

        let manager2 = DatabaseManager(paths: paths)
        try manager2.open()
        let repo2 = ItemRepository(manager: manager2)
        let fetched = try repo2.fetch(id: saved.id)
        XCTAssertEqual(fetched?.title, "Kind Designs")
        XCTAssertEqual(fetched?.sourceURL, "https://kinddesigns.com")
        manager2.close()
        try? FileManager.default.removeItem(at: root)
    }
}
