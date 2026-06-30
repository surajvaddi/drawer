#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

git checkout HEAD -- Orb.xcodeproj/project.pbxproj

add() {
  local target="$1" file="$2"
  python3 scripts/add_sources.py "$target" "$file" 2>/dev/null || true
  git add "$file"
}

commit() {
  git add Orb.xcodeproj/project.pbxproj
  git commit -m "$1"
}

# 22.1
add Orb Orb/Storage/MigrationV8.swift
git add Orb/Storage/OrbMigrations.swift
add Orb Orb/AI/AIJobQueue.swift
add OrbTests OrbTests/AIJobQueueTests.swift
add OrbIntegrationTests OrbIntegrationTests/AIJobQueueIntegrationTests.swift
commit "feat(ai): add AI job queue repository"

# 22.2
add Orb Orb/AI/AIProvider.swift
add OrbTests OrbTests/AIProviderTests.swift
add OrbIntegrationTests OrbIntegrationTests/AIProviderIntegrationTests.swift
commit "feat(ai): add AIProvider protocol and mock provider"

# 22.3
add Orb Orb/AI/AIPrivacyGate.swift
git add Orb/Services/SettingsStore.swift
add OrbTests OrbTests/AIPrivacyGateTests.swift
add OrbIntegrationTests OrbIntegrationTests/AIPrivacyGateIntegrationTests.swift
commit "feat(ai): add AI privacy policy gate"

# 22.4
add Orb Orb/AI/AIWorker.swift
add Orb Orb/Storage/AIAnnotationRepository.swift
add OrbTests OrbTests/AIWorkerTests.swift
add OrbIntegrationTests OrbIntegrationTests/AIWorkerIntegrationTests.swift
commit "feat(ai): add background AI worker processor"

# 22.5
add Orb Orb/AI/AISettingsView.swift
add OrbTests OrbTests/AISettingsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/AISettingsViewIntegrationTests.swift
commit "feat(ui): add AI settings panel"

# 22.6
add Orb Orb/AI/AIAnnotationViews.swift
add OrbTests OrbTests/AIAnnotationViewsTests.swift
add OrbIntegrationTests OrbIntegrationTests/AIAnnotationViewsIntegrationTests.swift
commit "feat(ui): add AI suggestion display and accept flow"

# 23.1
add Orb Orb/AI/TitleGenerator.swift
add OrbTests OrbTests/TitleGeneratorTests.swift
add OrbIntegrationTests OrbIntegrationTests/TitleGeneratorIntegrationTests.swift
commit "feat(ai): add auto-title generator"

# 23.2
add Orb Orb/AI/SummaryGenerator.swift
add OrbTests OrbTests/SummaryGeneratorTests.swift
add OrbIntegrationTests OrbIntegrationTests/SummaryGeneratorIntegrationTests.swift
commit "feat(ai): add auto-summary generator"

# 23.3
add Orb Orb/AI/TagGenerator.swift
add OrbTests OrbTests/TagGeneratorTests.swift
add OrbIntegrationTests OrbIntegrationTests/TagGeneratorIntegrationTests.swift
commit "feat(ai): add auto-tag generator"

# 23.4
add Orb Orb/AI/FactExtractor.swift
add OrbTests OrbTests/FactExtractorTests.swift
add OrbIntegrationTests OrbIntegrationTests/FactExtractorIntegrationTests.swift
commit "feat(ai): add fact extraction pipeline"

# 23.5
add Orb Orb/AI/DuplicateDetector.swift
add OrbTests OrbTests/DuplicateDetectorTests.swift
add OrbIntegrationTests OrbIntegrationTests/DuplicateDetectorIntegrationTests.swift
commit "feat(ai): add duplicate detection service"

# 23.6
add Orb Orb/AI/RelatedItemsEngine.swift
add OrbTests OrbTests/RelatedItemsEngineTests.swift
add OrbIntegrationTests OrbIntegrationTests/RelatedItemsEngineIntegrationTests.swift
commit "feat(ai): add related items engine"

# 24.1
add Orb Orb/Search/EmbeddingProvider.swift
add OrbTests OrbTests/EmbeddingProviderTests.swift
add OrbIntegrationTests OrbIntegrationTests/EmbeddingProviderIntegrationTests.swift
commit "feat(search): add EmbeddingProvider protocol"

# 24.2
add Orb Orb/Search/EmbeddingIndexer.swift
add OrbTests OrbTests/EmbeddingIndexerTests.swift
add OrbIntegrationTests OrbIntegrationTests/EmbeddingIndexerIntegrationTests.swift
commit "feat(search): add embedding indexer on item save"

