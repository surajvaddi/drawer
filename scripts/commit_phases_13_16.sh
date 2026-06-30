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

# 13.1
add Orb Orb/UI/CreateDrawerFlow.swift
git add Orb/Storage/DrawerRepository.swift
add OrbTests OrbTests/CreateDrawerFlowTests.swift
add OrbIntegrationTests OrbIntegrationTests/CreateDrawerFlowIntegrationTests.swift
commit "feat(ui): add create drawer flow"

# 13.2
add Orb Orb/Storage/NestedDrawerService.swift
add OrbTests OrbTests/NestedDrawerServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/NestedDrawerServiceIntegrationTests.swift
commit "feat(storage): add nested drawer CRUD with cycle prevention"

# 13.3
add Orb Orb/UI/DrawerStyleEditor.swift
add OrbTests OrbTests/DrawerStyleEditorTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerStyleEditorIntegrationTests.swift
commit "feat(ui): add drawer visual customization editor"

# 13.4
add Orb Orb/Storage/MoveItemToDrawerService.swift
git add Orb/Storage/ItemRepository.swift
add OrbTests OrbTests/MoveItemToDrawerServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/MoveItemToDrawerServiceIntegrationTests.swift
commit "feat(storage): add move item to drawer service"

# 13.5
add Orb Orb/Storage/DrawerRuleRepository.swift
add Orb Orb/Capture/DrawerRuleEvaluator.swift
add OrbTests OrbTests/DrawerRuleEvaluatorTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerRuleEvaluatorIntegrationTests.swift
commit "feat(capture): add drawer rule evaluator"

# 13.6
add Orb Orb/UI/DrawerSuggestionBanner.swift
add OrbTests OrbTests/DrawerSuggestionBannerTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerSuggestionBannerIntegrationTests.swift
commit "feat(ui): add post-capture drawer suggestion banner"

# 14.1
add Orb Orb/UI/TagEditorView.swift
git add Orb/Storage/TagRepository.swift
add OrbTests OrbTests/TagEditorViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/TagEditorViewIntegrationTests.swift
commit "feat(ui): add tag editor with autocomplete"

# 14.2
add Orb Orb/UI/TagFilterController.swift
add OrbTests OrbTests/TagFilterControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/TagFilterControllerIntegrationTests.swift
commit "feat(ui): add tag filter in drawer"

# 14.3
add Orb Orb/UI/ItemFilterController.swift
add OrbTests OrbTests/ItemFilterControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemFilterControllerIntegrationTests.swift
commit "feat(ui): add item type and source app filters"

# 14.4
add Orb Orb/Storage/BulkItemActions.swift
git add Orb/Storage/BlobRepository.swift
add OrbTests OrbTests/BulkItemActionsTests.swift
add OrbIntegrationTests OrbIntegrationTests/BulkItemActionsIntegrationTests.swift
commit "feat(storage): add archive and bulk delete actions"

# 14.5
add Orb Orb/UI/ItemSortController.swift
add OrbTests OrbTests/ItemSortControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/ItemSortControllerIntegrationTests.swift
commit "feat(ui): add per-drawer item sort options"

# 14.6
add Orb Orb/Core/FactCard.swift
add Orb Orb/Storage/MigrationV6.swift
add Orb Orb/Storage/FactCardRepository.swift
git add Orb/Core/Item.swift Orb/Storage/OrbMigrations.swift Orb/Storage/ItemRepository.swift
add OrbTests OrbTests/MigrationV6Tests.swift
add OrbTests OrbTests/FactCardRepositoryTests.swift
add OrbIntegrationTests OrbIntegrationTests/FactCardRepositoryIntegrationTests.swift
commit "feat(core): add fact card model and repository"

# 15.1
add Orb Orb/Search/FTSQueryBuilder.swift
add OrbTests OrbTests/FTSQueryBuilderTests.swift
add OrbIntegrationTests OrbIntegrationTests/FTSQueryBuilderIntegrationTests.swift
commit "feat(search): add FTS query builder"

# 15.2
add Orb Orb/Search/SearchRepository.swift
add OrbTests OrbTests/SearchRepositoryTests.swift
add OrbIntegrationTests OrbIntegrationTests/SearchRepositoryIntegrationTests.swift
commit "feat(search): add FTS search repository"

# 15.3
add Orb Orb/Search/SearchFilterParser.swift
add OrbTests OrbTests/SearchFilterParserTests.swift
add OrbIntegrationTests OrbIntegrationTests/SearchFilterParserIntegrationTests.swift
commit "feat(search): add query filter parser"

# 15.4
add Orb Orb/Search/SearchRanker.swift
add OrbTests OrbTests/SearchRankerTests.swift
add OrbIntegrationTests OrbIntegrationTests/SearchRankerIntegrationTests.swift
commit "feat(search): add weighted search ranker"

# 15.5
add Orb Orb/UI/DrawerSearchController.swift
add OrbTests OrbTests/DrawerSearchControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/DrawerSearchControllerIntegrationTests.swift
commit "feat(ui): wire drawer search bar to search engine"

# 15.6
add Orb Orb/Search/FuzzySearchService.swift
add OrbTests OrbTests/FuzzySearchServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/FuzzySearchServiceIntegrationTests.swift
commit "feat(search): add fuzzy fallback search"

# 16.1
add Orb Orb/UI/QuickPastePanel.swift
add OrbTests OrbTests/QuickPastePanelTests.swift
add OrbIntegrationTests OrbIntegrationTests/QuickPastePanelIntegrationTests.swift
commit "feat(ui): add quick paste panel window"

# 16.2
add Orb Orb/UI/QuickPasteResultsView.swift
add OrbTests OrbTests/QuickPasteResultsViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/QuickPasteResultsViewIntegrationTests.swift
commit "feat(ui): add quick paste result list with keyboard nav"

# 16.3
add Orb Orb/UI/QuickPasteController.swift
add OrbTests OrbTests/QuickPasteControllerTests.swift
add OrbIntegrationTests OrbIntegrationTests/QuickPasteControllerIntegrationTests.swift
commit "feat(ui): add quick paste copy on enter"

# 16.4
add Orb Orb/Services/AutoPasteService.swift
add OrbTests OrbTests/AutoPasteServiceTests.swift
add OrbIntegrationTests OrbIntegrationTests/AutoPasteServiceIntegrationTests.swift
commit "feat(services): add optional auto-paste via accessibility"

# 16.5
add Orb Orb/Search/RecencyBoostPolicy.swift
add OrbTests OrbTests/RecencyBoostPolicyTests.swift
add OrbIntegrationTests OrbIntegrationTests/RecencyBoostPolicyIntegrationTests.swift
commit "feat(search): add recency boost for quick paste"

# 16.6
add Orb Orb/UI/QuickPasteEmptyStateView.swift
add OrbTests OrbTests/QuickPasteEmptyStateViewTests.swift
add OrbIntegrationTests OrbIntegrationTests/QuickPasteEmptyStateViewIntegrationTests.swift
commit "feat(ui): add quick paste empty and no-result states"

echo done
