import AppKit
import SwiftUI
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var orbPanel: FloatingOrbPanel?
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        OrbLogger.shared.info("Orb application did finish launching")
        showPersistentOrb()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }

    private func showPersistentOrb() {
        let size = PersistentOrbButton.idleSize
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 900, height: 700)
        let origin = NSPoint(
            x: visibleFrame.maxX - size.width - 32,
            y: visibleFrame.maxY - size.height - 72
        )
        let panel = FloatingOrbPanel(contentRect: NSRect(origin: origin, size: size))
        panel.isMovableByWindowBackground = true
        panel.contentView = NSHostingView(
            rootView: PersistentOrbButton(
                currentPanelOrigin: { [weak panel] in
                    panel?.frame.origin
                },
                movePanel: { [weak panel] origin in
                    panel?.setFrameOrigin(origin)
                },
                setPanelExpanded: { [weak panel] isExpanded in
                    guard let panel else { return }
                    let oldFrame = panel.frame
                    let oldOrbCenter = PersistentOrbButton.orbCenter(in: oldFrame, isExpanded: !isExpanded)
                    let newSize = isExpanded ? PersistentOrbButton.expandedSize : PersistentOrbButton.idleSize
                    let newOrigin = NSPoint(
                        x: oldOrbCenter.x - PersistentOrbButton.orbCenterOffset(isExpanded: isExpanded).x,
                        y: oldOrbCenter.y - PersistentOrbButton.orbCenterOffset(isExpanded: isExpanded).y
                    )
                    panel.setFrame(NSRect(origin: newOrigin, size: newSize), display: true)
                },
                openOrb: {
                    self.showMainWindow()
                },
                saveDrop: { payload in
                    self.saveDrop(payload)
                },
                loadRecentItems: {
                    self.fetchRecentItems()
                },
                deleteItem: { item in
                    self.deleteItem(item)
                }
            )
        )
        panel.orderFrontRegardless()
        orbPanel = panel
    }

    private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if mainWindow == nil {
            mainWindow = makeMainWindow()
        }
        mainWindow?.center()
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    private func makeMainWindow() -> NSWindow {
        let hostingController = NSHostingController(rootView: ContentView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Orb"
        window.setContentSize(NSSize(width: 720, height: 500))
        window.minSize = NSSize(width: 660, height: 460)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        return window
    }

    private func saveDrop(_ payload: CapturePayload) {
        do {
            let paths = StoragePaths()
            let manager = DatabaseManager(paths: paths)
            try manager.open()
            defer { manager.close() }
            try manager.migrate(using: OrbMigrations.all)
            try ensureInbox(manager: manager)

            let coordinator = StorageCoordinator(paths: paths, manager: manager)
            var payload = payload
            payload.method = .dragDrop
            let item = ItemFactory().makeItem(from: payload)
            _ = try coordinator.saveTextItem(
                StorageCoordinator.SaveTextItemRequest(
                    item: item,
                    blobData: payload.blobData,
                    blobKind: .original,
                    mimeType: payload.mimeType ?? "application/octet-stream"
                )
            )
            NotificationCenter.default.post(name: .orbDidSaveItem, object: nil)
        } catch {
            OrbLogger.shared.info("Drop save failed: \(error.localizedDescription)")
        }
    }

    private func fetchRecentItems(limit: Int = 5) -> [Item] {
        do {
            let paths = StoragePaths()
            let manager = DatabaseManager(paths: paths)
            try manager.open()
            defer { manager.close() }
            try manager.migrate(using: OrbMigrations.all)
            try ensureInbox(manager: manager)
            return try ItemRepository(manager: manager).listRecent(limit: limit)
        } catch {
            OrbLogger.shared.info("Recent item load failed: \(error.localizedDescription)")
            return []
        }
    }

    private func deleteItem(_ item: Item) -> Bool {
        do {
            let paths = StoragePaths()
            let manager = DatabaseManager(paths: paths)
            try manager.open()
            defer { manager.close() }
            try manager.migrate(using: OrbMigrations.all)
            try ItemDeletionService(
                items: ItemRepository(manager: manager),
                blobs: BlobRepository(manager: manager),
                annotations: AIAnnotationRepository(manager: manager),
                blobStore: BlobStore(paths: paths)
            ).delete(itemID: item.id)
            NotificationCenter.default.post(name: .orbDidDeleteItem, object: nil)
            return true
        } catch {
            OrbLogger.shared.info("Item delete failed: \(error.localizedDescription)")
            return false
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
}

private struct PersistentOrbButton: View {
    static let idleSize = NSSize(width: 72, height: 72)
    static let expandedSize = NSSize(width: 320, height: 280)
    private static let expandedPadding: CGFloat = 12

    var currentPanelOrigin: () -> NSPoint?
    var movePanel: (NSPoint) -> Void
    var setPanelExpanded: (Bool) -> Void
    var openOrb: () -> Void
    var saveDrop: (CapturePayload) -> Void
    var loadRecentItems: () -> [Item]
    var deleteItem: (Item) -> Bool

    @State private var visualState: OrbVisualState = .idle
    @State private var dragStartOrigin: NSPoint?
    @State private var isDragging = false
    @State private var isHovering = false
    @State private var isDropTargeted = false
    @State private var recentItems: [Item] = []

    private var isExpanded: Bool {
        !isDragging && (isHovering || isDropTargeted)
    }

    var body: some View {
        VStack(spacing: 10) {
            orbControl

            if isExpanded {
                recentItemsPanel
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(isExpanded ? Self.expandedPadding : 0)
        .frame(
            width: isExpanded ? Self.expandedSize.width : Self.idleSize.width,
            height: isExpanded ? Self.expandedSize.height : Self.idleSize.height,
            alignment: .top
        )
        .background {
            if isExpanded {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                refreshRecents()
            }
            setPanelExpanded(!isDragging && (hovering || isDropTargeted))
        }
        .onDrop(
            of: Self.acceptedDropTypes,
            isTargeted: $isDropTargeted,
            perform: handleDrop(providers:)
        )
        .onChange(of: isDropTargeted) { _, isTargeted in
            if isTargeted {
                refreshRecents()
            }
            setPanelExpanded(!isDragging && (isHovering || isTargeted))
        }
        .onReceive(NotificationCenter.default.publisher(for: .orbDidSaveItem)) { _ in
            refreshRecents()
        }
        .onReceive(NotificationCenter.default.publisher(for: .orbDidDeleteItem)) { _ in
            refreshRecents()
        }
        .animation(.easeOut(duration: 0.18), value: isExpanded)
        .help("Open Orb")
    }

    private var orbControl: some View {
        OrbView(diameter: 64, state: isDropTargeted ? .dragHover : visualState)
            .frame(width: Self.idleSize.width, height: Self.idleSize.height)
            .contentShape(Rectangle())
            .onTapGesture(perform: openOrb)
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        if dragStartOrigin == nil {
                            isDragging = true
                            dragStartOrigin = currentPanelOrigin()
                            setPanelExpanded(false)
                        }
                        guard let dragStartOrigin else { return }
                        movePanel(
                            NSPoint(
                                x: dragStartOrigin.x + value.translation.width,
                                y: dragStartOrigin.y - value.translation.height
                            )
                        )
                    }
                    .onEnded { _ in
                        dragStartOrigin = nil
                        isDragging = false
                        setPanelExpanded(isHovering || isDropTargeted)
                    }
            )
    }

    private var recentItemsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Recent", systemImage: "clock")
                    .font(.caption.weight(.semibold))
                Spacer()
                Button(action: openOrb) {
                    Image(systemName: "rectangle.expand.vertical")
                }
                .buttonStyle(.plain)
                .help("Open Orb")
            }
            .foregroundStyle(.secondary)

            if recentItems.isEmpty {
                ContentUnavailableView("No recent items", systemImage: "tray")
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 2) {
                    ForEach(recentItems.prefix(5)) { item in
                        RecentItemRow(item: item, isCompact: true) {
                            deleteRecentItem(item)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private static let acceptedDropTypes = [
        UTType.plainText.identifier,
        UTType.utf8PlainText.identifier,
        UTType.url.identifier,
        UTType.fileURL.identifier,
        UTType.png.identifier,
        UTType.jpeg.identifier,
        UTType.pdf.identifier
    ]

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        visualState = .dragHover
        if loadText(from: providers) || loadFileURL(from: providers) || loadImageData(from: providers) {
            return true
        }
        resetStateSoon()
        return false
    }

    private func loadText(from providers: [NSItemProvider]) -> Bool {
        let textTypes = [UTType.url.identifier, UTType.plainText.identifier, UTType.utf8PlainText.identifier]
        for type in textTypes {
            if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(type) }) {
                provider.loadItem(forTypeIdentifier: type, options: nil) { item, _ in
                    guard let text = string(from: item) else {
                        resetStateOnMain()
                        return
                    }
                    let payload = payloadFromText(text)
                    DispatchQueue.main.async {
                        visualState = .saving
                        saveDrop(payload)
                        resetStateSoon()
                    }
                }
                return true
            }
        }
        return false
    }

    private func loadFileURL(from providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            return false
        }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let url = fileURL(from: item) else {
                resetStateOnMain()
                return
            }
            let payload = CapturePayload(
                type: url.pathExtension.lowercased() == "pdf" ? .pdf : .file,
                title: url.lastPathComponent,
                preview: url.path,
                contentText: url.path,
                sourceURL: url.absoluteString,
                sourceApp: "Drag and Drop",
                method: .dragDrop
            )
            DispatchQueue.main.async {
                visualState = .saving
                saveDrop(payload)
                resetStateSoon()
            }
        }
        return true
    }

    private func loadImageData(from providers: [NSItemProvider]) -> Bool {
        let imageTypes = [UTType.png.identifier, UTType.jpeg.identifier, UTType.pdf.identifier]
        for type in imageTypes {
            if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(type) }) {
                provider.loadDataRepresentation(forTypeIdentifier: type) { data, _ in
                    guard let data else {
                        resetStateOnMain()
                        return
                    }
                    let isPDF = type == UTType.pdf.identifier
                    let payload = CapturePayload(
                        type: isPDF ? .pdf : .image,
                        title: isPDF ? "Dropped PDF" : "Dropped Image",
                        preview: isPDF ? "PDF from drag and drop" : "Image from drag and drop",
                        blobData: data,
                        mimeType: isPDF ? "application/pdf" : type,
                        sourceApp: "Drag and Drop",
                        method: .dragDrop
                    )
                    DispatchQueue.main.async {
                        visualState = .saving
                        saveDrop(payload)
                        resetStateSoon()
                    }
                }
                return true
            }
        }
        return false
    }

    private func payloadFromText(_ rawText: String) -> CapturePayload {
        let textNormalizer = TextNormalizer()
        let text = textNormalizer.normalize(rawText)
        if URLNormalizer.isURL(text) {
            let url = URLNormalizer.normalize(text)
            return CapturePayload(
                type: .url,
                title: URLNormalizer.domain(from: url) ?? url,
                preview: url,
                contentText: url,
                sourceURL: url,
                sourceApp: "Drag and Drop",
                method: .dragDrop
            )
        }
        return CapturePayload(
            type: CodeSnippetDetector().isCode(text) ? .code : .text,
            title: textNormalizer.title(from: text),
            preview: textNormalizer.preview(from: text),
            contentText: text,
            sourceApp: "Drag and Drop",
            method: .dragDrop
        )
    }

    private func refreshRecents() {
        recentItems = loadRecentItems()
    }

    private func deleteRecentItem(_ item: Item) {
        visualState = .saving
        if deleteItem(item) {
            recentItems.removeAll { $0.id == item.id }
            refreshRecents()
        }
        resetStateSoon()
    }

    private func resetStateSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            visualState = .idle
            setPanelExpanded(!isDragging && (isHovering || isDropTargeted))
        }
    }

    private func resetStateOnMain() {
        DispatchQueue.main.async {
            visualState = .idle
            setPanelExpanded(!isDragging && (isHovering || isDropTargeted))
        }
    }

    static func orbCenter(in frame: NSRect, isExpanded: Bool) -> NSPoint {
        let offset = orbCenterOffset(isExpanded: isExpanded)
        return NSPoint(x: frame.origin.x + offset.x, y: frame.origin.y + offset.y)
    }

    static func orbCenterOffset(isExpanded: Bool) -> NSPoint {
        if isExpanded {
            return NSPoint(
                x: expandedSize.width / 2,
                y: expandedSize.height - expandedPadding - idleSize.height / 2
            )
        }
        return NSPoint(x: idleSize.width / 2, y: idleSize.height / 2)
    }

    private func string(from item: Any?) -> String? {
        if let string = item as? String { return string }
        if let url = item as? URL { return url.absoluteString }
        if let data = item as? Data { return String(data: data, encoding: .utf8) }
        return nil
    }

    private func fileURL(from item: Any?) -> URL? {
        if let url = item as? URL { return url }
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        if let string = item as? String {
            return URL(string: string) ?? URL(fileURLWithPath: string)
        }
        return nil
    }
}

extension Notification.Name {
    static let orbDidSaveItem = Notification.Name("orbDidSaveItem")
    static let orbDidDeleteItem = Notification.Name("orbDidDeleteItem")
}