# 24.3
add Orb Orb/Search/VectorSearchRepository.swift
add OrbTests OrbTests/VectorSearchRepositoryTests.swift
add OrbIntegrationTests OrbIntegrationTests/VectorSearchRepositoryIntegrationTests.swift
commit "feat(search): add vector similarity search"

# 24.4
add Orb Orb/Search/HybridSearchMerger.swift
add OrbTests OrbTests/HybridSearchMergerTests.swift
add OrbIntegrationTests OrbIntegrationTests/HybridSearchMergerIntegrationTests.swift
commit "feat(search): add hybrid FTS and semantic search merger"

# 24.5
add Orb Orb/Search/DocumentChunker.swift
add OrbTests OrbTests/DocumentChunkerTests.swift
add OrbIntegrationTests OrbIntegrationTests/DocumentChunkerIntegrationTests.swift
commit "feat(search): add document chunk embeddings"

# 24.6
add Orb Orb/Search/SemanticQuickPasteRanker.swift
add OrbTests OrbTests/SemanticQuickPasteRankerTests.swift
add OrbIntegrationTests OrbIntegrationTests/SemanticQuickPasteRankerIntegrationTests.swift
commit "feat(search): add semantic ranking to quick paste"

# 25.1
add Orb Orb/Storage/JSONExportService.swift
add OrbTests OrbTests/JSONExportServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/JSONExportServiceIntegrationTests.swift
commit "feat(storage): add JSON export service"

# 25.2
add Orb Orb/Storage/MarkdownExportService.swift
add OrbTests OrbTests/MarkdownExportServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/MarkdownExportServiceIntegrationTests.swift
commit "feat(storage): add Markdown export service"

# 25.3
add Orb Orb/Storage/ZIPExportService.swift
add OrbTests OrbTests/ZIPExportServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/ZIPExportServiceIntegrationTests.swift
commit "feat(storage): add ZIP archive export with blobs"

# 25.4
add Orb Orb/Storage/JSONImportService.swift
add OrbTests OrbTests/JSONImportServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/JSONImportServiceIntegrationTests.swift
commit "feat(storage): add JSON import service"

# 25.5
add Orb Orb/Storage/MarkdownImportService.swift
add OrbTests OrbTests/MarkdownImportServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/MarkdownImportServiceIntegrationTests.swift
commit "feat(storage): add Markdown and bookmark import"

# 25.6
add Orb Orb/UI/ExportImportView.swift
add OrbTests OrbTests/ExportImportViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/ExportImportViewIntegrationTests.swift
commit "feat(ui): add export and import settings UI"

# 26.1
add Orb Orb/UI/LibraryWindow.swift
add OrbTests OrbTests/LibraryWindowTests.swift
add OrbIntegrationTests OrbIntegrationTests/LibraryWindowIntegrationTests.swift
commit "feat(ui): add full library window shell"

# 26.2
add Orb Orb/UI/BulkOrganizationView.swift
add OrbTests OrbTests/BulkOrganizationViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/BulkOrganizationViewIntegrationTests.swift
commit "feat(ui): add bulk organization view in library"

# 26.3
add Orb Orb/UI/LibrarySearchView.swift
add OrbTests OrbTests/LibrarySearchViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/LibrarySearchViewIntegrationTests.swift
commit "feat(ui): add advanced search in full library"

# 26.4
add Orb Orb/Services/MenuBarController.swift
add OrbTests OrbTests/MenuBarControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/MenuBarControllerIntegrationTests.swift
commit "feat(ui): add menu bar status item and actions"

# 26.5
add Orb Orb/Services/LaunchAtLoginService.swift
add OrbTests OrbTests/LaunchAtLoginServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/LaunchAtLoginServiceIntegrationTests.swift
commit "feat(services): add launch at login support"

# 26.6
add Orb Orb/Services/PresentationModeObserver.swift
add OrbTests OrbTests/PresentationModeObserverTests.swift
add OrbIntegrationTests OrbIntegrationTests/PresentationModeObserverIntegrationTests.swift
commit "feat(ui): hide orb during fullscreen and presentation mode"

# 27.1
add Orb Orb/Services/CrashRecoveryService.swift
add OrbTests OrbTests/CrashRecoveryServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/CrashRecoveryServiceIntegrationTests.swift
commit "feat(services): add crash recovery on launch"

# 27.2
add Orb Orb/Services/ThumbnailRepairService.swift
add OrbTests OrbTests/ThumbnailRepairServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/ThumbnailRepairServiceIntegrationTests.swift
commit "feat(services): add thumbnail repair job"

