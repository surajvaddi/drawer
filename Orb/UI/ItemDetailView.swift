import SwiftUI

struct ItemDetailView: View {
    let item: Item
    var ocrText: String?
    var onCopy: () -> Void = {}
    var onOpen: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.title).font(.headline)
                Spacer()
                Button("Copy", action: onCopy)
                if item.type == .url {
                    Button("Open", action: onOpen)
                }
            }
            if let text = item.contentText, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .textSelection(.enabled)
            }
            if let ocrText, !ocrText.isEmpty {
                GroupBox("OCR Text") {
                    Text(ocrText)
                        .font(.caption)
                        .textSelection(.enabled)
                }
            }
            if let note = item.userNote, !note.isEmpty {
                GroupBox("Note") {
                    Text(note).font(.caption)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
