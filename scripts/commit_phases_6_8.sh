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

# 6.1
add Orb Orb/Capture/PasteboardProviding.swift
add Orb Orb/Capture/PasteboardMonitor.swift
add Orb Orb/Capture/ClipboardWatchSettings.swift
add OrbTests OrbTests/MockPasteboard.swift
add OrbTests OrbTests/PasteboardMonitorTests.swift
add OrbIntegrationTests OrbIntegrationTests/PasteboardMonitorIntegrationTests.swift
commit "feat(capture): add pasteboard change detector"

# 6.2 (+ classifiers deps used by primaryType)
add Orb Orb/Capture/URLNormalizer.swift
add Orb Orb/Capture/CodeSnippetDetector.swift
add Orb Orb/Capture/PasteboardClassifier.swift
add OrbTests OrbTests/PasteboardClassifierTests.swift
add OrbIntegrationTests OrbIntegrationTests/PasteboardClassifierIntegrationTests.swift
commit "feat(capture): add pasteboard type classifier"

# 6.3
add Orb Orb/Capture/PasteboardReader.swift
add OrbTests OrbTests/PasteboardReaderTests.swift
add OrbIntegrationTests OrbIntegrationTests/PasteboardReaderIntegrationTests.swift
commit "feat(capture): add pasteboard content reader"

# 7.2 + 7.4 deps for pipeline
add Orb Orb/Capture/TextNormalizer.swift
add Orb Orb/Capture/ItemFactory.swift
add Orb Orb/Capture/SourceAppResolver.swift
add Orb Orb/Capture/ClipboardSavePipeline.swift
add OrbTests OrbTests/ClipboardSavePipelineTests.swift
add OrbIntegrationTests OrbIntegrationTests/ClipboardSavePipelineIntegrationTests.swift
commit "feat(capture): add clipboard save pipeline"

# 6.5
add Orb Orb/Capture/PasteboardWriter.swift
add OrbTests OrbTests/PasteboardWriterTests.swift
add OrbIntegrationTests OrbIntegrationTests/PasteboardWriterIntegrationTests.swift
commit "feat(capture): add pasteboard write-back for saved items"

# 6.6
add OrbTests OrbTests/ClipboardWatchSettingsTests.swift
add OrbIntegrationTests OrbIntegrationTests/ClipboardWatchSettingsIntegrationTests.swift
commit "feat(capture): add clipboard pause and excluded app checks"

# 7.1
add OrbTests OrbTests/URLNormalizerTests.swift
add OrbIntegrationTests OrbIntegrationTests/URLNormalizerIntegrationTests.swift
commit "feat(capture): add URL detector and normalizer"

# 7.2
add OrbTests OrbTests/TextNormalizerTests.swift
add OrbIntegrationTests OrbIntegrationTests/TextNormalizerIntegrationTests.swift
commit "feat(capture): add text normalizer and preview generator"

# 7.3
add OrbTests OrbTests/CodeSnippetDetectorTests.swift
add OrbIntegrationTests OrbIntegrationTests/CodeSnippetDetectorIntegrationTests.swift
commit "feat(capture): add code snippet detector"

# 7.4
add OrbTests OrbTests/ItemFactoryTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemFactoryIntegrationTests.swift
commit "feat(capture): add ItemFactory for capture payloads"

# 7.5
add OrbTests OrbTests/CaptureEventLoggerTests.swift
add OrbIntegrationTests OrbIntegrationTests/CaptureEventLoggerIntegrationTests.swift
commit "feat(capture): log capture events on all save paths"

# 7.6
add OrbTests OrbTests/SourceAppResolverTests.swift
add OrbIntegrationTests OrbIntegrationTests/SourceAppResolverIntegrationTests.swift
commit "feat(capture): add source app attribution on capture"

# 8.1
add Orb Orb/UI/DrawerPanel.swift
add OrbTests OrbTests/DrawerPanelTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerPanelIntegrationTests.swift
commit "feat(ui): add drawer panel window anchored to orb"

# 8.2
add Orb Orb/UI/DrawerView.swift
add OrbTests OrbTests/DrawerViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerViewIntegrationTests.swift
commit "feat(ui): add drawer root layout with sections"

# 8.3
add Orb Orb/UI/DrawerSearchBar.swift
add OrbTests OrbTests/DrawerSearchBarTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerSearchBarIntegrationTests.swift
commit "feat(ui): add drawer search bar component"

# 8.4
add Orb Orb/UI/QuickActionsRow.swift
add OrbTests OrbTests/QuickActionsRowTests.swift
add OrbIntegrationTests OrbIntegrationTests/QuickActionsRowIntegrationTests.swift
commit "feat(ui): add drawer quick actions row"

# 8.5
add Orb Orb/UI/InboxListView.swift
add OrbTests OrbTests/InboxListViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/InboxListViewIntegrationTests.swift
commit "feat(ui): add inbox item list in drawer"

# 8.6
add Orb Orb/UI/DrawerListView.swift
add OrbTests OrbTests/DrawerListViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerListViewIntegrationTests.swift
commit "feat(ui): add nested drawer list sidebar"

echo done
