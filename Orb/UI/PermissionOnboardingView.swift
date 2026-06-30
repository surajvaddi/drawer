import SwiftUI

struct PermissionOnboardingView: View {
  let explanations: [PermissionKind: String] = [
        .clipboard: "Orb reads clipboard changes to detect content you may want to save.",
        .accessibility: "Accessibility enables global shortcuts and optional auto-paste.",
        .screenRecording: "Screen recording permission is required for region screenshots.",
        .files: "File access lets Orb import documents and keep references with your consent."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions").font(.headline)
            ForEach(PermissionKind.allCases, id: \.self) { kind in
                VStack(alignment: .leading, spacing: 4) {
                    Text(kind.rawValue.capitalized).font(.subheadline.weight(.semibold))
                    Text(explanations[kind] ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Button("Open System Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
            }
        }
        .padding()
    }
}

import AppKit
