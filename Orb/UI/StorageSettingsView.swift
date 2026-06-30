import SwiftUI

struct StorageSettingsView: View {
    @Binding var settings: AppSettings

    var body: some View {
        Form {
            Toggle("Import Copies Files by Default", isOn: $settings.importCopiesFiles)
            Stepper(value: $settings.cacheSizeMB, in: 64...4096, step: 64) {
                Text("Cache Size Limit: \(settings.cacheSizeMB) MB")
            }
            Text("Backups are stored under Application Support/Orb/backups/")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
