import XCTest
@testable import Orb

final class ItemPinControllerIntegrationTests: XCTestCase {
    func testPinnedItemVisibleInPinnedSection() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-pin-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let repository = ItemRepository(manager: manager)
        let controller = ItemPinController(repository: repository)
        let saved = try repository.create(Item(type: .text, title: "Pinned"))
        _ = try controller.togglePin(item: saved)
        let pinned = try repository.listPinned()
        XCTAssertTrue(pinned.contains { $0.id == saved.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
