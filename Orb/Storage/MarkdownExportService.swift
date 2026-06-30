import Foundation

struct MarkdownExportService: Sendable {
    let items: ItemRepository
    let drawers: DrawerRepository

    func export() throws -> String {
        let allDrawers = try drawers.fetchAll()
        let drawerByID = Dictionary(uniqueKeysWithValues: allDrawers.map { ($0.id, $0) })
        let allItems = try items.listAll(includeArchived: false)
        var lines = ["# Orb Export", "", "Exported: \(ISO8601DateFormatter().string(from: Date()))", ""]
        for item in allItems {
            lines.append("## \(item.title)")
            if let drawerId = item.drawerId, let drawer = drawerByID[drawerId] {
                lines.append("- Drawer: \(drawer.name)")
            }
            lines.append("- Type: \(item.type.rawValue)")
            if let url = item.sourceURL { lines.append("- Source: \(url)") }
            lines.append("")
            lines.append(item.contentText ?? item.preview)
            lines.append("")
            lines.append("---")
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    func export(to url: URL) throws {
        try export().write(to: url, atomically: true, encoding: .utf8)
    }
}
