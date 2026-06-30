import AppKit
import Foundation

protocol WorkspaceOpening: Sendable {
    func open(_ url: URL)
}

struct NSWorkspaceOpener: WorkspaceOpening {
    func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}

struct LinkItemActions: Sendable {
    let pasteboard: PasteboardProviding
    let workspace: any WorkspaceOpening

    init(pasteboard: PasteboardProviding = NSPasteboard.general, workspace: any WorkspaceOpening = NSWorkspaceOpener()) {
        self.pasteboard = pasteboard
        self.workspace = workspace
    }

    func copyURL(_ item: Item) throws {
        let url = item.sourceURL ?? item.contentText ?? item.title
        pasteboard.clearContents()
        pasteboard.setString(url, forType: .string)
        pasteboard.setString(url, forType: .URL)
    }

    func copyMarkdownLink(_ item: Item) throws {
        let url = item.sourceURL ?? item.contentText ?? item.title
        let markdown = "[\(item.title)](\(url))"
        pasteboard.clearContents()
        pasteboard.setString(markdown, forType: .string)
    }

    func openInBrowser(_ item: Item) throws {
        let urlString = item.sourceURL ?? item.contentText ?? item.title
        guard let url = URL(string: urlString) else {
            throw OrbError.invalidData("Invalid URL")
        }
        workspace.open(url)
    }
}
