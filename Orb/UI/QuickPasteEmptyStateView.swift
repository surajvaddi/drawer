import SwiftUI

struct QuickPasteEmptyStateView: View {
    let query: String
    let recents: [Item]

    var body: some View {
        VStack(spacing: 8) {
            if query.isEmpty {
                Text("Recent items")
                    .font(.headline)
                if recents.isEmpty {
                    Text("Save something to Orb to get started.")
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(recents.count) recent items")
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No results for \"\(query)\"")
                    .font(.headline)
                Text("Try a broader query or check your filters.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct QuickPasteEmptyStateModel {
    func showsRecents(query: String) -> Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func showsNoResults(query: String, resultCount: Int) -> Bool {
        !showsRecents(query: query) && resultCount == 0
    }
}
