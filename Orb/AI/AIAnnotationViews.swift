import SwiftUI

struct AIAnnotationRow: View {
    let annotation: AIAnnotation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(annotation.kind.rawValue.capitalized)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text(annotation.model)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(displayText)
                .font(.subheadline)
                .lineLimit(4)
        }
        .padding(.vertical, 4)
    }

    private var displayText: String {
        if let value = annotation.content["value"] { return value }
        if let tags = annotation.content["tags"] { return tags.replacingOccurrences(of: ",", with: ", ") }
        if let facts = annotation.content["facts"] { return facts }
        return annotation.content.values.joined(separator: "\n")
    }
}

struct AIAnnotationListView: View {
    let annotations: [AIAnnotation]

    var body: some View {
        Group {
            if annotations.isEmpty {
                Text("No AI annotations yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(annotations) { annotation in
                    AIAnnotationRow(annotation: annotation)
                }
            }
        }
    }
}

struct AIAnnotationBadge: View {
    let kind: AIAnnotationKind

    var body: some View {
        Text(kind.rawValue.capitalized)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary, in: Capsule())
    }
}
