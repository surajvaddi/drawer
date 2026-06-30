import AppKit
import SwiftUI

struct LibraryWindow: View {
    let items: [Item]
    let drawers: [Drawer]
    var onSelectItem: (Item) -> Void

    var body: some View {
        NavigationSplitView {
            List(drawers, id: \.id) { drawer in
                Text(drawer.name)
            }
            .navigationTitle("Drawers")
        } detail: {
            List(items, id: \.id) { item in
                Button(item.title) { onSelectItem(item) }
            }
            .navigationTitle("Library")
        }
        .frame(minWidth: 720, minHeight: 480)
    }
}

struct LibraryWindowController {
    private var window: NSWindow?

    mutating func show(content: some View) {
        let hosting = NSHostingController(rootView: content)
        if window == nil {
            window = NSWindow(contentViewController: hosting)
            window?.title = "Orb Library"
            window?.setContentSize(NSSize(width: 900, height: 600))
        } else {
            window?.contentViewController = hosting
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
