import XCTest
import SQLite3
@testable import Orb

final class MigrationV2Tests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v2-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: [MigrationV1(), MigrationV2()])
        try seedItemAndTag()
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testForeignKeysEnforced() throws {
        XCTAssertThrowsError(try manager.exec(
            "INSERT INTO item_tags(item_id, tag_id) VALUES ('missing-item', 'tag-1');"
        ))
    }

    func testItemTagUniqueConstraint() throws {
        try manager.exec("INSERT INTO item_tags(item_id, tag_id) VALUES ('item-1', 'tag-1');")
        XCTAssertThrowsError(try manager.exec(
            "INSERT INTO item_tags(item_id, tag_id) VALUES ('item-1', 'tag-1');"
        ))
    }

    private func seedItemAndTag() throws {
        let now = ISO8601DateFormatter().string(from: Date())
        try manager.exec(
            """
            INSERT INTO items(id, type, title, created_at, updated_at)
            VALUES ('item-1', 'text', 'Test', '\(now)', '\(now)');
            INSERT INTO tags(id, name) VALUES ('tag-1', 'research');
            """
        )
    }
}
