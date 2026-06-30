# Orb — Development Goals & Phased Plan

This document splits the [Orb product spec](./PRODUCT_SPEC.md) into sequential development phases. Each phase contains atomic **steps**. Each step implements **one function** (one module, pipeline stage, UI element, or integration surface).

## How to Use This Plan

1. Work phases in order unless a step explicitly notes a dependency exception.
2. Complete **one step** before starting the next.
3. For each step: implement the function, add the listed **unit tests** and **integration tests**, verify they pass, then **commit** using the provided commit message.
4. Do not batch multiple steps into one commit.
5. Mark completed steps by changing `[ ]` to `[x]` in this file in a separate housekeeping commit at the end of each phase (optional).

## Test Conventions

- **Unit tests** live in `OrbTests/` and target a single type or function.
- **Integration tests** live in `OrbIntegrationTests/` and exercise real SQLite, filesystem, pasteboard mocks, or UI harnesses.
- Use in-memory SQLite and temp directories in tests unless the step explicitly requires on-disk fixtures.

---

## Phase 0 — Project Bootstrap

Establish the macOS app shell, module layout, and CI test runner.

### Step 0.1: Create Xcode macOS App Target

- [x] **Function:** Scaffold `Orb` macOS app with SwiftUI lifecycle, `AppDelegate`, and empty `ContentView`.
- **Unit tests:**
  - `testAppDelegateInitializesWithoutCrash`
  - `testBundleIdentifierIsSet`
- **Integration tests:**
  - `testAppLaunchesInTestHarness`
- **Commit message:** `chore: scaffold Orb macOS app target with SwiftUI lifecycle`

### Step 0.2: Add Test Targets and CI Script

- [x] **Function:** Add `OrbTests` and `OrbIntegrationTests` targets plus `scripts/test.sh` that runs `xcodebuild test`.
- **Unit tests:**
  - `testTestTargetsAreLinkedToOrb`
- **Integration tests:**
  - `testCIScriptExitsZeroOnGreenBuild`
- **Commit message:** `chore: add unit and integration test targets with CI script`

### Step 0.3: Define Module Folder Structure

- [x] **Function:** Create empty module directories: `Core/`, `Storage/`, `Capture/`, `UI/`, `Search/`, `AI/`, `Services/`.
- **Unit tests:**
  - `testModuleFoldersExist`
- **Integration tests:**
  - `testAppBuildsWithModuleStructure`
- **Commit message:** `chore: establish Orb module directory structure`

### Step 0.4: Add Shared Utilities and Logging

- [x] **Function:** Implement `OrbLogger` (os_log wrapper) and `OrbError` base error enum.
- **Unit tests:**
  - `testLoggerFormatsMessages`
  - `testOrbErrorDescriptionsAreNonEmpty`
- **Integration tests:**
  - `testLoggerWritesToUnifiedLogInIntegration`
- **Commit message:** `feat(core): add shared logging and error types`

---

## Phase 1 — Domain Models

Define pure Swift types mirroring the product data model.

### Step 1.1: Implement ItemType and SensitivityLevel Enums

- [x] **Function:** `ItemType`, `SensitivityLevel`, `CaptureMethod` enums with `Codable` and display metadata.
- **Unit tests:**
  - `testItemTypeCodableRoundTrip`
  - `testAllItemTypesHaveDisplayNames`
  - `testSensitivityLevelOrdering`
- **Integration tests:**
  - `testEnumsDecodeFromFixtureJSON`
- **Commit message:** `feat(core): add ItemType, SensitivityLevel, and CaptureMethod enums`

### Step 1.2: Implement Item Model

- [x] **Function:** `Item` struct with validation helpers (`previewText`, `isEmpty`).
- **Unit tests:**
  - `testItemInitializationWithDefaults`
  - `testItemPreviewTruncation`
  - `testItemEquality`
- **Integration tests:**
  - `testItemEncodesToJSONFixture`
- **Commit message:** `feat(core): add Item domain model`

### Step 1.3: Implement Drawer Model

- [x] **Function:** `Drawer` struct with parent/child helpers and sort order.
- **Unit tests:**
  - `testDrawerRootAndNestedPaths`
  - `testDrawerSortOrderComparison`
- **Integration tests:**
  - `testDrawerTreeDecodesFromFixture`
- **Commit message:** `feat(core): add Drawer domain model`

### Step 1.4: Implement Tag and ItemTag Models

- [x] **Function:** `Tag` and `ItemTag` structs with normalized tag name helper.
- **Unit tests:**
  - `testTagNameNormalization`
  - `testItemTagLinkage`
- **Integration tests:**
  - `testTagsDecodeFromFixtureJSON`
- **Commit message:** `feat(core): add Tag and ItemTag models`

### Step 1.5: Implement Blob, Embedding, and CaptureEvent Models

- [x] **Function:** `Blob`, `Embedding`, `CaptureEvent` structs with kind/method enums.
- **Unit tests:**
  - `testBlobKindPaths`
  - `testEmbeddingVectorValidation`
  - `testCaptureEventMetadataEncoding`
- **Integration tests:**
  - `testCaptureEventRoundTripThroughJSON`
- **Commit message:** `feat(core): add Blob, Embedding, and CaptureEvent models`

### Step 1.6: Implement DrawerRule and AIAnnotation Models

- [x] **Function:** `DrawerRule` and `AIAnnotation` structs with JSON condition payloads.
- **Unit tests:**
  - `testDrawerRulePrioritySort`
  - `testAIAnnotationKindParsing`
- **Integration tests:**
  - `testAIAnnotationRoundTrip`
- **Commit message:** `feat(core): add DrawerRule and AIAnnotation models`

---

## Phase 2 — Storage Engine Foundation

SQLite persistence, migrations, and application support paths.

### Step 2.1: Application Support Path Resolver

- [x] **Function:** `StoragePaths` — resolves `~/Library/Application Support/Orb/` and subfolders (`blobs/`, `indexes/`, `backups/`, `logs/`).
- **Unit tests:**
  - `testStoragePathsCreatesSubdirectories`
  - `testBlobPathsForEachKind`
- **Integration tests:**
  - `testStoragePathsCreatesRealDirectoriesInTempHome`
- **Commit message:** `feat(storage): add application support path resolver`

### Step 2.2: SQLite Connection and Migration Runner

- [x] **Function:** `DatabaseManager` opens SQLite, runs versioned migrations transactionally.
- **Unit tests:**
  - `testMigrationVersionStartsAtZero`
  - `testMigrationsAreIdempotent`
- **Integration tests:**
  - `testDatabaseManagerCreatesOrbSQLiteFile`
- **Commit message:** `feat(storage): add SQLite connection and migration runner`

### Step 2.3: Initial Schema Migration (Items and Drawers)

- [x] **Function:** Migration v1 creating `items` and `drawers` tables with indexes.
- **Unit tests:**
  - `testItemsTableSchemaMatchesModel`
  - `testDrawersTableSupportsParentID`
- **Integration tests:**
  - `testMigrationV1AppliesOnFreshDatabase`
- **Commit message:** `feat(storage): add initial items and drawers schema migration`

### Step 2.4: Tags, Blobs, and Junction Tables Migration

- [x] **Function:** Migration v2 for `tags`, `item_tags`, `blobs`, `capture_events`.
- **Unit tests:**
  - `testForeignKeysEnforced`
  - `testItemTagUniqueConstraint`
- **Integration tests:**
  - `testMigrationV2UpgradesFromV1`
- **Commit message:** `feat(storage): add tags, blobs, and capture_events schema`

### Step 2.5: FTS5 and Embeddings Migration

- [x] **Function:** Migration v3 for `items_fts` virtual table and `embeddings` table.
- **Unit tests:**
  - `testFTSTableTriggersExist`
  - `testEmbeddingDimensionsColumn`
- **Integration tests:**
  - `testFTSIndexesItemOnInsert`
- **Commit message:** `feat(storage): add FTS5 and embeddings schema`

### Step 2.6: DrawerRules and AIAnnotations Migration

- [x] **Function:** Migration v4 for `drawer_rules` and `ai_annotations`.
- **Unit tests:**
  - `testDrawerRuleJSONColumnRoundTrip`
- **Integration tests:**
  - `testMigrationV4FullSchemaPresent`
- **Commit message:** `feat(storage): add drawer_rules and ai_annotations schema`

---

## Phase 3 — Repository Layer

CRUD repositories over the schema.

### Step 3.1: ItemRepository CRUD

- [ ] **Function:** `ItemRepository` — create, read, update, delete, list recent, archive.
- **Unit tests:**
  - `testCreateItemAssignsIDAndTimestamps`
  - `testUpdateItemUpdatesUpdatedAt`
  - `testDeleteItemRemovesRow`
- **Integration tests:**
  - `testItemRepositoryPersistsAcrossReopen`
- **Commit message:** `feat(storage): add ItemRepository CRUD`

### Step 3.2: DrawerRepository CRUD

- [ ] **Function:** `DrawerRepository` — nested drawer fetch, reorder, pin.
- **Unit tests:**
  - `testCreateNestedDrawer`
  - `testReorderDrawersUpdatesSortOrder`
- **Integration tests:**
  - `testDrawerTreePersistsAndReloads`
- **Commit message:** `feat(storage): add DrawerRepository CRUD`

