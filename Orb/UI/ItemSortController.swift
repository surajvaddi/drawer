import Foundation

enum ItemSortOption: String, Codable, CaseIterable, Sendable {
    case recent
    case alphabetical
    case type
    case lastAccessed
}

struct ItemSortController: Sendable {
  var option: ItemSortOption = .recent
    private let preferencesKey = "orb.drawer.sort"

    func sort(_ items: [Item]) -> [Item] {
        switch option {
        case .recent:
            return items.sorted { $0.createdAt > $1.createdAt }
        case .alphabetical:
            return items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .type:
            return items.sorted {
                if $0.type.displayName != $1.type.displayName {
                    return $0.type.displayName < $1.type.displayName
                }
                return $0.title < $1.title
            }
        case .lastAccessed:
            return items.sorted {
                let lhs = $0.lastAccessedAt ?? $0.createdAt
                let rhs = $1.lastAccessedAt ?? $1.createdAt
                return lhs > rhs
            }
        }
    }

    func savePreference(for drawerID: String, option: ItemSortOption, defaults: UserDefaults = .standard) {
        var map = defaults.dictionary(forKey: preferencesKey) as? [String: String] ?? [:]
        map[drawerID] = option.rawValue
        defaults.set(map, forKey: preferencesKey)
    }

    func loadPreference(for drawerID: String, defaults: UserDefaults = .standard) -> ItemSortOption {
        let map = defaults.dictionary(forKey: preferencesKey) as? [String: String] ?? [:]
        guard let raw = map[drawerID], let option = ItemSortOption(rawValue: raw) else { return .recent }
        return option
    }
}
