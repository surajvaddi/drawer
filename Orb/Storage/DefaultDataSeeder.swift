import Foundation

struct DefaultDataSeeder: Sendable {
    static let inboxDrawerID = "inbox"
    static let inboxDrawerName = "Inbox"
    private static let seededKey = "orb.default_inbox_seeded"

    let drawers: DrawerRepository
    let defaults: UserDefaults

    init(drawers: DrawerRepository, defaults: UserDefaults = .standard) {
        self.drawers = drawers
        self.defaults = defaults
    }

    @discardableResult
    func seedIfNeeded() throws -> Drawer? {
        guard !defaults.bool(forKey: Self.seededKey) else { return nil }
        if try drawers.fetchAll().contains(where: { $0.id == Self.inboxDrawerID || $0.name == Self.inboxDrawerName }) {
            defaults.set(true, forKey: Self.seededKey)
            return nil
        }
        let inbox = try drawers.create(
            Drawer(
                id: Self.inboxDrawerID,
                name: Self.inboxDrawerName,
                icon: "tray",
                color: "#6B7280",
                sortOrder: 0,
                isPinned: true
            )
        )
        defaults.set(true, forKey: Self.seededKey)
        return inbox
    }
}
