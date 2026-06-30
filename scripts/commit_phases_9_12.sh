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

# 9.1
add Orb Orb/UI/RelativeDateFormatter.swift
add Orb Orb/UI/ItemCardView.swift
add OrbTests OrbTests/ItemCardViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemCardViewIntegrationTests.swift
commit "feat(ui): add compact item card component"

# 9.2
add Orb Orb/UI/ItemCardContextMenu.swift
add OrbTests OrbTests/ItemCardContextMenuTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemCardContextMenuIntegrationTests.swift
commit "feat(ui): add item card context menu actions"

# 9.3
add Orb Orb/UI/ItemDetailView.swift
add OrbTests OrbTests/ItemDetailViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemDetailViewIntegrationTests.swift
commit "feat(ui): add inline item detail expansion"

# 9.4 (+ migration v5 for user_note)
add Orb Orb/Storage/MigrationV5.swift
git add Orb/Core/Item.swift Orb/Storage/ItemRepository.swift Orb/Storage/OrbMigrations.swift
add Orb Orb/UI/ItemMetadataEditor.swift
add OrbTests OrbTests/MigrationV5Tests.swift
add OrbTests OrbTests/ItemMetadataEditorTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemMetadataEditorIntegrationTests.swift
commit "feat(ui): add item rename and notes editor"

# 9.5
add Orb Orb/UI/ItemPinController.swift
add OrbTests OrbTests/ItemPinControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemPinControllerIntegrationTests.swift
commit "feat(ui): add pin and favorite toggles for items"

# 9.6
add Orb Orb/UI/ItemReorderController.swift
add OrbTests OrbTests/ItemReorderControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemReorderControllerIntegrationTests.swift
commit "feat(ui): add drag-and-drop item reorder and drawer move"

# 10.1
add Orb Orb/Capture/LinkMetadataFetcher.swift
add OrbTests OrbTests/LinkMetadataFetcherTests.swift
add OrbIntegrationTests OrbIntegrationTests/LinkMetadataFetcherIntegrationTests.swift
commit "feat(capture): add link metadata fetcher"

# 10.2
add OrbTests OrbTests/TestFixtures.swift
add Orb Orb/Capture/LinkItemProcessor.swift
add OrbTests OrbTests/LinkItemProcessorTests.swift
add OrbIntegrationTests OrbIntegrationTests/LinkItemProcessorIntegrationTests.swift
commit "feat(capture): add link item processor pipeline"

# 10.3
add Orb Orb/Capture/TextItemProcessor.swift
add OrbTests OrbTests/TextItemProcessorTests.swift
add OrbIntegrationTests OrbIntegrationTests/TextItemProcessorIntegrationTests.swift
commit "feat(capture): add text item processor pipeline"

# 10.4
add Orb Orb/Capture/RichClipProcessor.swift
add OrbTests OrbTests/RichClipProcessorTests.swift
add OrbIntegrationTests OrbIntegrationTests/RichClipProcessorIntegrationTests.swift
commit "feat(capture): add rich clip HTML processor"

# 10.5
add Orb Orb/UI/LinkItemActions.swift
add OrbTests OrbTests/LinkItemActionsTests.swift
add OrbIntegrationTests OrbIntegrationTests/LinkItemActionsIntegrationTests.swift
commit "feat(ui): add link open and copy actions"

# 10.6
add Orb Orb/UI/TextItemActions.swift
add OrbTests OrbTests/TextItemActionsTests.swift
add OrbIntegrationTests OrbIntegrationTests/TextItemActionsIntegrationTests.swift
commit "feat(ui): add text copy and edit actions"

# 11.1
add Orb Orb/Capture/ScreenshotRegionOverlay.swift
add OrbTests OrbTests/ScreenshotRegionOverlayTests.swift
add OrbIntegrationTests OrbIntegrationTests/ScreenshotRegionOverlayIntegrationTests.swift
commit "feat(capture): add screenshot region selection overlay"

# 11.2
add Orb Orb/Capture/ScreenshotCaptureService.swift
add OrbTests OrbTests/ScreenshotCaptureServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/ScreenshotCaptureServiceIntegrationTests.swift
commit "feat(capture): add ScreenCaptureKit region capture"

# 11.3
add Orb Orb/Capture/ScreenshotSavePipeline.swift
add OrbTests OrbTests/ScreenshotSavePipelineTests.swift
add OrbIntegrationTests OrbIntegrationTests/ScreenshotSavePipelineIntegrationTests.swift
commit "feat(capture): add screenshot save pipeline"

# 11.4
add Orb Orb/Capture/OCRService.swift
add OrbTests OrbTests/OCRServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/OCRServiceIntegrationTests.swift
commit "feat(capture): add Vision OCR service for screenshots"

# 11.5
add Orb Orb/Capture/OCRIndexer.swift
add OrbTests OrbTests/OCRIndexerTests.swift
add OrbIntegrationTests OrbIntegrationTests/OCRIndexerIntegrationTests.swift
commit "feat(capture): index OCR text for screenshot search"

# 11.6
add Orb Orb/UI/ScreenshotItemActions.swift
add OrbTests OrbTests/ScreenshotItemActionsTests.swift
add OrbIntegrationTests OrbIntegrationTests/ScreenshotItemActionsIntegrationTests.swift
commit "feat(ui): add screenshot copy and preview actions"

# 12.1
add Orb Orb/Capture/FileImportValidator.swift
add OrbTests OrbTests/FileImportValidatorTests.swift
add OrbIntegrationTests OrbIntegrationTests/FileImportValidatorIntegrationTests.swift
commit "feat(capture): add file import validator"

# 12.2
add Orb Orb/Capture/FileImporter.swift
add OrbTests OrbTests/FileImporterTests.swift
add OrbIntegrationTests OrbIntegrationTests/FileImporterIntegrationTests.swift
commit "feat(capture): add file copy importer"

# 12.3
add Orb Orb/Capture/FileReferenceImporter.swift
add OrbTests OrbTests/FileReferenceImporterTests.swift
add OrbIntegrationTests OrbIntegrationTests/FileReferenceImporterIntegrationTests.swift
commit "feat(capture): add file reference importer with bookmarks"

# 12.4
add Orb Orb/Capture/PDFTextExtractor.swift
add OrbTests OrbTests/PDFTextExtractorTests.swift
add OrbIntegrationTests OrbIntegrationTests/PDFTextExtractorIntegrationTests.swift
commit "feat(capture): add PDF text extraction"

# 12.5
add Orb Orb/Capture/DocumentTextExtractor.swift
add OrbTests OrbTests/DocumentTextExtractorTests.swift
add OrbIntegrationTests OrbIntegrationTests/DocumentTextExtractorIntegrationTests.swift
commit "feat(capture): add plain document text extractor"

# 12.6
add Orb Orb/UI/DocumentItemActions.swift
add OrbTests OrbTests/DocumentItemActionsTests.swift
add OrbIntegrationTests OrbIntegrationTests/DocumentItemActionsIntegrationTests.swift
commit "feat(ui): add document open, reveal, and copy actions"

echo done
