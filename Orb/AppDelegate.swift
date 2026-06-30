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
                setDropHoverFrame: { [weak panel] isHovering in
                    guard let panel else { return }
                    let oldFrame = panel.frame
                    let oldCenter = NSPoint(x: oldFrame.midX, y: oldFrame.midY)
                    let newSize = isHovering ? PersistentOrbButton.dropHoverSize : PersistentOrbButton.idleSize
                    let newOrigin = NSPoint(
                        x: oldCenter.x - newSize.width / 2,
                        y: oldCenter.y - newSize.height / 2
                    )
                    panel.setFrame(NSRect(origin: newOrigin, size: newSize), display: true)
                },
                openOrb: {
                    self.showMainWindow()
                },
                saveDrop: { payload in
                    self.saveDrop(payload)
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
    static let dropHoverSize = NSSize(width: 168, height: 112)

    var currentPanelOrigin: () -> NSPoint?
    var movePanel: (NSPoint) -> Void
    var setDropHoverFrame: (Bool) -> Void
    var openOrb: () -> Void
    var saveDrop: (CapturePayload) -> Void

    @State private var visualState: OrbVisualState = .idle
    @State private var dragStartOrigin: NSPoint?
    @State private var isDropTargeted = false

    var body: some View {
        OrbView(diameter: 64, state: isDropTargeted ? .dragHover : visualState)
            .padding(4)
            .frame(
                width: isDropTargeted ? Self.dropHoverSize.width : Self.idleSize.width,
                height: isDropTargeted ? Self.dropHoverSize.height : Self.idleSize.height
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: openOrb)
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        if dragStartOrigin == nil {
                            dragStartOrigin = currentPanelOrigin()
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
                    }
            )
            .onDrop(
                of: Self.acceptedDropTypes,
                isTargeted: $isDropTargeted,
                perform: handleDrop(providers:)
            )
            .onChange(of: isDropTargeted) { _, isHovering in
                setDropHoverFrame(isHovering)
            }
        .help("Open Orb")
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

    private func resetStateSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            visualState = .idle
            setDropHoverFrame(false)
        }
    }

    private func resetStateOnMain() {
        DispatchQueue.main.async {
            visualState = .idle
            setDropHoverFrame(false)
        }
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
}
