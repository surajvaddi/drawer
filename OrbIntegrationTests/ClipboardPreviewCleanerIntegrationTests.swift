import XCTest
@testable import Orb

final class ClipboardPreviewCleanerIntegrationTests: XCTestCase {
    func testNoPersistentStorageOfUnsavedClipboard() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-preview-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let cleaner = ClipboardPreviewCleaner(timeout: 1)
        var state = ClipboardPreviewState(previewText: "ephemeral", capturedAt: Date(timeIntervalSinceNow: -5))
        if cleaner.shouldClear(state: state, isPaused: false) {
            state = cleaner.clearedState()
        }
        XCTAssertNil(state.previewText)
        XCTAssertEqual(try ItemRepository(manager: manager).listRecent().count, 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