### Step 3.3: TagRepository and ItemTag Linking

- [ ] **Function:** `TagRepository` — create tag, link/unlink to items, list by item.
- **Unit tests:**
  - `testLinkTagToItem`
  - `testTagNameDedupedOnCreate`
- **Integration tests:**
  - `testItemTagsSurviveItemUpdate`
- **Commit message:** `feat(storage): add TagRepository and item tag linking`

### Step 3.4: BlobRepository Metadata Persistence

- [ ] **Function:** `BlobRepository` — register blob metadata linked to items.
- **Unit tests:**
  - `testRegisterBlobStoresChecksum`
  - `testListBlobsByItemAndKind`
- **Integration tests:**
  - `testBlobMetadataMatchesFilesystemEntry`
- **Commit message:** `feat(storage): add BlobRepository metadata persistence`

### Step 3.5: CaptureEventRepository

- [ ] **Function:** `CaptureEventRepository` — log capture events, fetch pending/failed.
- **Unit tests:**
  - `testLogCaptureEventStoresMethod`
  - `testFetchPendingEventsOrderedByDate`
- **Integration tests:**
  - `testCaptureEventLinkedToSavedItem`
- **Commit message:** `feat(storage): add CaptureEventRepository`

---

## Phase 4 — Blob Filesystem Storage

Filesystem-backed binary storage coordinated with DB metadata.

### Step 4.1: BlobStore Write and Read

- [ ] **Function:** `BlobStore` — write bytes to `blobs/originals/`, return path and checksum.
- **Unit tests:**
  - `testWriteBlobCreatesFile`
  - `testChecksumStableForSameContent`
- **Integration tests:**
  - `testBlobStoreUsesApplicationSupportDirectory`
- **Commit message:** `feat(storage): add BlobStore write and read`

### Step 4.2: Thumbnail Generator

- [ ] **Function:** `ThumbnailGenerator` — produce PNG thumbnails for images and PDF first page.
- **Unit tests:**
  - `testGenerateThumbnailFromPNG`
  - `testThumbnailMaxDimensionRespected`
- **Integration tests:**
  - `testThumbnailSavedAsBlobKindThumbnail`
- **Commit message:** `feat(storage): add thumbnail generator for images and PDFs`

### Step 4.3: Transactional Item Save Coordinator

- [ ] **Function:** `StorageCoordinator` — atomic save: blob write + item row + FTS index.
- **Unit tests:**
  - `testRollbackOnDBFailureLeavesNoOrphanBlob`
  - `testCommitOnSuccessUpdatesFTS`
- **Integration tests:**
  - `testSaveTextItemEndToEnd`
- **Commit message:** `feat(storage): add transactional StorageCoordinator`

### Step 4.4: Default Inbox Drawer Seeder

- [ ] **Function:** `DefaultDataSeeder` — create Inbox drawer on first launch.
- **Unit tests:**
  - `testSeederRunsOnlyOnce`
  - `testInboxDrawerIsPinned`
- **Integration tests:**
  - `testFreshInstallHasInboxDrawer`
- **Commit message:** `feat(storage): seed default Inbox drawer on first launch`

---

## Phase 5 — Floating Orb Window

Borderless always-on-top orb shell.

### Step 5.1: FloatingPanel Subclass

- [ ] **Function:** `FloatingOrbPanel` — borderless, transparent, floating level, non-activating.
- **Unit tests:**
  - `testPanelIsFloatingAndBorderless`
  - `testPanelDoesNotStealFocusByDefault`
- **Integration tests:**
  - `testFloatingPanelDisplaysInTestHost`
- **Commit message:** `feat(ui): add FloatingOrbPanel window shell`

### Step 5.2: Orb SwiftUI View (Idle State)

- [ ] **Function:** `OrbView` — circular 48px orb, idle visual state.
- **Unit tests:**
  - `testOrbViewRendersAtConfiguredSize`
  - `testIdleStateShowsIcon`
- **Integration tests:**
  - `testOrbViewSnapshotIdleState`
- **Commit message:** `feat(ui): add idle OrbView circular shell`

### Step 5.3: Orb Drag Repositioning

- [ ] **Function:** `OrbDragController` — drag orb anywhere, persist position in `SettingsStore`.
- **Unit tests:**
  - `testDragUpdatesWindowOrigin`
  - `testPositionPersistsAcrossSessions`
- **Integration tests:**
  - `testDragOrbAcrossMultipleDisplays`
- **Commit message:** `feat(ui): add orb drag repositioning with persistence`

### Step 5.4: Edge Snap Behavior

- [ ] **Function:** `EdgeSnapController` — optional gentle snap to screen edges.
- **Unit tests:**
  - `testSnapToNearestEdgeWithinThreshold`
  - `testNoSnapWhenDisabled`
- **Integration tests:**
  - `testSnapRespectsVisibleFrame`
- **Commit message:** `feat(ui): add optional orb edge snapping`

### Step 5.5: Orb Visual State Machine

- [ ] **Function:** `OrbStateMachine` — idle, clipboardChanged, dragHover, saving, expanded states.
- **Unit tests:**
  - `testTransitionsFromIdleToClipboardChanged`
  - `testInvalidTransitionsRejected`
- **Integration tests:**
  - `testOrbViewReflectsStateMachineChanges`
- **Commit message:** `feat(ui): add orb visual state machine`

### Step 5.6: Orb Pulse Animation on Clipboard Changed

- [ ] **Function:** `OrbPulseAnimation` — single pulse when clipboard changes.
- **Unit tests:**
  - `testPulseTriggersOncePerEvent`
  - `testPulseDoesNotRepeatWhileIdle`
- **Integration tests:**
  - `testClipboardChangeTriggersPulseAnimation`
- **Commit message:** `feat(ui): add orb pulse animation for clipboard changes`

---

## Phase 6 — Clipboard Service

Pasteboard observation and save pipeline.

### Step 6.1: Pasteboard Change Detector

- [ ] **Function:** `PasteboardMonitor` — poll `changeCount`, emit `clipboardDidChange`.
- **Unit tests:**
  - `testDetectsChangeCountIncrement`
  - `testIgnoresDuplicateChangeCount`
- **Integration tests:**
  - `testDetectsRealPasteboardChange`
- **Commit message:** `feat(capture): add pasteboard change detector`

### Step 6.2: Pasteboard Type Classifier

- [ ] **Function:** `PasteboardClassifier` — map available types to `ItemType` candidates.
- **Unit tests:**
  - `testClassifyPlainText`
  - `testClassifyURL`
  - `testClassifyImage`
  - `testClassifyMultipleFiles`
- **Integration tests:**
  - `testClassifyRealPasteboardFixtureSet`
- **Commit message:** `feat(capture): add pasteboard type classifier`

### Step 6.3: Pasteboard Content Reader

- [ ] **Function:** `PasteboardReader` — read best representation (text, URL, image, file URLs).
- **Unit tests:**
  - `testReadPlainText`
  - `testReadFileURLList`
  - `testReadPNGImageData`
- **Integration tests:**
  - `testReadFromSystemPasteboardMock`
- **Commit message:** `feat(capture): add pasteboard content reader`

### Step 6.4: Clipboard Save Pipeline

- [ ] **Function:** `ClipboardSavePipeline` — read → normalize → `StorageCoordinator.save`.
- **Unit tests:**
  - `testSaveTextClipboardCreatesItem`
  - `testSaveImageClipboardCreatesBlob`
- **Integration tests:**
  - `testSaveClipboardAppearsInInbox`
- **Commit message:** `feat(capture): add clipboard save pipeline`

### Step 6.5: Clipboard Write-Back

- [ ] **Function:** `PasteboardWriter` — copy saved item content back to general pasteboard.
- **Unit tests:**
  - `testWriteTextToPasteboard`
  - `testWriteImageToPasteboard`
- **Integration tests:**
  - `testCopyItemThenPasteInExternalApp`
- **Commit message:** `feat(capture): add pasteboard write-back for saved items`

### Step 6.6: Clipboard Pause and Privacy Flags

- [ ] **Function:** `ClipboardWatchSettings` — pause watching, private mode, excluded apps check.
- **Unit tests:**
  - `testPauseStopsChangeNotifications`
  - `testExcludedAppBlocksPulse`
- **Integration tests:**
  - `testExcludedBundleIDSkipsDetection`
- **Commit message:** `feat(capture): add clipboard pause and excluded app checks`

---

## Phase 7 — Capture Classifier and Item Processor

Normalize raw captures into items.

### Step 7.1: URL Detector and Normalizer

- [ ] **Function:** `URLNormalizer` — detect URLs in text, normalize scheme/host.
- **Unit tests:**
  - `testDetectURLInText`
  - `testNormalizeRemovesTrackingParams`
- **Integration tests:**
  - `testURLItemGetsDomainPreview`
- **Commit message:** `feat(capture): add URL detector and normalizer`

### Step 7.2: Text Normalizer

- [ ] **Function:** `TextNormalizer` — trim, collapse whitespace, generate preview.
- **Unit tests:**
  - `testCollapseWhitespace`
  - `testPreviewTruncatesAtLimit`
- **Integration tests:**
  - `testTextItemPreviewMatchesNormalizedContent`
- **Commit message:** `feat(capture): add text normalizer and preview generator`

