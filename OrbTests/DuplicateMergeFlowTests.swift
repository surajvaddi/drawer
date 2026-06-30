import XCTest
@testable import Orb

final class DuplicateMergeFlowTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testMergeCombinesTagsAndNotes() throws {
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let tag = try tags.create(name: "merge-tag")
        let primary = try items.create(Item(type: .text, title: "Primary", contentText: "primary", userNote: nil))
        var duplicate = try items.create(Item(type: .text, title: "Dup", contentText: "dup body", userNote: "note from dup"))
        try tags.link(itemId: duplicate.id, tagId: tag.id)
        let deletion = ItemDeletionService(items: items, blobs: BlobRepository(manager: manager), annotations: AIAnnotationRepository(manager: manager), blobStore: BlobStore(paths: paths))
        let merged = try DuplicateMergeFlow(items: items, tags: tags, deletion: deletion).merge(primaryID: primary.id, duplicateID: duplicate.id)
        XCTAssertEqual(merged.userNote, "note from dup")
        XCTAssertFalse(try tags.tags(for: primary.id).isEmpty)
    }

    func testReplaceDeletesOlderItem() throws {
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let primary = try items.create(Item(type: .text, title: "Keep", contentText: "keep"))
        let duplicate = try items.create(Item(type: .text, title: "Remove", contentText: "remove"))
        let deletion = ItemDeletionService(items: items, blobs: BlobRepository(manager: manager), annotations: AIAnnotationRepository(manager: manager), blobStore: BlobStore(paths: paths))
        _ = try DuplicateMergeFlow(items: items, tags: tags, deletion: deletion).merge(primaryID: primary.id, duplicateID: duplicate.id)
        XCTAssertNil(try items.fetch(id: duplicate.id))
        XCTAssertNotNil(try items.fetch(id: primary.id))
    }
}
