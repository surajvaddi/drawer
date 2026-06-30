import SwiftUI

struct TagEditorView: View {
    @Binding var tags: [Tag]
    @State private var draft = ""
    var suggestions: [Tag] = []
    var onAdd: (String) -> Void = { _ in }
    var onRemove: (Tag) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(tags: tags, onRemove: onRemove)
            TextField("Add tag", text: $draft, onCommit: commitDraft)
                .textFieldStyle(.roundedBorder)
            if !filteredSuggestions.isEmpty {
                ForEach(filteredSuggestions) { tag in
                    Button(tag.name) {
                        draft = tag.name
                        commitDraft()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private var filteredSuggestions: [Tag] {
        let query = Tag.normalize(draft)
        guard !query.isEmpty else { return [] }
        return suggestions.filter { $0.name.hasPrefix(query) && !tags.contains($0) }
    }

    private func commitDraft() {
        let name = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        onAdd(name)
        draft = ""
    }
}

struct TagEditorController: Sendable {
    let tags: TagRepository

    func addTag(name: String, to itemID: String) throws -> Tag {
        let tag = try tags.create(name: name)
        try tags.link(itemId: itemID, tagId: tag.id)
        return tag
    }

    func autocomplete(query: String, existing: [Tag]) throws -> [Tag] {
        try tags.searchPrefix(query).filter { candidate in
            !existing.contains(where: { $0.id == candidate.id })
        }
    }
}

private struct FlowLayout: View {
    let tags: [Tag]
    var onRemove: (Tag) -> Void

    var body: some View {
        HStack {
            ForEach(tags) { tag in
                HStack(spacing: 4) {
                    Text(tag.name)
                    Button(action: { onRemove(tag) }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
            }
        }
    }
}
