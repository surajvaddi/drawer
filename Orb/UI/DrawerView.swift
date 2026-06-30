import SwiftUI

struct DrawerViewModel {
    var searchText: String = ""
    var items: [Item] = []
    var drawers: [Drawer] = []
    var selectedDrawerID: String? = DefaultDataSeeder.inboxDrawerID

    var inboxItems: [Item] {
        items
            .filter { $0.drawerId == DefaultDataSeeder.inboxDrawerID && !$0.isArchived }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func items(for drawerID: String) -> [Item] {
        items.filter { $0.drawerId == drawerID && !$0.isArchived }
    }
}

struct DrawerView: View {
    @State private var model: DrawerViewModel
    @FocusState private var searchFocused: Bool

    var onSaveClipboard: () -> Void = {}
    var onScreenshot: () -> Void = {}
    var onNewDrawer: () -> Void = {}

    init(model: DrawerViewModel = DrawerViewModel(), onSaveClipboard: @escaping () -> Void = {}, onScreenshot: @escaping () -> Void = {}, onNewDrawer: @escaping () -> Void = {}) {
        _model = State(initialValue: model)
        self.onSaveClipboard = onSaveClipboard
        self.onScreenshot = onScreenshot
        self.onNewDrawer = onNewDrawer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DrawerSearchBar(text: $model.searchText)
                .focused($searchFocused)
            QuickActionsRow(
                onSaveClipboard: onSaveClipboard,
                onScreenshot: onScreenshot,
                onNewDrawer: onNewDrawer
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    InboxListView(items: filteredInboxItems)
                    DrawerListView(
                        drawers: model.drawers,
                        selectedDrawerID: $model.selectedDrawerID,
                        itemsForDrawer: model.items(for:)
                    )
                }
            }
        }
        .padding(12)
        .frame(minWidth: DrawerPanel.defaultWidth - 24)
        .onAppear { searchFocused = true }
    }

    private var filteredInboxItems: [Item] {
        guard !model.searchText.isEmpty else { return model.inboxItems }
        let query = model.searchText.lowercased()
        return model.inboxItems.filter {
            $0.title.lowercased().contains(query) || $0.preview.lowercased().contains(query)
        }
    }
}

#Preview {
    DrawerView()
        .frame(width: 360, height: 500)
}
