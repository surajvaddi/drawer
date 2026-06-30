import AppKit
import Foundation

struct DocumentItemActions: Sendable {
    let pasteboard: PasteboardProviding
    let blobStore: BlobStore
    let blobs: BlobRepository
    let workspace: any WorkspaceOpening

    init(
        pasteboard: PasteboardProviding = NSPasteboard.general,
        blobStore: BlobStore,
        blobs: BlobRepository,
        workspace: any WorkspaceOpening = NSWorkspaceOpener()
    ) {
        self.pasteboard = pasteboard
        self.blobStore = blobStore
        self.blobs = blobs
        self.workspace = workspace
    }

    func revealInFinder(item: Item) throws {
        let path = try resolvedPath(for: item)
        workspace.open(path.deletingLastPathComponent())
    }

    func open(item: Item) throws {
        let path = try resolvedPath(for: item)
        workspace.open(path)
    }

    func copyFile(item: Item) throws {
        let path = try resolvedPath(for: item)
        let data = try Data(contentsOf: path)
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .fileURL)
        pasteboard.setString(path.path, forType: .string)
    }

    func copyPath(item: Item) {
        pasteboard.clearContents()
        pasteboard.setString(item.contentText ?? item.title, forType: .string)
    }

    private func resolvedPath(for item: Item) throws -> URL {
        if let blob = try blobs.list(itemId: item.id, kind: .original).first {
            return URL(fileURLWithPath: blob.localPath)
        }
        if let path = item.contentText {
            return URL(fileURLWithPath: path)
        }
        throw OrbError.invalidData("Missing file path")
    }
}