### Step 7.3: Code Snippet Detector

- [ ] **Function:** `CodeSnippetDetector` — heuristics for code vs prose, language guess.
- **Unit tests:**
  - `testDetectSwiftCodeBlock`
  - `testDetectPythonFromKeywords`
- **Integration tests:**
  - `testCodeClipboardClassifiedAsCodeItem`
- **Commit message:** `feat(capture): add code snippet detector`

### Step 7.4: Item Shell Factory

- [ ] **Function:** `ItemFactory` — build `Item` shell from classified capture payload.
- **Unit tests:**
  - `testFactorySetsTypeAndTimestamps`
  - `testFactoryAssignsInboxDrawerByDefault`
- **Integration tests:**
  - `testFactoryProducesValidItemForEachType`
- **Commit message:** `feat(capture): add ItemFactory for capture payloads`

### Step 7.5: Capture Event Logger Integration

- [ ] **Function:** Wire `CaptureEventRepository` into all save pipelines.
- **Unit tests:**
  - `testClipboardSaveLogsCaptureEvent`
  - `testDragDropLogsCaptureEvent`
- **Integration tests:**
  - `testCaptureEventSurvivesRestart`
- **Commit message:** `feat(capture): log capture events on all save paths`

### Step 7.6: Source App Attribution

- [ ] **Function:** `SourceAppResolver` — capture frontmost app bundle/name/window title.
- **Unit tests:**
  - `testResolveBundleID`
  - `testGracefulFallbackWhenUnknown`
- **Integration tests:**
  - `testSavedItemIncludesSourceAppMetadata`
- **Commit message:** `feat(capture): add source app attribution on capture`

---

## Phase 8 — Drawer UI Shell

Compact drawer column anchored to orb.

### Step 8.1: Drawer Panel Window

- [ ] **Function:** `DrawerPanel` — vertical panel anchored near orb, 360px width, rounded.
- **Unit tests:**
  - `testDrawerAnchorsToOrbPosition`
  - `testDrawerMaxHeight80PercentScreen`
- **Integration tests:**
  - `testDrawerOpensWithin100ms`
- **Commit message:** `feat(ui): add drawer panel window anchored to orb`

### Step 8.2: Drawer Root Layout

- [ ] **Function:** `DrawerView` — sections: search bar, quick actions, inbox, drawers list.
- **Unit tests:**
  - `testDrawerSectionsRender`
  - `testDrawerStartsWithSearchFocused`
- **Integration tests:**
  - `testDrawerOpenCloseViaOrbClick`
- **Commit message:** `feat(ui): add drawer root layout with sections`

### Step 8.3: Search Bar Component

- [ ] **Function:** `DrawerSearchBar` — search field with placeholder and clear button.
- **Unit tests:**
  - `testSearchTextBinding`
  - `testClearButtonResetsQuery`
- **Integration tests:**
  - `testSearchBarAcceptsKeyboardInput`
- **Commit message:** `feat(ui): add drawer search bar component`

### Step 8.4: Quick Actions Row

- [ ] **Function:** `QuickActionsRow` — Save Clipboard, Screenshot, New Drawer buttons.
- **Unit tests:**
  - `testQuickActionCallbacksFire`
- **Integration tests:**
  - `testSaveClipboardQuickActionTriggersPipeline`
- **Commit message:** `feat(ui): add drawer quick actions row`

### Step 8.5: Inbox Item List

- [ ] **Function:** `InboxListView` — recent unsorted items from Inbox drawer.
- **Unit tests:**
  - `testInboxListsMostRecentFirst`
  - `testEmptyInboxShowsPlaceholder`
- **Integration tests:**
  - `testSavedItemAppearsInInboxList`
- **Commit message:** `feat(ui): add inbox item list in drawer`

### Step 8.6: Drawer List Sidebar

- [ ] **Function:** `DrawerListView` — color-coded drawers, expand/collapse nesting.
- **Unit tests:**
  - `testNestedDrawerIndentation`
  - `testDrawerSelectionFiltersItems`
- **Integration tests:**
  - `testSelectingDrawerShowsItsItems`
- **Commit message:** `feat(ui): add nested drawer list sidebar`

---

## Phase 9 — Item Cards and Detail View

Card UI and inline expansion.

### Step 9.1: Item Card Component

- [ ] **Function:** `ItemCardView` — icon, title, preview, source app, relative time.
- **Unit tests:**
  - `testCardRendersLinkIcon`
  - `testCardRendersScreenshotThumbnail`
- **Integration tests:**
  - `testItemCardSnapshotForEachType`
- **Commit message:** `feat(ui): add compact item card component`

### Step 9.2: Item Card Context Menu

- [ ] **Function:** `ItemCardContextMenu` — copy, move, tag, delete actions.
- **Unit tests:**
  - `testContextMenuActionsInvokeCallbacks`
- **Integration tests:**
  - `testDeleteFromContextMenuRemovesItem`
- **Commit message:** `feat(ui): add item card context menu actions`

### Step 9.3: Item Detail Inline Expansion

- [ ] **Function:** `ItemDetailView` — expand card inline with full preview and actions.
- **Unit tests:**
  - `testDetailShowsFullText`
  - `testDetailShowsOCRForScreenshot`
- **Integration tests:**
  - `testExpandCollapsePreservesScrollPosition`
- **Commit message:** `feat(ui): add inline item detail expansion`

### Step 9.4: Item Rename and Notes Editor

- [ ] **Function:** `ItemMetadataEditor` — rename title, add user note.
- **Unit tests:**
  - `testRenameUpdatesItemTitle`
  - `testNotePersistsOnSave`
- **Integration tests:**
  - `testEditedTitleReflectsInSearchIndex`
- **Commit message:** `feat(ui): add item rename and notes editor`

### Step 9.5: Pin and Favorite Toggles

- [ ] **Function:** `ItemPinController` — pin/favorite with repository persistence.
- **Unit tests:**
  - `testTogglePinUpdatesItem`
  - `testPinnedItemsSortHigher`
- **Integration tests:**
  - `testPinnedItemVisibleInPinnedSection`
- **Commit message:** `feat(ui): add pin and favorite toggles for items`

### Step 9.6: Drag-and-Drop Reorder in Drawer

- [ ] **Function:** `ItemReorderController` — drag to reorder within drawer.
- **Unit tests:**
  - `testReorderUpdatesSortMetadata`
- **Integration tests:**
  - `testDragItemIntoDifferentDrawer`
- **Commit message:** `feat(ui): add drag-and-drop item reorder and drawer move`

---

## Phase 10 — Link and Text Item Features

Type-specific processing and previews.

### Step 10.1: Link Metadata Fetcher

- [ ] **Function:** `LinkMetadataFetcher` — fetch title and favicon from URL.
- **Unit tests:**
  - `testParseTitleFromHTML`
  - `testFaviconURLConstruction`
- **Integration tests:**
  - `testFetchMetadataForHTTPSURL`
- **Commit message:** `feat(capture): add link metadata fetcher`

### Step 10.2: Link Item Processor Pipeline

- [ ] **Function:** `LinkItemProcessor` — normalize URL, fetch metadata, save link item.
- **Unit tests:**
  - `testProcessorSetsTitleFromMetadata`
  - `testProcessorFallbackTitleUsesDomain`
- **Integration tests:**
  - `testSaveLinkClipboardEndToEnd`
- **Commit message:** `feat(capture): add link item processor pipeline`

### Step 10.3: Text Item Processor Pipeline

- [ ] **Function:** `TextItemProcessor` — normalize text, assign title from first line.
- **Unit tests:**
  - `testTitleFromFirstLine`
  - `testLongTextGetsPreviewOnly`
- **Integration tests:**
  - `testSaveTextClipboardEndToEnd`
- **Commit message:** `feat(capture): add text item processor pipeline`

### Step 10.4: Rich Clip HTML Processor

- [ ] **Function:** `RichClipProcessor` — store plain text and HTML representations.
- **Unit tests:**
  - `testStoresHTMLAndPlainText`
  - `testStripHTMLForPreview`
- **Integration tests:**
  - `testSaveRichTextClipboardEndToEnd`
- **Commit message:** `feat(capture): add rich clip HTML processor`

### Step 10.5: Link Open and Copy Actions

- [ ] **Function:** `LinkItemActions` — open in browser, copy URL, copy markdown link.
- **Unit tests:**
  - `testCopyMarkdownLinkFormat`
  - `testOpenURLUsesNSWorkspace`
- **Integration tests:**
  - `testOpenLinkActionLaunchesBrowser`
- **Commit message:** `feat(ui): add link open and copy actions`

### Step 10.6: Text Copy and Edit Actions

- [ ] **Function:** `TextItemActions` — copy plain text, edit content in place.
- **Unit tests:**
  - `testCopyWritesTextToPasteboard`
  - `testEditUpdatesContentText`
- **Integration tests:**
  - `testEditTextUpdatesSearchIndex`
- **Commit message:** `feat(ui): add text copy and edit actions`

---

## Phase 11 — Screenshot Capture and OCR

Region capture, image storage, and Vision OCR.

### Step 11.1: Screenshot Region Overlay

- [ ] **Function:** `ScreenshotRegionOverlay` — dim screen, drag to select region.
- **Unit tests:**
  - `testSelectionRectClampedToScreen`
  - `testEscapeCancelsCapture`
