import Foundation

struct MarkdownImportService: Sendable {
    let items: ItemRepository
    let defaultDrawerID: String

    init(items: ItemRepository, defaultDrawerID: String = DefaultDataSeeder.inboxDrawerID) {
        self.items = items
        self.defaultDrawerID = defaultDrawerID
    }

    func importMarkdown(_ markdown: String) throws -> [Item] {
        let sections = markdown.components(separatedBy: "\n## ")
        var imported: [Item] = []
        for (index, section) in sections.enumerated() {
            let trimmed = section.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            if index == 0 && !trimmed.hasPrefix("#") { continue }
            let lines = trimmed.components(separatedBy: .newlines)
            guard let titleLine = lines.first else { continue }
            let title = titleLine
                .replacingOccurrences(of: "#", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, title != "Orb Export" else { continue }
            let bodyStart = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty }) ?? 1
            let body = lines.dropFirst(bodyStart + 1)
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let item = try items.create(
                Item(
                    type: .text,
                    title: title,
                    preview: itemPreview(body),
                    contentText: body,
                    drawerId: defaultDrawerID
                )
            )
            imported.append(item)
        }
        return imported
    }

    func importFile(at url: URL) throws -> [Item] {
        let markdown = try String(contentsOf: url, encoding: .utf8)
        return try importMarkdown(markdown)
    }

    private func itemPreview(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > Item.previewLimit else { return trimmed }
        let index = trimmed.index(trimmed.startIndex, offsetBy: Item.previewLimit)
        return String(trimmed[..<index]) + "…"
    }
}
