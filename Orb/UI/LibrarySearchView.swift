import SwiftUI

struct LibrarySearchView: View {
    @Binding var query: String
    let results: [Item]
    var onSelect: (Item) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search library", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()
            if results.isEmpty {
                ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("Try a different query"))
            } else {
                List(results, id: \.id) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title).font(.headline)
                            Text(item.preview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Search")
    }
}
