import Foundation

protocol DrawerEncrypting: Sendable {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
}

struct NoOpDrawerEncryptor: DrawerEncrypting {
    func encrypt(_ data: Data) throws -> Data { data }
    func decrypt(_ data: Data) throws -> Data { data }
}

struct PrivateDrawerService: Sendable {
    static let privateDrawerID = "private"
    let drawers: DrawerRepository
    let encryptor: any DrawerEncrypting
    var isUnlocked: Bool

    init(drawers: DrawerRepository, encryptor: any DrawerEncrypting = NoOpDrawerEncryptor(), isUnlocked: Bool = false) {
        self.drawers = drawers
        self.encryptor = encryptor
        self.isUnlocked = isUnlocked
    }

    func markPrivate(drawerID: String) throws -> Drawer {
        guard var drawer = try drawers.fetch(id: drawerID) else {
            throw OrbError.invalidData("Drawer not found")
        }
        drawer.isPrivate = true
        return try drawers.update(drawer)
    }

    func includeInSearch(drawer: Drawer) -> Bool {
        !drawer.isPrivate || isUnlocked
    }

    func visibleItems(_ items: [Item], drawers: [Drawer]) -> [Item] {
        let privateIDs = Set(drawers.filter(\.isPrivate).map(\.id))
        guard !isUnlocked else { return items }
        return items.filter { item in
            guard let drawerID = item.drawerId else { return true }
            return !privateIDs.contains(drawerID)
        }
    }
}
