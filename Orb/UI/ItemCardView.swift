import AppKit
import SwiftUI

struct ItemCardView: View {
    let item: Item
    var thumbnailData: Data?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            iconView
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if !item.preview.isEmpty {
                    Text(item.preview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                HStack(spacing: 6) {
                    if let sourceApp = item.sourceApp, !sourceApp.isEmpty {
                        Text(sourceApp)
                    }
                    Text(RelativeDateFormatter.string(from: item.createdAt))
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var iconView: some View {
        if item.type == .screenshot || item.type == .image, let thumbnailData, let image = NSImage(data: thumbnailData) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            Image(systemName: item.type.iconName)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
        }
    }
}
