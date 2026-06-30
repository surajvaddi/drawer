import XCTest
import SQLite3
@testable import Orb

final class MigrationV3Tests: XCTestCase {
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v3-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: [MigrationV1(), MigrationV2(), MigrationV3()])
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testFTSTableTriggersExist() throws {
        let triggers = try triggerNames()
        XCTAssertTrue(triggers.contains("items_fts_insert"))
        XCTAssertTrue(triggers.contains("items_fts_update"))
        XCTAssertTrue(triggers.contains("items_fts_delete"))
    }

    func testEmbeddingDimensionsColumn() throws {
        let columns = try tableColumns("embeddings")
        XCTAssertTrue(columns.contains("vector_json"))
        XCTAssertTrue(columns.contains("text_hash"))
        XCTAssertTrue(columns.contains("model"))
    }

    private func triggerNames() throws -> Set<String> {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT name FROM sqlite_master WHERE type='trigger';", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("failed to list triggers")
        }
        var names = Set<String>()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 0) {
                names.insert(String(cString: name))
            }
        }
        return names
    }

    private func tableColumns(_ table: String) throws -> Set<String> {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "PRAGMA table_info(\(table));", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("pragma failed")
        }
        var columns = Set<String>()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 1) {
                columns.insert(String(cString: name))
            }
        }
        return columns
    }
}
