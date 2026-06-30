import SwiftUI

struct PrivacySettingsView: View {
    @Binding var settings: AppSettings
    @Binding var excludedApps: Set<String>
    var onDeleteAllData: () -> Void

    var body: some View {
        Form {
            Toggle("Sensitive Content Detection", isOn: $settings.sensitiveDetectionEnabled)
            Section("Excluded Apps") {
                if excludedApps.isEmpty {
                    Text("No excluded apps").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(excludedApps).sorted(), id: \.self) { bundleID in
                        Text(bundleID)
                    }
                }
            }
            Button("Delete All Data", role: .destructive, action: onDeleteAllData)
        }
    }
}