- **Integration tests:**
  - `testOverlayCapturesRegionCoordinates`
- **Commit message:** `feat(capture): add screenshot region selection overlay`

### Step 11.2: ScreenCaptureKit Region Capture

- [ ] **Function:** `ScreenshotCaptureService` — capture selected region to PNG data.
- **Unit tests:**
  - `testCaptureReturnsPNGData`
  - `testCaptureHonorsRetinaScale`
- **Integration tests:**
  - `testCaptureScreenRegionIntegration`
- **Commit message:** `feat(capture): add ScreenCaptureKit region capture`

### Step 11.3: Screenshot Save Pipeline

- [ ] **Function:** `ScreenshotSavePipeline` — image blob, thumbnail, screenshot item.
- **Unit tests:**
  - `testSaveCreatesScreenshotItemType`
  - `testThumbnailGeneratedOnSave`
- **Integration tests:**
  - `testScreenshotShortcutSavesToInbox`
- **Commit message:** `feat(capture): add screenshot save pipeline`

### Step 11.4: Vision OCR Service

- [ ] **Function:** `OCRService` — `VNRecognizeTextRequest` on image, return joined text.
- **Unit tests:**
  - `testOCRReturnsTextForSampleImage`
  - `testOCREmptyForBlankImage`
- **Integration tests:**
  - `testOCROnSavedScreenshotBlob`
- **Commit message:** `feat(capture): add Vision OCR service for screenshots`

### Step 11.5: OCR Text Indexing

- [ ] **Function:** `OCRIndexer` — store OCR blob, index text in FTS.
- **Unit tests:**
  - `testOCRTextIndexedForSearch`
  - `testOCRBlobLinkedToItem`
- **Integration tests:**
  - `testSearchFindsScreenshotByOCRText`
- **Commit message:** `feat(capture): index OCR text for screenshot search`

### Step 11.6: Screenshot Card Actions

- [ ] **Function:** `ScreenshotItemActions` — copy image, copy OCR text, open in Preview.
- **Unit tests:**
  - `testCopyImageWritesPNGToPasteboard`
  - `testCopyOCRTextWritesString`
- **Integration tests:**
  - `testScreenshotActionsEndToEnd`
- **Commit message:** `feat(ui): add screenshot copy and preview actions`

---

## Phase 12 — File and Document Import

PDF/text ingestion and text extraction.

### Step 12.1: File Import Validator

- [ ] **Function:** `FileImportValidator` — allowed extensions, size limits, MIME sniff.
- **Unit tests:**
  - `testRejectOversizedFile`
  - `testAcceptPDFAndMarkdown`
- **Integration tests:**
  - `testValidateRealPDF fixture`
- **Commit message:** `feat(capture): add file import validator`

### Step 12.2: File Copy Importer

- [ ] **Function:** `FileImporter` — copy file into `blobs/originals/`, create file item.
- **Unit tests:**
  - `testImportCopiesBytesVerbatim`
  - `testChecksumMatchesOriginal`
- **Integration tests:**
  - `testDropFileOnOrbImportsCopy`
- **Commit message:** `feat(capture): add file copy importer`

### Step 12.3: File Reference Importer

- [ ] **Function:** `FileReferenceImporter` — security-scoped bookmark, store reference path.
- **Unit tests:**
  - `testBookmarkResolveAfterImport`
  - `testReferenceDoesNotDuplicateBytes`
- **Integration tests:**
  - `testReferenceImportSurvivesReopen`
- **Commit message:** `feat(capture): add file reference importer with bookmarks`

### Step 12.4: PDF Text Extractor

- [ ] **Function:** `PDFTextExtractor` — extract text per page from PDF blob.
- **Unit tests:**
  - `testExtractTextFromPDFFixture`
  - `testPageCountDetected`
- **Integration tests:**
  - `testPDFItemGetsSearchableText`
- **Commit message:** `feat(capture): add PDF text extraction`

### Step 12.5: Plain Document Text Extractor

- [ ] **Function:** `DocumentTextExtractor` — TXT, MD, CSV text extraction.
- **Unit tests:**
  - `testExtractMarkdownFile`
  - `testExtractCSVFile`
- **Integration tests:**
  - `testDocumentTextSearchableAfterImport`
- **Commit message:** `feat(capture): add plain document text extractor`

### Step 12.6: Document Card Actions

- [ ] **Function:** `DocumentItemActions` — open, reveal in Finder, copy file/path.
- **Unit tests:**
  - `testRevealInFinderUsesNSURL`
  - `testCopyFileWritesToPasteboard`
- **Integration tests:**
  - `testOpenDocumentInDefaultApp`
- **Commit message:** `feat(ui): add document open, reveal, and copy actions`

---

## Phase 13 — Drawer Management

Create, nest, customize, and rule-based suggestions.

### Step 13.1: Create Drawer Flow

- [ ] **Function:** `CreateDrawerFlow` — name, icon, color picker, save drawer.
- **Unit tests:**
  - `testCreateDrawerValidatesName`
  - `testCreateDrawerAssignsSortOrder`
- **Integration tests:**
  - `testNewDrawerAppearsInDrawerList`
- **Commit message:** `feat(ui): add create drawer flow`

### Step 13.2: Nested Drawer CRUD

- [ ] **Function:** `NestedDrawerService` — reparent drawer, prevent cycles.
- **Unit tests:**
  - `testReparentDrawer`
  - `testCycleReparentRejected`
- **Integration tests:**
  - `testNestedDrawerTreePersists`
- **Commit message:** `feat(storage): add nested drawer CRUD with cycle prevention`

### Step 13.3: Drawer Visual Customization

- [ ] **Function:** `DrawerStyleEditor` — emoji/SF Symbol, color, tint.
- **Unit tests:**
  - `testDrawerColorHexRoundTrip`
  - `testIconTypePersists`
- **Integration tests:**
  - `testDrawerStyleRendersInList`
- **Commit message:** `feat(ui): add drawer visual customization editor`

### Step 13.4: Move Item to Drawer

- [ ] **Function:** `MoveItemToDrawerService` — update `drawerId`, refresh lists.
- **Unit tests:**
  - `testMoveUpdatesDrawerId`
  - `testMoveToNilGoesToInbox`
- **Integration tests:**
  - `testDragItemToDrawerUpdatesPersistence`
- **Commit message:** `feat(storage): add move item to drawer service`

### Step 13.5: Drawer Rule Evaluator

- [ ] **Function:** `DrawerRuleEvaluator` — evaluate URL/content/app conditions, return suggestion.
- **Unit tests:**
  - `testURLContainsRuleMatches`
  - `testSourceAppRuleMatches`
  - `testHighestPriorityWins`
- **Integration tests:**
  - `testGreenhouseURLSuggestsJobsDrawer`
- **Commit message:** `feat(capture): add drawer rule evaluator`

### Step 13.6: Drawer Suggestion UI

- [ ] **Function:** `DrawerSuggestionBanner` — post-capture suggestion with accept/dismiss.
- **Unit tests:**
  - `testAcceptAppliesDrawerToItem`
  - `testDismissLeavesInbox`
- **Integration tests:**
  - `testSuggestionShownAfterLinkSave`
- **Commit message:** `feat(ui): add post-capture drawer suggestion banner`

---

## Phase 14 — Tags and Organization

Tagging, filtering, and bulk actions.

### Step 14.1: Tag Editor Component

- [ ] **Function:** `TagEditorView` — add/remove tags on item with autocomplete.
- **Unit tests:**
  - `testAddTagCreatesTagRecord`
  - `testAutocompleteFiltersExisting`
- **Integration tests:**
  - `testTagsPersistAndDisplayOnCard`
- **Commit message:** `feat(ui): add tag editor with autocomplete`

### Step 14.2: Tag Filter in Drawer

- [ ] **Function:** `TagFilterController` — filter drawer list by selected tag.
- **Unit tests:**
  - `testFilterReturnsOnlyTaggedItems`
  - `testClearFilterRestoresList`
- **Integration tests:**
  - `testTagFilterWorksWithInboxAndDrawers`
- **Commit message:** `feat(ui): add tag filter in drawer`

### Step 14.3: Type and Source Filters

- [ ] **Function:** `ItemFilterController` — filter by `ItemType` and source app.
- **Unit tests:**
  - `testFilterByScreenshotType`
  - `testFilterBySourceApp`
- **Integration tests:**
  - `testCombinedTagAndTypeFilters`
- **Commit message:** `feat(ui): add item type and source app filters`

### Step 14.4: Archive and Bulk Delete

- [ ] **Function:** `BulkItemActions` — multi-select archive/delete.
- **Unit tests:**
  - `testBulkArchiveSetsFlag`
  - `testBulkDeleteRemovesAll`
- **Integration tests:**
  - `testBulkDeleteCleansUpBlobs`
- **Commit message:** `feat(storage): add archive and bulk delete actions`

### Step 14.5: Item Sort Options

- [ ] **Function:** `ItemSortController` — recent, alphabetical, type, access frequency.
- **Unit tests:**
  - `testSortByLastAccessed`
  - `testSortByTitleCaseInsensitive`
- **Integration tests:**
  - `testSortPersistsPerDrawer`
