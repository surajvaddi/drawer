import XCTest
@testable import Orb

final class PrivacySettingsViewTests: XCTestCase {
    func testDeleteAllDataWipesDBAndBlobs() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-wipe-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Delete me"))
        XCTAssertEqual(try items.listRecent().count, 1)
        try Data("blob".utf8).write(to: paths.blobDirectory(for: .original).appendingPathComponent("sample.bin"))
        try DataWiper(paths: paths, manager: manager).deleteAll()
        XCTAssertEqual(try items.listRecent().count, 0)
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(at: paths.blobDirectory(for: .original), includingPropertiesForKeys: nil).isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
