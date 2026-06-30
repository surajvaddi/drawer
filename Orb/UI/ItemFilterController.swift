import Foundation

struct ItemFilterCriteria: Equatable, Sendable {
    var types: Set<ItemType> = []
    var sourceApps: Set<String> = []
}

struct ItemFilterController: Sendable {
    var criteria = ItemFilterCriteria()

    func filter(_ items: [Item]) -> [Item] {
        items.filter { item in
            let typeMatch = criteria.types.isEmpty || criteria.types.contains(item.type)
            let sourceMatch = criteria.sourceApps.isEmpty || criteria.sourceApps.contains((item.sourceApp ?? "").lowercased())
            return typeMatch && sourceMatch
        }
    }
}
