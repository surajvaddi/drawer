import Foundation

struct NestedDrawerService: Sendable {
    let drawers: DrawerRepository

    func reparent(drawerID: String, toParent parentID: String?) throws {
        if let parentID {
            guard drawerID != parentID else {
                throw OrbError.invalidData("Drawer cannot be its own parent")
            }
            let all = try drawers.fetchAll()
            if isDescendant(of: drawerID, candidate: parentID, in: all) {
                throw OrbError.invalidData("Cannot create drawer cycle")
            }
        }
        try drawers.reparent(drawerID: drawerID, parentDrawerID: parentID)
    }

    func isDescendant(of ancestorID: String, candidate childID: String, in drawers: [Drawer]) -> Bool {
        var current = drawers.first { $0.id == childID }
        var visited = Set<String>()
        while let drawer = current {
            if drawer.id == ancestorID { return true }
            if visited.contains(drawer.id) { break }
            visited.insert(drawer.id)
            guard let parentID = drawer.parentDrawerId else { break }
            current = drawers.first { $0.id == parentID }
        }
        return false
    }
}
