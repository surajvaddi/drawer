import SwiftUI

struct InboxListView: View {
    let items: [Item]
    var emptyMessage: String = "No items in Inbox"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inbox")
                .font(.headline)
            if items.isEmpty {
                Text(emptyMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: item.type.iconName)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title).font(.subheadline).lineLimit(1)
                            Text(item.preview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
