import SwiftUI

struct QuickPasteResultsView: View {
    @Binding var selection: Int
    let items: [Item]
    var onCopy: (Item) -> Void = { _ in }

    var body: some View {
        List(Array(items.enumerated()), id: \.element.id) { index, item in
            HStack {
                Image(systemName: item.type.iconName)
                VStack(alignment: .leading) {
                    Text(item.title).font(.subheadline)
                    Text(item.preview).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .padding(.vertical, 4)
            .background(index == selection ? Color.accentColor.opacity(0.15) : Color.clear)
            .onTapGesture {
                selection = index
                onCopy(item)
            }
        }
        .onMoveCommand { direction in
            switch direction {
            case .down:
                selection = min(selection + 1, max(items.count - 1, 0))
            case .up:
                selection = max(selection - 1, 0)
            default:
                break
            }
        }
    }
}

struct QuickPasteKeyboardModel {
    var selection: Int = 0

    mutating func moveDown(count: Int) {
        selection = min(selection + 1, max(count - 1, 0))
    }

    mutating func moveUp() {
        selection = max(selection - 1, 0)
    }
}
