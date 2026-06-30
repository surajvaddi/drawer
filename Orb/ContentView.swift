import SwiftUI

struct ContentView: View {
    @StateObject private var model = OrbLaunchViewModel()

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 18) {
                OrbView(
                    diameter: 96,
                    state: model.lastSavedItem == nil ? .idle : .clipboardChanged,
                    pulseScale: model.lastSavedItem == nil ? 1 : 1.04
                )

                VStack(spacing: 6) {
                    Text("Orb")
                        .font(.system(size: 26, weight: .semibold))
                    Text(model.statusText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }

                HStack(spacing: 10) {
                    Button {
                        model.saveClipboard()
                    } label: {
                        Label("Save Clipboard", systemImage: "tray.and.arrow.down")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        model.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .help("Refresh")
                }

                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .frame(width: 260)
            .padding(24)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Drawer", systemImage: "rectangle.stack")
                        .font(.headline)
                    Spacer()
                    Text("\(model.items.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                DrawerSearchBar(text: $model.searchText)

                if model.filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No saved items",
                        systemImage: "tray",
                        description: Text("Copy something, then click Save Clipboard.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(model.filteredItems) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: item.type.iconName)
                                    .foregroundStyle(.secondary)
                                Text(item.title)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                            Text(item.preview)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.inset)
                }
            }
            .frame(minWidth: 360, minHeight: 420)
            .padding(16)
        }
        .frame(minWidth: 660, minHeight: 460)
        .background(.regularMaterial)
        .onAppear {
            model.start()
        }
    }
}

@MainActor
final class OrbLaunchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var items: [Item] = []
    @Published private(set) var lastSavedItem: Item?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isReady = false

    private var manager: DatabaseManager?
    private var coordinator: StorageCoordinator?

    var statusText: String {
        if let lastSavedItem {
            return "Saved \(lastSavedItem.title)"
        }
        if isReady {
            return "Copy something useful, then save it here."
        }
        return "Starting local vault..."
    }

    var filteredItems: [Item] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return items
        }
        let query = searchText.lowercased()
        return items.filter {
            $0.title.lowercased().contains(query)
                || $0.preview.lowercased().contains(query)
                || ($0.contentText?.lowercased().contains(query) ?? false)
        }
    }

    func start() {
        guard !isReady else { return }
        do {
            let paths = StoragePaths()
            let manager = DatabaseManager(paths: paths)
            try manager.open()
            try manager.migrate(using: OrbMigrations.all)
            try ensureInbox(manager: manager)
            self.manager = manager
            self.coordinator = StorageCoordinator(paths: paths, manager: manager)
            isReady = true
            refresh()
        } catch {
            errorMessage = "Could not start Orb: \(error.localizedDescription)"
        }
    }

    func saveClipboard() {
        do {
            if coordinator == nil {
                start()
            }
            guard let coordinator else { return }
            let saved = try ClipboardSavePipeline(coordinator: coordinator).saveCurrentClipboard()
            lastSavedItem = saved
            errorMessage = nil
            refresh()
        } catch {
            errorMessage = "Could not save clipboard: \(error.localizedDescription)"
        }
    }

    func refresh() {
        do {
            guard let manager else { return }
            items = try ItemRepository(manager: manager).listAll()
            errorMessage = nil
        } catch {
            errorMessage = "Could not load items: \(error.localizedDescription)"
        }
    }

    private func ensureInbox(manager: DatabaseManager) throws {
        let drawers = DrawerRepository(manager: manager)
        if try drawers.fetch(id: DefaultDataSeeder.inboxDrawerID) == nil {
            _ = try drawers.create(
                Drawer(
                    id: DefaultDataSeeder.inboxDrawerID,
                    name: DefaultDataSeeder.inboxDrawerName,
                    icon: "tray",
                    color: "#6B7280",
                    sortOrder: 0,
                    isPinned: true
                )
            )
        }
    }

    deinit {
        manager?.close()
    }
}

#Preview {
    ContentView()
}
