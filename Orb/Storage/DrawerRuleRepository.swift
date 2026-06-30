import Foundation
import SQLite3

struct DrawerRuleRepository: Sendable {
    let manager: DatabaseManager

    func create(_ rule: DrawerRule) throws -> DrawerRule {
        let json = try JSONEncoder().encode(rule.condition)
        let condition = String(data: json, encoding: .utf8) ?? "{}"
        try manager.exec(
            """
            INSERT INTO drawer_rules (id, drawer_id, name, condition_json, priority, enabled)
            VALUES (
              '\(escape(rule.id))',
              '\(escape(rule.drawerId))',
              '\(escape(rule.name))',
              '\(escape(condition))',
              \(rule.priority),
              \(rule.enabled ? 1 : 0)
            );
            """
        )
        return rule
    }

    func fetchAll(enabledOnly: Bool = true) throws -> [DrawerRule] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = enabledOnly
            ? "SELECT id, drawer_id, name, condition_json, priority, enabled FROM drawer_rules WHERE enabled = 1 ORDER BY priority DESC;"
            : "SELECT id, drawer_id, name, condition_json, priority, enabled FROM drawer_rules ORDER BY priority DESC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch drawer rules failed")
        }
        var rules: [DrawerRule] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            rules.append(try mapRow(stmt))
        }
        return rules
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> DrawerRule {
        guard
            let id = sqlite3_column_text(stmt, 0),
            let drawerID = sqlite3_column_text(stmt, 1),
            let name = sqlite3_column_text(stmt, 2),
            let conditionJSON = sqlite3_column_text(stmt, 3)
        else { throw OrbError.storage("invalid drawer rule row") }
        let data = String(cString: conditionJSON).data(using: .utf8) ?? Data()
        let condition = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
        return DrawerRule(
            id: String(cString: id),
            drawerId: String(cString: drawerID),
            name: String(cString: name),
            condition: condition,
            priority: Int(sqlite3_column_int(stmt, 4)),
            enabled: sqlite3_column_int(stmt, 5) == 1
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}
