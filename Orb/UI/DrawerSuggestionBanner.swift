import SwiftUI

struct DrawerSuggestionBanner: View {
    let suggestion: DrawerSuggestion
    var onAccept: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "tray.and.arrow.down")
            VStack(alignment: .leading, spacing: 2) {
                Text("Move to \(suggestion.drawerName)?")
                    .font(.subheadline.weight(.semibold))
                Text(suggestion.ruleName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Dismiss", action: onDismiss)
                .buttonStyle(.borderless)
            Button("Accept", action: onAccept)
                .buttonStyle(.borderedProminent)
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct DrawerSuggestionController: Sendable {
    let moveService: MoveItemToDrawerService

    func accept(itemID: String, suggestion: DrawerSuggestion) throws {
        try moveService.move(itemID: itemID, toDrawer: suggestion.drawerID)
    }

    func dismiss() {}
}
