import AppKit
import Foundation

struct ScreenshotItemActions: Sendable {
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

    func copyImage(itemID: String) throws {
        guard let blob = try blobs.list(itemId: itemID, kind: .original).first else {
            throw OrbError.invalidData("Missing screenshot blob")
        }
        let data = try blobStore.read(path: blob.localPath)
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .png)
    }

    func copyOCRText(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func openInPreview(itemID: String) throws {
        guard let blob = try blobs.list(itemId: itemID, kind: .original).first else {
            throw OrbError.invalidData("Missing screenshot blob")
        }
        workspace.open(URL(fileURLWithPath: blob.localPath))
    }
}