- **Commit message:** `feat(ui): add per-drawer item sort options`

### Step 14.6: Fact Card Model and CRUD

- [ ] **Function:** `FactCardRepository` — create/read/update/delete fact items linked to source.
- **Unit tests:**
  - `testCreateFactLinksSourceItem`
  - `testFactCopyWithSourceFormat`
- **Integration tests:**
  - `testConvertTextSelectionToFactCard`
- **Commit message:** `feat(core): add fact card model and repository`

---

## Phase 15 — Search Engine

FTS keyword search, filters, and ranking.

### Step 15.1: FTS Query Builder

- [ ] **Function:** `FTSQueryBuilder` — build safe FTS5 queries from user input.
- **Unit tests:**
  - `testEscapeSpecialCharacters`
  - `testPrefixSearchQuery`
- **Integration tests:**
  - `testFTSQueryReturnsExpectedHits`
- **Commit message:** `feat(search): add FTS query builder`

### Step 15.2: Search Repository

- [ ] **Function:** `SearchRepository` — keyword search across title, content, OCR, notes.
- **Unit tests:**
  - `testSearchFindsTitleMatch`
  - `testSearchFindsOCRText`
- **Integration tests:**
  - `testSearchUnder150msOn1000Items`
- **Commit message:** `feat(search): add FTS search repository`

### Step 15.3: Query Filter Parser

- [ ] **Function:** `SearchFilterParser` — parse `type:`, `drawer:`, `tag:`, `source:`, date filters.
- **Unit tests:**
  - `testParseTypeFilter`
  - `testParseDateRangeFilters`
  - `testParseTagFilter`
- **Integration tests:**
  - `testCombinedFiltersNarrowResults`
- **Commit message:** `feat(search): add query filter parser`

### Step 15.4: Search Ranker

- [ ] **Function:** `SearchRanker` — weighted scoring per spec §31.
- **Unit tests:**
  - `testTitleMatchRanksHigherThanContent`
  - `testPinnedBoostApplied`
  - `testRecencyBoostApplied`
- **Integration tests:**
  - `testRankerOrdersRealResultSet`
- **Commit message:** `feat(search): add weighted search ranker`

### Step 15.5: Drawer Search Integration

- [ ] **Function:** Wire `DrawerSearchBar` to `SearchRepository` with live results.
- **Unit tests:**
  - `testDebounceSearchInput`
  - `testEmptyQueryShowsRecents`
- **Integration tests:**
  - `testSearchKindDesignsReturnsLinkAndScreenshot`
- **Commit message:** `feat(ui): wire drawer search bar to search engine`

### Step 15.6: Fuzzy Fallback Search

- [ ] **Function:** `FuzzySearchService` — fallback matching when FTS returns few results.
- **Unit tests:**
  - `testFuzzyMatchesTypos`
  - `testFuzzyRespectsThreshold`
- **Integration tests:**
  - `testFuzzyFindsModalWhenTypedModl`
- **Commit message:** `feat(search): add fuzzy fallback search`

---

## Phase 16 — Quick Paste Picker

Keyboard-first retrieval window.

### Step 16.1: QuickPaste Panel Window

- [ ] **Function:** `QuickPastePanel` — compact floating search picker, keyboard focus.
- **Unit tests:**
  - `testPanelOpensOnShortcut`
  - `testPanelClosesOnEsc`
- **Integration tests:**
  - `testQuickPasteOpensWithoutMainWindow`
- **Commit message:** `feat(ui): add quick paste panel window`

### Step 16.2: QuickPaste Result List

- [ ] **Function:** `QuickPasteResultsView` — compact result list with keyboard selection.
- **Unit tests:**
  - `testArrowKeysChangeSelection`
  - `testEnterInvokesCopy`
- **Integration tests:**
  - `testTypeQueryShowsRankedResults`
- **Commit message:** `feat(ui): add quick paste result list with keyboard nav`

### Step 16.3: QuickPaste Copy Action

- [ ] **Function:** `QuickPasteController` — copy selected item to pasteboard on Enter.
- **Unit tests:**
  - `testEnterCopiesSelectedItem`
  - `testUpdatesLastAccessedAt`
- **Integration tests:**
  - `testQuickPasteCopyThenSystemPaste`
- **Commit message:** `feat(ui): add quick paste copy on enter`

### Step 16.4: Optional Auto-Paste Mode

- [ ] **Function:** `AutoPasteService` — optional paste into frontmost app via Accessibility.
- **Unit tests:**
  - `testAutoPasteRequiresPermission`
  - `testAutoPasteDisabledByDefault`
- **Integration tests:**
  - `testAutoPasteSimulatedKeystroke`
- **Commit message:** `feat(services): add optional auto-paste via accessibility`

### Step 16.5: Recent Items Boost in Quick Paste

- [ ] **Function:** `RecencyBoostPolicy` — rank recently used items higher in picker.
- **Unit tests:**
  - `testRecentAccessIncreasesScore`
  - `testBoostDecaysOverTime`
- **Integration tests:**
  - `testQuickPasteShowsRecentItemFirst`
- **Commit message:** `feat(search): add recency boost for quick paste`

### Step 16.6: QuickPaste Empty and No-Result States

- [ ] **Function:** `QuickPasteEmptyStateView` — helpful empty/no-result UI.
- **Unit tests:**
  - `testEmptyQueryShowsRecents`
  - `testNoResultsShowsSuggestions`
- **Integration tests:**
  - `testNoResultDoesNotCrashOnEnter`
- **Commit message:** `feat(ui): add quick paste empty and no-result states`

---

## Phase 17 — Global Hotkeys and Keyboard UX

System-wide shortcuts and drawer keyboard navigation.

### Step 17.1: Global Hotkey Registrar

- [ ] **Function:** `HotkeyService` — register/unregister global shortcuts (Carbon or CGEvent tap).
- **Unit tests:**
  - `testRegisterDefaultShortcuts`
  - `testUnregisterOnDeinit`
- **Integration tests:**
  - `testSaveClipboardShortcutInvokesPipeline`
- **Commit message:** `feat(services): add global hotkey registrar`

### Step 17.2: Configurable Shortcut Storage

- [ ] **Function:** `ShortcutSettings` — persist customizable key combos.
- **Unit tests:**
  - `testOverrideDefaultShortcut`
  - `testDetectShortcutConflicts`
- **Integration tests:**
  - `testCustomShortcutTriggersAction`
- **Commit message:** `feat(services): add configurable shortcut storage`

### Step 17.3: Drawer Keyboard Navigation

- [ ] **Function:** `DrawerKeyboardNavigator` — arrows, Enter, Space, Delete in drawer.
- **Unit tests:**
  - `testArrowMovesSelection`
  - `testSpaceOpensPreview`
  - `testDeleteArchivesItem`
- **Integration tests:**
  - `testKeyboardOnlyRetrieveItemFlow`
- **Commit message:** `feat(ui): add drawer keyboard navigation`

### Step 17.4: Command Palette

- [ ] **Function:** `CommandPalette` — searchable commands for core actions.
- **Unit tests:**
  - `testFilterCommandsByQuery`
  - `testExecuteSelectedCommand`
- **Integration tests:**
  - `testCommandPaletteSaveClipboard`
- **Commit message:** `feat(ui): add command palette`

### Step 17.5: Toggle Drawer Shortcut

- [ ] **Function:** Wire Cmd+Shift+O to open/close drawer from any app.
- **Unit tests:**
  - `testToggleOpensClosedDrawer`
  - `testToggleClosesOpenDrawer`
- **Integration tests:**
  - `testToggleDrawerShortcutEndToEnd`
- **Commit message:** `feat(services): add toggle drawer global shortcut`

### Step 17.6: Screenshot Shortcut

- [ ] **Function:** Wire Cmd+Shift+2 to start screenshot capture pipeline.
- **Unit tests:**
  - `testScreenshotShortcutStartsOverlay`
- **Integration tests:**
  - `testScreenshotShortcutEndToEnd`
- **Commit message:** `feat(services): add screenshot global shortcut`

---

## Phase 18 — Drag-and-Drop Capture

Orb as drop target and drag-out source.

### Step 18.1: Orb Drop Target Registration

- [ ] **Function:** `OrbDropTarget` — register for text, URL, file, image drops.
- **Unit tests:**
  - `testAcceptsRegisteredUTTypes`
  - `testRejectUnsupportedTypes`
- **Integration tests:**
  - `testDropTextOnOrbSavesItem`
- **Commit message:** `feat(capture): register orb as drag-and-drop target`

### Step 18.2: Drop Hover Visual State

- [ ] **Function:** Wire drag-hover to `OrbStateMachine` dragHover state and label.
- **Unit tests:**
  - `testDragEnterSetsDragHover`
  - `testDragExitReturnsIdle`
- **Integration tests:**
  - `testDropHoverShowsDropToSaveLabel`
- **Commit message:** `feat(ui): add orb drop hover visual state`

### Step 18.3: File Drop Import Pipeline

- [ ] **Function:** `FileDropPipeline` — dropped files → `FileImporter` / reference flow.
- **Unit tests:**
  - `testDropSinglePDFImports`
  - `testDropMultipleFilesCreatesMultipleItems`
- **Integration tests:**
  - `testDropPDFOnOrbAppearsInInbox`
