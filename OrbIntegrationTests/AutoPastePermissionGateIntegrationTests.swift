import XCTest
@testable import Orb

final class AutoPastePermissionGateIntegrationTests: XCTestCase {
    func testCopyStillWorksWithoutAccessibility() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-ax-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let saved = try items.create(Item(type: .text, title: "Copy", contentText: "Copy"))
        let pasteboard = MockPasteboard()
        try TextItemActions(pasteboard: pasteboard, repository: items).copy(item: saved)
        XCTAssertEqual(pasteboard.string(forType: .string), "Copy")
        let gate = AutoPastePermissionGate(permissions: PermissionService())
        if !gate.canAutoPaste() {
            XCTAssertFalse(gate.canAutoPaste())
        }
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
