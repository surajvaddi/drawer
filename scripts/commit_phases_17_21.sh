#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

add() {
  local target="$1" file="$2"
  python3 scripts/add_sources.py "$target" "$file" 2>/dev/null || true
  git add "$file"
}

commit() {
  git add Orb.xcodeproj/project.pbxproj
  git commit -m "$1"
}

# 17.1
add Orb Orb/Services/HotkeyService.swift
add OrbTests OrbTests/HotkeyServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/HotkeyServiceIntegrationTests.swift
commit "feat(services): add global hotkey registrar"

# 17.2
add Orb Orb/Services/ShortcutSettings.swift
add OrbTests OrbTests/ShortcutSettingsTests.swift
add OrbIntegrationTests OrbIntegrationTests/ShortcutSettingsIntegrationTests.swift
commit "feat(services): add configurable shortcut storage"

# 17.3
add Orb Orb/UI/DrawerKeyboardNavigator.swift
add OrbTests OrbTests/DrawerKeyboardNavigatorTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerKeyboardNavigatorIntegrationTests.swift
commit "feat(ui): add drawer keyboard navigation"

# 17.4
add Orb Orb/UI/CommandPalette.swift
add OrbTests OrbTests/CommandPaletteTests.swift
add OrbIntegrationTests OrbIntegrationTests/CommandPaletteIntegrationTests.swift
commit "feat(ui): add command palette"

# 17.5
add Orb Orb/Services/DrawerToggleShortcut.swift
add OrbTests OrbTests/DrawerToggleShortcutTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerToggleShortcutIntegrationTests.swift
commit "feat(services): add toggle drawer global shortcut"

# 17.6
add Orb Orb/Services/ScreenshotShortcut.swift
add OrbTests OrbTests/ScreenshotShortcutTests.swift
add OrbIntegrationTests OrbIntegrationTests/ScreenshotShortcutIntegrationTests.swift
commit "feat(services): add screenshot global shortcut"

# 18.1
add Orb Orb/Capture/OrbDropTarget.swift
add OrbTests OrbTests/OrbDropTargetTests.swift
add OrbIntegrationTests OrbIntegrationTests/OrbDropTargetIntegrationTests.swift
commit "feat(capture): register orb as drag-and-drop target"

# 18.2
add Orb Orb/UI/OrbDropHoverController.swift
add OrbTests OrbTests/OrbDropHoverControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/OrbDropHoverControllerIntegrationTests.swift
commit "feat(ui): add orb drop hover visual state"

# 18.3
add Orb Orb/Capture/FileDropPipeline.swift
add OrbTests OrbTests/FileDropPipelineTests.swift
add OrbIntegrationTests OrbIntegrationTests/FileDropPipelineIntegrationTests.swift
commit "feat(capture): add file drop import pipeline"

# 18.4
add Orb Orb/Capture/ImageDropPipeline.swift
add OrbTests OrbTests/ImageDropPipelineTests.swift
add OrbIntegrationTests OrbIntegrationTests/ImageDropPipelineIntegrationTests.swift
commit "feat(capture): add image and text drop pipelines"

# 18.5
add Orb Orb/UI/ItemDragSource.swift
add OrbTests OrbTests/ItemDragSourceTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemDragSourceIntegrationTests.swift
commit "feat(ui): add drag-out item source for external apps"

# 18.6
add Orb Orb/UI/DrawerRowDropHandler.swift
add OrbTests OrbTests/DrawerRowDropHandlerTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerRowDropHandlerIntegrationTests.swift
commit "feat(ui): add drag-and-drop move between drawers"

# 19.1
add Orb Orb/Privacy/SensitiveContentDetector.swift
add OrbTests OrbTests/SensitiveContentDetectorTests.swift
add OrbIntegrationTests OrbIntegrationTests/SensitiveContentDetectorIntegrationTests.swift
commit "feat(privacy): add sensitive content detector"

# 19.2
add Orb Orb/Privacy/SensitiveSaveAlert.swift
add OrbTests OrbTests/SensitiveSaveAlertTests.swift
add OrbIntegrationTests OrbIntegrationTests/SensitiveSaveAlertIntegrationTests.swift
commit "feat(privacy): add sensitive save warning dialog"

# 19.3
add Orb Orb/Storage/MigrationV7.swift
git add Orb/Core/Drawer.swift Orb/Storage/DrawerRepository.swift Orb/Storage/OrbMigrations.swift
add Orb Orb/Privacy/PrivateDrawerService.swift
add OrbTests OrbTests/MigrationV7Tests.swift
add OrbTests OrbTests/PrivateDrawerServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/PrivateDrawerServiceIntegrationTests.swift
commit "feat(privacy): add private drawer flag and encryption interface"