- **Commit message:** `feat(capture): add file drop import pipeline`

### Step 18.4: Image and Text Drop Pipeline

- [ ] **Function:** `ImageDropPipeline` and `TextDropPipeline` — direct save from drops.
- **Unit tests:**
  - `testDropPNGCreatesImageItem`
  - `testDropURLStringCreatesLinkItem`
- **Integration tests:**
  - `testDropImageOnOrbGeneratesThumbnail`
- **Commit message:** `feat(capture): add image and text drop pipelines`

### Step 18.5: Drag Item Out of Drawer

- [ ] **Function:** `ItemDragSource` — drag item content into external apps.
- **Unit tests:**
  - `testDragProvidesTextPayload`
  - `testDragProvidesFileURLForDocuments`
- **Integration tests:**
  - `testDragSnippetIntoTextEdit`
- **Commit message:** `feat(ui): add drag-out item source for external apps`

### Step 18.6: Drag Item Between Drawers

- [ ] **Function:** Enhance drop handling on drawer rows for move semantics.
- **Unit tests:**
  - `testDropOnDrawerRowMovesItem`
- **Integration tests:**
  - `testDragBetweenDrawersPersists`
- **Commit message:** `feat(ui): add drag-and-drop move between drawers`

---

## Phase 19 — Privacy and Sensitive Content

Detection, warnings, private drawers, exclusions.

### Step 19.1: Sensitive Content Detector

- [ ] **Function:** `SensitiveContentDetector` — regex/heuristics for keys, cards, SSN, secrets.
- **Unit tests:**
  - `testDetectAWSKeyPattern`
  - `testDetectCreditCardNumber`
  - `testDetectPrivateKeyBlock`
  - `testNoFalsePositiveOnNormalText`
- **Integration tests:**
  - `testDetectorRunsOnClipboardBeforeSave`
- **Commit message:** `feat(privacy): add sensitive content detector`

### Step 19.2: Sensitive Save Warning Dialog

- [ ] **Function:** `SensitiveSaveAlert` — save once / private drawer / don't save.
- **Unit tests:**
  - `testDontSaveAbortsPipeline`
  - `testSaveToPrivateRoutesToPrivateDrawer`
- **Integration tests:**
  - `testSensitiveClipboardShowsWarning`
- **Commit message:** `feat(privacy): add sensitive save warning dialog`

### Step 19.3: Private Drawer Flag and Encryption Stub

- [ ] **Function:** `PrivateDrawerService` — mark drawer private, encrypt-at-rest stub interface.
- **Unit tests:**
  - `testPrivateDrawerExcludedFromDefaultSearch`
  - `testEncryptionInterfacePluggable`
- **Integration tests:**
  - `testPrivateDrawerItemsHiddenUntilUnlocked`
- **Commit message:** `feat(privacy): add private drawer flag and encryption interface`

### Step 19.4: Excluded Apps Manager

- [ ] **Function:** `ExcludedAppsManager` — persist and check excluded bundle IDs.
- **Unit tests:**
  - `testAddRemoveExcludedApp`
  - `testExcludedAppBlocksClipboardPulse`
- **Integration tests:**
  - `testExcludedAppClipboardNotDetected`
- **Commit message:** `feat(privacy): add excluded apps manager`

### Step 19.5: Clear Unsaved Clipboard Previews

- [ ] **Function:** `ClipboardPreviewCleaner` — auto-clear ephemeral preview data.
- **Unit tests:**
  - `testPreviewClearsAfterTimeout`
  - `testPreviewClearsOnPause`
- **Integration tests:**
  - `testNoPersistentStorageOfUnsavedClipboard`
- **Commit message:** `feat(privacy): clear unsaved clipboard previews automatically`

### Step 19.6: Private Mode Toggle

- [ ] **Function:** `PrivateModeController` — global pause of capture, search, and AI.
- **Unit tests:**
  - `testPrivateModeBlocksSave`
  - `testPrivateModeBadgeOnOrb`
- **Integration tests:**
  - `testPrivateModeEndToEnd`
- **Commit message:** `feat(privacy): add global private mode toggle`

---

## Phase 20 — Permissions Manager

Permission UX and graceful degradation.

### Step 20.1: Permission Status Reader

- [ ] **Function:** `PermissionService` — read clipboard, accessibility, screen recording status.
- **Unit tests:**
  - `testPermissionStatesMappedCorrectly`
- **Integration tests:**
  - `testPermissionServiceReadsSystemState`
- **Commit message:** `feat(services): add permission status reader`

### Step 20.2: Permission Explanation Views

- [ ] **Function:** `PermissionOnboardingView` — explain why each permission is needed.
- **Unit tests:**
  - `testEachPermissionHasExplanationText`
- **Integration tests:**
  - `testOpenSystemSettingsDeepLink`
- **Commit message:** `feat(ui): add permission explanation onboarding views`

### Step 20.3: Screen Recording Permission Gate

- [ ] **Function:** Gate `ScreenshotCaptureService` behind screen recording permission.
- **Unit tests:**
  - `testCaptureBlockedWithoutPermission`
  - `testFallbackMessageShown`
- **Integration tests:**
  - `testScreenshotShortcutPromptsPermission`
- **Commit message:** `feat(services): gate screenshot capture on screen recording permission`

### Step 20.4: Accessibility Permission Gate

- [ ] **Function:** Gate `AutoPasteService` behind accessibility permission.
- **Unit tests:**
  - `testAutoPasteBlockedWithoutAXPermission`
- **Integration tests:**
  - `testCopyStillWorksWithoutAccessibility`
- **Commit message:** `feat(services): gate auto-paste on accessibility permission`

### Step 20.5: Permission Degradation Policy

- [ ] **Function:** `PermissionDegradationPolicy` — central feature availability matrix.
- **Unit tests:**
  - `testPolicyMatchesSpecSection21_3`
- **Integration tests:**
  - `testAppUsableWithAllPermissionsDenied`
- **Commit message:** `feat(services): add permission degradation policy`

### Step 20.6: File Access Permission Helper

- [ ] **Function:** `FileAccessPermissionHelper` — NSOpenPanel and security-scoped bookmarks.
- **Unit tests:**
  - `testBookmarkCreatedOnUserSelection`
- **Integration tests:**
  - `testReferenceImportAfterUserGrantsAccess`
- **Commit message:** `feat(services): add file access permission helper`

---

## Phase 21 — Settings

Persistent user preferences.

### Step 21.1: SettingsStore Foundation

- [ ] **Function:** `SettingsStore` — UserDefaults + SQLite overlay for app settings.
- **Unit tests:**
  - `testSettingsDefaultsApplied`
  - `testSettingsPersistAcrossLaunch`
- **Integration tests:**
  - `testSettingsStoreBacksUISettings`
- **Commit message:** `feat(services): add SettingsStore foundation`

### Step 21.2: General Settings (Orb Appearance)

- [ ] **Function:** `GeneralSettingsView` — size, opacity, color, snap, hide in fullscreen.
- **Unit tests:**
  - `testOrbSizeUpdatesOrbView`
  - `testOpacityClampedZeroToOne`
- **Integration tests:**
  - `testGeneralSettingsApplyLiveToOrb`
- **Commit message:** `feat(ui): add general orb appearance settings`

### Step 21.3: Capture Settings

- [ ] **Function:** `CaptureSettingsView` — pulse, default drawer, auto-save toggles.
- **Unit tests:**
  - `testPauseClipboardWatcherSetting`
  - `testDefaultDrawerSelection`
- **Integration tests:**
  - `testCaptureSettingsAffectClipboardService`
- **Commit message:** `feat(ui): add capture settings panel`

### Step 21.4: Search and Paste Settings

- [ ] **Function:** `SearchSettingsView` — quick paste behavior, private items, ranking toggles.
- **Unit tests:**
  - `testIncludeOCRSettingAffectsSearch`
  - `testEnterCopiesVsPastesSetting`
- **Integration tests:**
  - `testSearchSettingsAffectQuickPaste`
- **Commit message:** `feat(ui): add search and paste settings`

### Step 21.5: Privacy Settings

- [ ] **Function:** `PrivacySettingsView` — excluded apps, sensitive detection, delete all data.
- **Unit tests:**
  - `testDeleteAllDataWipesDBAndBlobs`
- **Integration tests:**
  - `testPrivacySettingsLinkedToManagers`
- **Commit message:** `feat(ui): add privacy settings panel`

### Step 21.6: Storage Settings

- [ ] **Function:** `StorageSettingsView` — import vs reference default, cache size, backup path.
- **Unit tests:**
  - `testImportVsReferenceDefault`
  - `testCacheSizeLimitEvictsThumbnails`
- **Integration tests:**
  - `testStorageSettingsAffectImporter`
- **Commit message:** `feat(ui): add storage settings panel`

---

## Phase 22 — AI Processing Queue

Async AI job infrastructure with privacy gates.

### Step 22.1: AI Job Queue Repository

- [ ] **Function:** `AIJobQueue` — enqueue, dequeue, status transitions, retry.
- **Unit tests:**
  - `testEnqueueSetsPendingStatus`
  - `testRetryFailedJob`
- **Integration tests:**
  - `testQueuePersistsAcrossRelaunch`
- **Commit message:** `feat(ai): add AI job queue repository`

