import SwiftUI

struct DrawerListView: View {
    let drawers: [Drawer]
    @Binding var selectedDrawerID: String?
    var itemsForDrawer: (String) -> [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Drawers")
                .font(.headline)
            ForEach(drawers.sorted(by: Drawer.sortByOrder)) { drawer in
                let indent = nestingLevel(for: drawer) * 12
                Button {
                    selectedDrawerID = drawer.id
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: drawer.color) ?? .blue)
                            .frame(width: 8, height: 8)
                        Text(drawer.name)
                            .font(.subheadline)
                        Spacer()
                        if selectedDrawerID == drawer.id {
                            Text("\(itemsForDrawer(drawer.id).count)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.leading, CGFloat(indent))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func nestingLevel(for drawer: Drawer) -> Int {
        guard drawer.parentDrawerId != nil else { return 0 }
        var level = 0
        var current = drawer.parentDrawerId
        let byID = Dictionary(uniqueKeysWithValues: drawers.map { ($0.id, $0) })
        while let parentID = current, let parent = byID[parentID] {
            level += 1
            current = parent.parentDrawerId
        }
        return level
    }
}

private extension Color {
    init?(hex: String?) {
        guard let hex, hex.hasPrefix("#"), hex.count == 7 else { return nil }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let value = Int(hex[start...], radix: 16) ?? 0
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
