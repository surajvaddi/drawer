import SwiftUI

struct ItemCardContextMenu: Sendable {
    var onCopy: () -> Void
    var onMove: () -> Void
    var onTag: () -> Void
    var onDelete: () -> Void

    func performCopy() { onCopy() }
    func performMove() { onMove() }
    func performTag() { onTag() }
    func performDelete() { onDelete() }
}

private struct ItemCardContextMenuModifier: ViewModifier {
    let menu: ItemCardContextMenu

    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Copy", action: menu.onCopy)
            Button("Move to Drawer", action: menu.onMove)
            Button("Add Tags", action: menu.onTag)
            Divider()
            Button("Delete", role: .destructive, action: menu.onDelete)
        }
    }
}

extension View {
    func itemCardContextMenu(_ menu: ItemCardContextMenu) -> some View {
        modifier(ItemCardContextMenuModifier(menu: menu))
    }

    func itemCardContextMenu(
        onCopy: @escaping () -> Void,
        onMove: @escaping () -> Void,
        onTag: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        itemCardContextMenu(ItemCardContextMenu(onCopy: onCopy, onMove: onMove, onTag: onTag, onDelete: onDelete))
    }
}