# 27.3
add Orb Orb/Services/IndexRebuildService.swift
add OrbTests OrbTests/IndexRebuildServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/IndexRebuildServiceIntegrationTests.swift
commit "feat(services): add search index rebuild service"

# 27.4
add Orb Orb/Services/ItemDeletionService.swift
add OrbTests OrbTests/ItemDeletionServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemDeletionServiceIntegrationTests.swift
commit "feat(storage): add transactional item deletion with blob cleanup"

# 27.5
add Orb Orb/Services/DuplicateMergeFlow.swift
add OrbTests OrbTests/DuplicateMergeFlowTests.swift
add OrbIntegrationTests OrbIntegrationTests/DuplicateMergeFlowIntegrationTests.swift
commit "feat(ui): add duplicate merge flow"

# 27.6
add Orb Orb/Services/ErrorReporter.swift
add OrbTests OrbTests/ErrorReporterTests.swift
add OrbIntegrationTests OrbIntegrationTests/ErrorReporterIntegrationTests.swift
commit "feat(ui): add non-intrusive error toasts"

# 28.1
add Orb Orb/UI/LazyBlobImageLoader.swift
add OrbTests OrbTests/LazyBlobImageLoaderTests.swift
add OrbIntegrationTests OrbIntegrationTests/LazyBlobImageLoaderIntegrationTests.swift
commit "perf(ui): add lazy blob loading with memory cap"

# 28.2
add Orb Orb/Search/SearchPerformanceTracer.swift
add OrbTests OrbTests/SearchPerformanceTracerTests.swift
add OrbIntegrationTests OrbIntegrationTests/SearchPerformanceTracerIntegrationTests.swift
commit "perf(search): add search performance tracing and budget tests"

# 28.3
git add Orb/Capture/PasteboardMonitor.swift Orb/Capture/PasteboardProviding.swift
git add OrbTests/PasteboardMonitorTests.swift
git add OrbIntegrationTests/PasteboardMonitorIntegrationTests.swift
commit "perf(capture): optimize clipboard polling efficiency"

# 28.4
add Orb Orb/UI/SaveToastView.swift
add OrbTests OrbTests/SaveToastViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/SaveToastViewIntegrationTests.swift
commit "feat(ui): add save success toast feedback"

# 28.5
add Orb Orb/UI/OrbAnimationPolish.swift
add OrbTests OrbTests/OrbAnimationPolishTests.swift
add OrbIntegrationTests OrbIntegrationTests/OrbAnimationPolishIntegrationTests.swift
commit "feat(ui): polish orb hover, drop, and error animations"

# 28.6
add OrbIntegrationTests OrbIntegrationTests/ActivationFlowTests.swift
git add Orb/Capture/TextNormalizer.swift Orb/Capture/DrawerRuleEvaluator.swift Orb/Storage/DatabaseManager.swift
git add Orb/Capture/SourceAppResolver.swift Orb/Services/ShortcutSettings.swift Orb/Storage/DrawerRepository.swift
git add OrbTests/DrawerRuleEvaluatorTests.swift OrbTests/CaptureEventLoggerTests.swift
git add OrbTests/MockPasteboard.swift OrbTests/DocumentChunkerTests.swift OrbTests/PresentationModeObserverTests.swift
git add OrbTests/JSONExportServiceTests.swift OrbTests/MarkdownExportServiceTests.swift OrbTests/MarkdownImportServiceTests.swift
git add OrbTests/AutoPasteServiceTests.swift OrbTests/PrivateModeControllerTests.swift
git add OrbIntegrationTests/RecencyBoostPolicyIntegrationTests.swift
git add OrbIntegrationTests/AutoPasteServiceIntegrationTests.swift OrbIntegrationTests/PrivateModeControllerIntegrationTests.swift
git add OrbIntegrationTests/AutoPastePermissionGateIntegrationTests.swift OrbIntegrationTests/DrawerKeyboardNavigatorIntegrationTests.swift
git add scripts/add_sources.py scripts/sync_pbxproj_sources.py scripts/add_phase22_28_sources.sh scripts/mark_goals_phases_22_28.py
git add scripts/commit_phases_22_28.sh scripts/generate_phase22_28_tests.py
python3 scripts/sync_pbxproj_sources.py
commit "test: add end-to-end activation and reuse flow tests"

python3 scripts/mark_goals_phases_22_28.py
git add GOALS.md
commit "docs(goals): mark phases 22-28 complete"

echo done
