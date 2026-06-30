import Foundation

struct CreateDrawerRequest: Equatable, Sendable {
    var name: String
    var icon: String?
    var color: String?
    var parentDrawerId: String?
}

struct CreateDrawerFlow: Sendable {
    let drawers: DrawerRepository

    func validate(name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw OrbError.invalidData("Drawer name cannot be empty")
        }
    }

    func create(_ request: CreateDrawerRequest) throws -> Drawer {
        try validate(name: request.name)
        let sortOrder = try drawers.nextSortOrder()
        return try drawers.create(
            Drawer(
                name: request.name.trimmingCharacters(in: .whitespacesAndNewlines),
                icon: request.icon,
                color: request.color,
                parentDrawerId: request.parentDrawerId,
                sortOrder: sortOrder
            )
        )
    }
}