### Step 22.2: AI Provider Protocol

- [ ] **Function:** `AIProvider` protocol — summarize, title, tags, facts methods.
- **Unit tests:**
  - `testMockProviderReturnsDeterministicOutput`
- **Integration tests:**
  - `testProviderSwapDoesNotChangeQueueContract`
- **Commit message:** `feat(ai): add AIProvider protocol and mock provider`

### Step 22.3: AI Privacy Policy Gate

- [ ] **Function:** `AIPrivacyGate` — local-only, ask-before-cloud, exclude private drawers.
- **Unit tests:**
  - `testPrivateDrawerSkipsCloud`
  - `testAskModeRequiresApproval`
- **Integration tests:**
  - `testSensitiveItemRequiresPermissionState`
- **Commit message:** `feat(ai): add AI privacy policy gate`

### Step 22.4: AI Worker Processor

- [ ] **Function:** `AIWorker` — background process jobs, write `AIAnnotation` records.
- **Unit tests:**
  - `testWorkerWritesTitleAnnotation`
  - `testWorkerMarksFailedOnError`
- **Integration tests:**
  - `testSavedItemGetsAIAnnotationsAfterWorker`
- **Commit message:** `feat(ai): add background AI worker processor`

### Step 22.5: AI Settings Panel

- [ ] **Function:** `AISettingsView` — enable AI, provider, per-feature toggles.
- **Unit tests:**
  - `testDisableAIStopsEnqueue`
- **Integration tests:**
  - `testAISettingsAffectPrivacyGate`
- **Commit message:** `feat(ui): add AI settings panel`

### Step 22.6: AI Suggestion UI on Items

- [ ] **Function:** `AIAnnotationViews` — show suggested title/tags/summary with accept/edit.
- **Unit tests:**
  - `testAcceptTitleUpdatesItem`
  - `testDismissLeavesOriginal`
- **Integration tests:**
  - `testAIAnnotationsVisibleOnItemDetail`
- **Commit message:** `feat(ui): add AI suggestion display and accept flow`

---

## Phase 23 — AI Features

Title, summary, tags, facts, duplicates.

### Step 23.1: Auto-Title Generator

- [ ] **Function:** `TitleGenerator` — generate concise title from content via `AIProvider`.
- **Unit tests:**
  - `testTitleFallsBackToFirstLine`
  - `testTitleMaxLengthEnforced`
- **Integration tests:**
  - `testLongTextItemGetsGeneratedTitle`
- **Commit message:** `feat(ai): add auto-title generator`

### Step 23.2: Auto-Summary Generator

- [ ] **Function:** `SummaryGenerator` — one-line and bullet summaries.
- **Unit tests:**
  - `testSummarySkippedForShortText`
  - `testSummaryStoredAsAIAnnotation`
- **Integration tests:**
  - `testPDFItemGetsSummaryAfterProcessing`
- **Commit message:** `feat(ai): add auto-summary generator`

### Step 23.3: Auto-Tag Generator

- [ ] **Function:** `TagGenerator` — suggest lightweight tags, user confirm before apply.
- **Unit tests:**
  - `testTagsDedupedAndNormalized`
  - `testMaxTagsLimit`
- **Integration tests:**
  - `testSuggestedTagsAppearInTagEditor`
- **Commit message:** `feat(ai): add auto-tag generator`

### Step 23.4: Fact Extraction Pipeline

- [ ] **Function:** `FactExtractor` — extract atomic facts into `FactCard` items.
- **Unit tests:**
  - `testExtractFactsFromJobDescription`
  - `testFactsLinkToParentItem`
- **Integration tests:**
  - `testExtractFactsEndToEnd`
- **Commit message:** `feat(ai): add fact extraction pipeline`

### Step 23.5: Duplicate Detection Service

- [ ] **Function:** `DuplicateDetector` — URL, text hash, file checksum, image hash.
- **Unit tests:**
  - `testDetectDuplicateURL`
  - `testDetectDuplicateTextHash`
  - `testDetectDuplicateFileChecksum`
- **Integration tests:**
  - `testDuplicateSaveShowsMergeDialog`
- **Commit message:** `feat(ai): add duplicate detection service`

### Step 23.6: Related Items Engine

- [ ] **Function:** `RelatedItemsEngine` — same URL, drawer, tags, semantic neighbors.
- **Unit tests:**
  - `testRelatedBySharedTags`
  - `testRelatedBySameSourceURL`
- **Integration tests:**
  - `testRelatedItemsShownInDetailView`
- **Commit message:** `feat(ai): add related items engine`

---

## Phase 24 — Semantic Search

Embeddings and vector recall.

### Step 24.1: Embedding Provider Protocol

- [ ] **Function:** `EmbeddingProvider` — local or remote text embeddings.
- **Unit tests:**
  - `testMockEmbeddingDeterministicDimension`
- **Integration tests:**
  - `testEmbeddingProviderHandlesBatch`
- **Commit message:** `feat(search): add EmbeddingProvider protocol`

### Step 24.2: Embedding Indexer

- [ ] **Function:** `EmbeddingIndexer` — generate and store embeddings on save/update.
- **Unit tests:**
  - `testIndexerStoresVectorHash`
  - `testReindexOnContentChange`
- **Integration tests:**
  - `testItemSearchableViaEmbeddingAfterIndex`
- **Commit message:** `feat(search): add embedding indexer on item save`

### Step 24.3: Vector Similarity Search

- [ ] **Function:** `VectorSearchRepository` — cosine similarity search over embeddings.
- **Unit tests:**
  - `testCosineSimilarityRanking`
  - `testMinScoreThreshold`
- **Integration tests:**
  - `testSemanticQueryFindsRelatedConcreteItems`
- **Commit message:** `feat(search): add vector similarity search`

### Step 24.4: Hybrid Search Merger

- [ ] **Function:** `HybridSearchMerger` — merge FTS and vector results with unified ranking.
- **Unit tests:**
  - `testMergerDeduplicatesItems`
  - `testSemanticWeightApplied`
- **Integration tests:**
  - `testConceptualQueryRanksSemanticMatch`
- **Commit message:** `feat(search): add hybrid FTS and semantic search merger`

### Step 24.5: Document Chunk Embeddings

- [ ] **Function:** `DocumentChunker` — chunk long PDFs/text, embed chunks, link to parent.
- **Unit tests:**
  - `testChunkSizeAndOverlap`
  - `testChunkLinksToParentItem`
- **Integration tests:**
  - `testSearchSurfacesBestMatchingChunk`
- **Commit message:** `feat(search): add document chunk embeddings`

### Step 24.6: Semantic Quick Paste Boost

- [ ] **Function:** Integrate semantic scores into quick paste ranking.
- **Unit tests:**
  - `testSemanticScoreBlendedWithRecency`
- **Integration tests:**
  - `testQuickPasteFindsVagueConceptualQuery`
- **Commit message:** `feat(search): add semantic ranking to quick paste`

---

## Phase 25 — Export and Import

Backup, portability, and restore.

### Step 25.1: JSON Export Service

- [ ] **Function:** `JSONExportService` — export items, drawers, tags to JSON archive.
- **Unit tests:**
  - `testExportIncludesAllEntities`
  - `testExportValidJSON`
- **Integration tests:**
  - `testExportImportRoundTrip`
- **Commit message:** `feat(storage): add JSON export service`

### Step 25.2: Markdown Export Service

- [ ] **Function:** `MarkdownExportService` — export drawer hierarchy as Markdown files.
- **Unit tests:**
  - `testMarkdownIncludesMetadata`
  - `testFactsRenderedAsList`
- **Integration tests:**
  - `testExportMarkdownMatchesFixture`
- **Commit message:** `feat(storage): add Markdown export service`

### Step 25.3: ZIP Archive Export

- [ ] **Function:** `ZIPExportService` — bundle JSON/Markdown plus blobs into ZIP.
- **Unit tests:**
  - `testZIPContainsBlobsAndManifest`
- **Integration tests:**
  - `testExportZIPRestoresViaImport`
- **Commit message:** `feat(storage): add ZIP archive export with blobs`

### Step 25.4: JSON Import Service

- [ ] **Function:** `JSONImportService` — import archive with duplicate resolution options.
- **Unit tests:**
  - `testImportSkipsDuplicatesWhenConfigured`
  - `testImportPreservesDrawerHierarchy`
- **Integration tests:**
  - `testImportJSONRestoresLibrary`
- **Commit message:** `feat(storage): add JSON import service`

### Step 25.5: Markdown and Bookmarks Import

- [ ] **Function:** `MarkdownImportService` — import `.md` files and browser bookmark HTML.
- **Unit tests:**
  - `testImportMarkdownCreatesTextItems`
  - `testImportBookmarksCreatesLinkItems`
- **Integration tests:**
  - `testImportBookmarksFolder`
- **Commit message:** `feat(storage): add Markdown and bookmark import`

### Step 25.6: Export UI and Manual Backup

- [ ] **Function:** `ExportImportView` — user-triggered export/import with progress.
- **Unit tests:**
  - `testExportShowsProgressAndCompletion`
- **Integration tests:**
  - `testManualBackupAndRestoreFlow`
- **Commit message:** `feat(ui): add export and import settings UI`

---

## Phase 26 — Full Library Window