# 19.4
add Orb Orb/Privacy/ExcludedAppsManager.swift
add OrbTests OrbTests/ExcludedAppsManagerTests.swift
add OrbIntegrationTests OrbIntegrationTests/ExcludedAppsManagerIntegrationTests.swift
commit "feat(privacy): add excluded apps manager"

# 19.5
add Orb Orb/Privacy/ClipboardPreviewCleaner.swift
add OrbTests OrbTests/ClipboardPreviewCleanerTests.swift
add OrbIntegrationTests OrbIntegrationTests/ClipboardPreviewCleanerIntegrationTests.swift
commit "feat(privacy): clear unsaved clipboard previews automatically"

# 19.6
add Orb Orb/Privacy/PrivateModeController.swift
add OrbTests OrbTests/PrivateModeControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/PrivateModeControllerIntegrationTests.swift
commit "feat(privacy): add global private mode toggle"

# 20.1
add Orb Orb/Services/PermissionService.swift
add OrbTests OrbTests/PermissionServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/PermissionServiceIntegrationTests.swift
commit "feat(services): add permission status reader"

# 20.2
add Orb Orb/UI/PermissionOnboardingView.swift
add OrbTests OrbTests/PermissionOnboardingViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/PermissionOnboardingViewIntegrationTests.swift
commit "feat(ui): add permission explanation onboarding views"

# 20.3
add Orb Orb/Services/ScreenshotPermissionGate.swift
add OrbTests OrbTests/ScreenshotPermissionGateTests.swift
add OrbIntegrationTests OrbIntegrationTests/ScreenshotPermissionGateIntegrationTests.swift
commit "feat(services): gate screenshot capture on screen recording permission"

# 20.4
add Orb Orb/Services/AutoPastePermissionGate.swift
add OrbTests OrbTests/AutoPastePermissionGateTests.swift
add OrbIntegrationTests OrbIntegrationTests/AutoPastePermissionGateIntegrationTests.swift
commit "feat(services): gate auto-paste on accessibility permission"

# 20.5
add Orb Orb/Services/PermissionDegradationPolicy.swift
add OrbTests OrbTests/PermissionDegradationPolicyTests.swift
add OrbIntegrationTests OrbIntegrationTests/PermissionDegradationPolicyIntegrationTests.swift
commit "feat(services): add permission degradation policy"

# 20.6
add Orb Orb/Services/FileAccessPermissionHelper.swift
add OrbTests OrbTests/FileAccessPermissionHelperTests.swift
add OrbIntegrationTests OrbIntegrationTests/FileAccessPermissionHelperIntegrationTests.swift
commit "feat(services): add file access permission helper"

# 21.1
add Orb Orb/Storage/AppSettingsRepository.swift
git add Orb/Services/SettingsStore.swift
add OrbTests OrbTests/SettingsStoreFoundationTests.swift
add OrbIntegrationTests OrbIntegrationTests/SettingsStoreFoundationIntegrationTests.swift
commit "feat(services): add SettingsStore foundation"

# 21.2
add Orb Orb/UI/GeneralSettingsView.swift
add OrbTests OrbTests/GeneralSettingsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/GeneralSettingsViewIntegrationTests.swift
commit "feat(ui): add general orb appearance settings"

# 21.3
add Orb Orb/UI/CaptureSettingsView.swift
add OrbTests OrbTests/CaptureSettingsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/CaptureSettingsViewIntegrationTests.swift
commit "feat(ui): add capture settings panel"

# 21.4
add Orb Orb/UI/SearchSettingsView.swift
add OrbTests OrbTests/SearchSettingsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/SearchSettingsViewIntegrationTests.swift
commit "feat(ui): add search and paste settings"

# 21.5
add Orb Orb/Storage/DataWiper.swift
add Orb Orb/UI/PrivacySettingsView.swift
add OrbTests OrbTests/PrivacySettingsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/PrivacySettingsViewIntegrationTests.swift
commit "feat(ui): add privacy settings panel"

# 21.6
add Orb Orb/Storage/ThumbnailCacheEvictor.swift
add Orb Orb/UI/StorageSettingsView.swift
add OrbTests OrbTests/StorageSettingsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/StorageSettingsViewIntegrationTests.swift
commit "feat(ui): add storage settings panel"

echo done
