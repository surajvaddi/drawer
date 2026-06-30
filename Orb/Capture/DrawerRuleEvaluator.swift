import Foundation

struct DrawerSuggestion: Equatable, Sendable {
    var drawerID: String
    var drawerName: String
    var ruleName: String
}

struct DrawerRuleEvaluator: Sendable {
    let rules: DrawerRuleRepository
    let drawers: DrawerRepository

    init(rules: DrawerRuleRepository, drawers: DrawerRepository) {
        self.rules = rules
        self.drawers = drawers
    }

    func suggest(for item: Item) throws -> DrawerSuggestion? {
        let enabled = try rules.fetchAll(enabledOnly: true)
        let matches = enabled.compactMap { rule -> (DrawerRule, Int)? in
            guard matches(rule: rule, item: item) else { return nil }
            return (rule, rule.priority)
        }
        guard let best = matches.max(by: { $0.1 < $1.1 })?.0 else { return nil }
        guard let drawer = try drawers.fetch(id: best.drawerId) else { return nil }
        return DrawerSuggestion(drawerID: drawer.id, drawerName: drawer.name, ruleName: best.name)
    }

    func matches(rule: DrawerRule, item: Item) -> Bool {
        let condition = rule.condition
        if let urlContains = condition["url_contains"]?.lowercased() {
            let haystack = [item.sourceURL, item.contentText, item.preview].compactMap { $0?.lowercased() }.joined(separator: " ")
            guard haystack.contains(urlContains) else { return false }
        }
        if let sourceApp = condition["source_app"]?.lowercased() {
            guard item.sourceApp?.lowercased() == sourceApp else { return false }
        }
        if let type = condition["type"] {
            guard item.type.rawValue == type else { return false }
        }
        return !condition.isEmpty
    }
}
