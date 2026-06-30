import SwiftUI

struct BulkOrganizationView: View {
    @Binding var selectedItemIDs: Set<String>
    let items: [Item]
    let drawers: [Drawer]
    var onMoveToDrawer: (String, Set<String>) throws -> Void
    var onArchive: (Set<String>) throws -> Void
    var onDelete: (Set<String>) throws -> Void
    @State private var targetDrawerID: String = ""
    @State private var statusMessage: String?

    var body: some View {
        Form {
            Section("Selection") {
                Text("\(selectedItemIDs.count) items selected")
            }
            Section("Move") {
                Picker("Drawer", selection: $targetDrawerID) {
                    Text("Choose drawer").tag("")
                    ForEach(drawers, id: \.id) { drawer in
                        Text(drawer.name).tag(drawer.id)
                    }
                }
                Button("Move Selected") {
                    run {
                        guard !targetDrawerID.isEmpty else { return }
                        try onMoveToDrawer(targetDrawerID, selectedItemIDs)
                    }
                }
                .disabled(selectedItemIDs.isEmpty || targetDrawerID.isEmpty)
            }
            Section("Actions") {
                Button("Archive Selected") { run { try onArchive(selectedItemIDs) } }
                    .disabled(selectedItemIDs.isEmpty)
                Button("Delete Selected", role: .destructive) { run { try onDelete(selectedItemIDs) } }
                    .disabled(selectedItemIDs.isEmpty)
            }
            if let statusMessage {
                Text(statusMessage).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Bulk Organization")
    }

    private func run(_ action: () throws -> Void) {
        do {
            try action()
            statusMessage = "Updated \(selectedItemIDs.count) items"
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