Detached management surface and menu bar presence.

### Step 26.1: Full Library Window Shell

- [ ] **Function:** `LibraryWindow` — standard window with sidebar and main content.
- **Unit tests:**
  - `testLibraryWindowOpensFromMenu`
- **Integration tests:**
  - `testLibraryShowsAllDrawersAndItems`
- **Commit message:** `feat(ui): add full library window shell`

### Step 26.2: Bulk Organization View

- [ ] **Function:** `BulkOrganizationView` — multi-select, move, tag, archive in library.
- **Unit tests:**
  - `testBulkMoveInLibrary`
- **Integration tests:**
  - `testBulkOrganizationEndToEnd`
- **Commit message:** `feat(ui): add bulk organization view in library`

### Step 26.3: Advanced Search in Library

- [ ] **Function:** `LibrarySearchView` — full search with filters and larger previews.
- **Unit tests:**
  - `testLibrarySearchUsesHybridMerger`
- **Integration tests:**
  - `testAdvancedSearchAcrossEntireLibrary`
- **Commit message:** `feat(ui): add advanced search in full library`

### Step 26.4: Menu Bar Status Item

- [ ] **Function:** `MenuBarController` — show/hide orb, open drawer, pause capture.
- **Unit tests:**
  - `testMenuBarToggleOrbVisibility`
- **Integration tests:**
  - `testMenuBarActionsWorkWithoutOrbClick`
- **Commit message:** `feat(ui): add menu bar status item and actions`

### Step 26.5: Launch at Login

- [ ] **Function:** `LaunchAtLoginService` — SMAppService login item toggle.
- **Unit tests:**
  - `testLaunchAtLoginTogglePersists`
- **Integration tests:**
  - `testLoginItemRegisteredWithServiceManagement`
- **Commit message:** `feat(services): add launch at login support`

### Step 26.6: Hide Orb in Full Screen and Presentation

- [ ] **Function:** `PresentationModeObserver` — auto-hide orb in fullscreen/presentation.
- **Unit tests:**
  - `testHideWhenFullscreenAppActive`
  - `testRestoreWhenExitingFullscreen`
- **Integration tests:**
  - `testOrbHiddenDuringPresentationMode`
- **Commit message:** `feat(ui): hide orb during fullscreen and presentation mode`

---

## Phase 27 — Reliability and Crash Recovery

Data safety, repair, and duplicate handling.

### Step 27.1: Crash Recovery on Launch

- [ ] **Function:** `CrashRecoveryService` — verify pending captures, resume queues on launch.
- **Unit tests:**
  - `testRecoverPendingCaptureEvent`
  - `testDeleteOrphanBlobsWithoutDBRows`
- **Integration tests:**
  - `testSimulatedCrashRecoveryRestoresConsistency`
- **Commit message:** `feat(services): add crash recovery on launch`

### Step 27.2: Thumbnail Repair Job

- [ ] **Function:** `ThumbnailRepairService` — regenerate missing thumbnails.
- **Unit tests:**
  - `testRepairCreatesMissingThumbnail`
- **Integration tests:**
  - `testRepairRunsOnLaunchWhenNeeded`
- **Commit message:** `feat(services): add thumbnail repair job`

### Step 27.3: Index Rebuild Service

- [ ] **Function:** `IndexRebuildService` — rebuild FTS and embeddings if corrupted.
- **Unit tests:**
  - `testRebuildFTSFromItems`
  - `testRebuildEmbeddingsQueue`
- **Integration tests:**
  - `testIndexRebuildRestoresSearch`
- **Commit message:** `feat(services): add search index rebuild service`

### Step 27.4: Transactional Delete with Blob Cleanup

- [ ] **Function:** `ItemDeletionService` — coordinated delete of item, blobs, tags, embeddings.
- **Unit tests:**
  - `testDeleteRemovesAllAssociatedRecords`
  - `testDeleteRemovesFilesystemBlobs`
- **Integration tests:**
  - `testDeleteItemFullyCleanup`
- **Commit message:** `feat(storage): add transactional item deletion with blob cleanup`

### Step 27.5: Duplicate Merge Flow

- [ ] **Function:** `DuplicateMergeFlow` — keep both, merge, replace, link duplicate UI.
- **Unit tests:**
  - `testMergeCombinesTagsAndNotes`
  - `testReplaceDeletesOlderItem`
- **Integration tests:**
  - `testDuplicateURLSaveShowsMergeDialog`
- **Commit message:** `feat(ui): add duplicate merge flow`

### Step 27.6: Error Toast and Non-Intrusive Reporting

- [ ] **Function:** `ErrorReporter` — surface save/index/AI errors via subtle toasts.
- **Unit tests:**
  - `testErrorToastAutoDismisses`
- **Integration tests:**
  - `testSaveFailureShowsToastWithoutCrash`
- **Commit message:** `feat(ui): add non-intrusive error toasts`

---

## Phase 28 — Performance and Polish

Latency targets, memory, and final UX refinements.

### Step 28.1: Lazy Blob Loading in UI

- [ ] **Function:** `LazyBlobImageLoader` — async thumbnail loading with memory cache cap.
- **Unit tests:**
  - `testLoaderEvictsWhenOverBudget`
- **Integration tests:**
  - `testDrawerScrollStaysAbove55FPS`
- **Commit message:** `perf(ui): add lazy blob loading with memory cap`

### Step 28.2: Search Performance Budget Guard

- [ ] **Function:** `SearchPerformanceTracer` — assert search latency < 150ms in integration tests.
- **Unit tests:**
  - `testTracerFlagsSlowQueries`
- **Integration tests:**
  - `testSearch1000ItemsUnder150ms`
- **Commit message:** `perf(search): add search performance tracing and budget tests`

### Step 28.3: Clipboard Polling Efficiency

- [ ] **Function:** Optimize `PasteboardMonitor` interval and wake on app activation.
- **Unit tests:**
  - `testPollingBackoffWhenPaused`
- **Integration tests:**
  - `testClipboardWatcherLowCPUOver30Seconds`
- **Commit message:** `perf(capture): optimize clipboard polling efficiency`

### Step 28.4: Save Success and Toast Feedback

- [ ] **Function:** `SaveToastView` — "Saved to Inbox" ripple/toast on successful capture.
- **Unit tests:**
  - `testToastShowsDrawerName`
- **Integration tests:**
  - `testSaveClipboardShowsToast`
- **Commit message:** `feat(ui): add save success toast feedback`

### Step 28.5: Orb Appearance Polish

- [ ] **Function:** Finalize hover, drop glow, error shake animations.
- **Unit tests:**
  - `testAnimationStatesExist`
- **Integration tests:**
  - `testOrbVisualPolishSnapshots`
- **Commit message:** `feat(ui): polish orb hover, drop, and error animations`

### Step 28.6: End-to-End Activation Flow Test

- [ ] **Function:** `ActivationFlowTests` — first save, first drawer, first retrieve scenarios.
- **Unit tests:**
  - n/a (integration-focused step)
- **Integration tests:**
  - `testFirstSaveFirstDrawerFirstRetrieveFlow`
  - `testQuickPasteReuseFlow`
  - `testScreenshotOCRSearchReuseFlow`
  - `testJobDescriptionFactExtractionFlow`
- **Commit message:** `test: add end-to-end activation and reuse flow tests`

---

## Phase Summary

| Phase | Name | Steps |
|-------|------|-------|
| 0 | Project Bootstrap | 4 |
| 1 | Domain Models | 6 |
| 2 | Storage Engine Foundation | 6 |
| 3 | Repository Layer | 5 |
| 4 | Blob Filesystem Storage | 4 |
| 5 | Floating Orb Window | 6 |
| 6 | Clipboard Service | 6 |
| 7 | Capture Classifier and Item Processor | 6 |
| 8 | Drawer UI Shell | 6 |
| 9 | Item Cards and Detail View | 6 |
| 10 | Link and Text Item Features | 6 |
| 11 | Screenshot Capture and OCR | 6 |
| 12 | File and Document Import | 6 |
| 13 | Drawer Management | 6 |
| 14 | Tags and Organization | 6 |
| 15 | Search Engine | 6 |
| 16 | Quick Paste Picker | 6 |
| 17 | Global Hotkeys and Keyboard UX | 6 |
| 18 | Drag-and-Drop Capture | 6 |
| 19 | Privacy and Sensitive Content | 6 |
| 20 | Permissions Manager | 6 |
| 21 | Settings | 6 |
| 22 | AI Processing Queue | 6 |
| 23 | AI Features | 6 |
| 24 | Semantic Search | 6 |
| 25 | Export and Import | 6 |
| 26 | Full Library Window | 6 |
| 27 | Reliability and Crash Recovery | 6 |
| 28 | Performance and Polish | 6 |
| **Total** | | **166 steps** |

---

## Suggested MVP Cut Line

For a first usable release, complete **Phases 0–16** plus **Steps 19.1–19.2**, **20.1–20.3**, and **21.1–21.3**. This delivers:

- Floating orb with clipboard save and pulse
- Drawer with inbox, item cards, and basic search
- Text, link, screenshot, and file capture
- Quick paste picker
- Core privacy warnings and permissions

Phases 17–28 layer keyboard polish, AI, semantic search, export, full library, reliability, and performance refinements.
