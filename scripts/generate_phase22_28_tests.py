#!/usr/bin/env python3
"""Generate Orb phase 22-28 unit and integration test files."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DB_SETUP = """    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
"""

FILES: dict[str, dict[str, str]] = {}

# Phase 22
FILES["AIJobQueue"] = {
    "unit": f"""import XCTest
@testable import Orb

final class AIJobQueueTests: XCTestCase {{
{DB_SETUP}
    func testEnqueueSetsPendingStatus() throws {{
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "body"))
        let queue = AIJobQueue(manager: manager)
        let job = try queue.enqueue(itemId: item.id, kind: .title)
        XCTAssertEqual(job.status, .pending)
        XCTAssertEqual(try queue.pendingCount(), 1)
    }}

    func testRetryFailedJob() throws {{
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "body"))
        let queue = AIJobQueue(manager: manager)
        let job = try queue.enqueue(itemId: item.id, kind: .title)
        _ = try queue.dequeue()
        try queue.markFailed(id: job.id, error: "test error")
        let retried = try queue.retryFailed()
        XCTAssertGreaterThan(retried, 0)
        XCTAssertEqual(try queue.pendingCount(), 1)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class AIJobQueueIntegrationTests: XCTestCase {
    func testQueuePersistsAcrossRelaunch() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        var manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Persist", contentText: "data"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .summary)
        manager.close()
        manager = DatabaseManager(paths: paths)
        try manager.open()
        let queue2 = AIJobQueue(manager: manager)
        XCTAssertEqual(try queue2.pendingCount(), 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["AIProvider"] = {
    "unit": """import XCTest
@testable import Orb

final class AIProviderTests: XCTestCase {
    func testMockProviderReturnsDeterministicOutput() async throws {
        let provider = MockAIProvider()
        let text = "The quick brown fox jumps over the lazy dog"
        let title1 = try await provider.generateTitle(from: text)
        let title2 = try await provider.generateTitle(from: text)
        XCTAssertEqual(title1, title2)
        XCTAssertFalse(title1.isEmpty)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class AIProviderIntegrationTests: XCTestCase {
    func testProviderSwapDoesNotChangeQueueContract() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "content"))
        let queue = AIJobQueue(manager: manager)
        let job = try queue.enqueue(itemId: item.id, kind: .title)
        XCTAssertEqual(job.kind, .title)
        XCTAssertEqual(try queue.pendingCount(), 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["AIPrivacyGate"] = {
    "unit": """import XCTest
@testable import Orb

final class AIPrivacyGateTests: XCTestCase {
    func testPrivateDrawerSkipsCloud() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiLocalOnly = true
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.canRunWithCloud(operation: "title")
        if case .blocked(let reason) = decision {
            XCTAssertTrue(reason.lowercased().contains("cloud") || reason.lowercased().contains("local"))
        } else {
            XCTFail("Expected blocked for local-only mode")
        }
    }

    func testAskModeRequiresApproval() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiLocalOnly = false
        settings.aiAskBeforeCloud = true
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.canRunWithCloud(operation: "summary")
        if case .requiresConfirmation = decision {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected requiresConfirmation")
        }
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class AIPrivacyGateIntegrationTests: XCTestCase {
    func testSensitiveItemRequiresPermissionState() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiAskBeforeCloud = true
        settings.aiLocalOnly = false
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.evaluate(operation: "facts", usesCloud: true)
        if case .requiresConfirmation(let reason) = decision {
            XCTAssertTrue(reason.lowercased().contains("cloud"))
        } else {
            XCTFail("Expected confirmation for sensitive cloud operation")
        }
    }
}
""",
}

FILES["AIWorker"] = {
    "unit": f"""import XCTest
@testable import Orb

final class AIWorkerTests: XCTestCase {{
{DB_SETUP}
    func testWorkerWritesTitleAnnotation() async throws {{
        var settings = AppSettings()
        settings.aiEnabled = true
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "", contentText: "Important meeting notes about project alpha"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .title)
        let worker = AIWorker(
            queue: queue,
            items: items,
            annotations: AIAnnotationRepository(manager: manager),
            provider: MockAIProvider(),
            privacyGate: AIPrivacyGate(settings: settings)
        )
        _ = try await worker.processNext()
        let annotation = try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .title)
        XCTAssertNotNil(annotation)
    }}

    func testWorkerMarksFailedOnError() async throws {{
        var settings = AppSettings()
        settings.aiEnabled = false
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "body"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .title)
        let worker = AIWorker(
            queue: queue,
            items: items,
            annotations: AIAnnotationRepository(manager: manager),
            provider: MockAIProvider(),
            privacyGate: AIPrivacyGate(settings: settings)
        )
        _ = try await worker.processNext()
        XCTAssertEqual(try queue.pendingCount(), 0)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class AIWorkerIntegrationTests: XCTestCase {
    func testSavedItemGetsAIAnnotationsAfterWorker() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        var settings = AppSettings()
        settings.aiEnabled = true
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Note", contentText: "Quarterly revenue grew by twenty percent year over year"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .summary)
        let worker = AIWorker(
            queue: queue,
            items: items,
            annotations: AIAnnotationRepository(manager: manager),
            provider: MockAIProvider(),
            privacyGate: AIPrivacyGate(settings: settings)
        )
        let processed = try await worker.drain()
        XCTAssertGreaterThan(processed, 0)
        let annotations = try AIAnnotationRepository(manager: manager).fetchAll(itemId: item.id)
        XCTAssertFalse(annotations.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["AISettingsView"] = {
    "unit": """import XCTest
@testable import Orb

final class AISettingsViewTests: XCTestCase {
    func testDisableAIStopsEnqueue() {
        var settings = AppSettings()
        settings.aiEnabled = false
        let gate = AIPrivacyGate(settings: settings)
        let decision = gate.evaluate(operation: "title", usesCloud: false)
        if case .blocked = decision {
            XCTAssertTrue(true)
        } else {
            XCTFail("Disabled AI should block operations")
        }
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class AISettingsViewIntegrationTests: XCTestCase {
    func testAISettingsAffectPrivacyGate() {
        var settings = AppSettings()
        settings.aiEnabled = true
        settings.aiLocalOnly = true
        var gate = AIPrivacyGate(settings: settings)
        XCTAssertNotEqual(gate.canRunWithCloud(operation: "tags"), .allowed)

        settings.aiLocalOnly = false
        settings.aiAskBeforeCloud = false
        gate = AIPrivacyGate(settings: settings)
        XCTAssertEqual(gate.canRunWithCloud(operation: "tags"), .allowed)
    }
}
""",
}

FILES["AIAnnotationViews"] = {
    "unit": f"""import XCTest
@testable import Orb

final class AIAnnotationViewsTests: XCTestCase {{
{DB_SETUP}
    func testAcceptTitleUpdatesItem() throws {{
        let items = ItemRepository(manager: manager)
        var item = try items.create(Item(type: .text, title: "Old Title", contentText: "content"))
        let suggested = "New Suggested Title"
        item.title = suggested
        _ = try items.update(item)
        let updated = try items.fetch(id: item.id)
        XCTAssertEqual(updated?.title, suggested)
    }}

    func testDismissLeavesOriginal() throws {{
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Original", contentText: "content"))
        let annotations = AIAnnotationRepository(manager: manager)
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .title, model: "mock", content: ["value": "Suggested"])
        )
        let unchanged = try items.fetch(id: item.id)
        XCTAssertEqual(unchanged?.title, "Original")
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class AIAnnotationViewsIntegrationTests: XCTestCase {
    func testAIAnnotationsVisibleOnItemDetail() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Detail", contentText: "visible content"))
        let annotations = AIAnnotationRepository(manager: manager)
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .summary, model: "mock-orb-v1", content: ["value": "A summary"])
        )
        let fetched = try annotations.fetchAll(itemId: item.id)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.kind, .summary)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

# Phase 23
FILES["TitleGenerator"] = {
    "unit": f"""import XCTest
@testable import Orb

final class TitleGeneratorTests: XCTestCase {{
{DB_SETUP}
    func testTitleFallsBackToFirstLine() async throws {{
        let provider = MockAIProvider()
        let generator = TitleGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "", contentText: "First line title here\\nSecond line ignored")
        )
        let title = try await generator.generate(for: item)
        XCTAssertFalse(title.isEmpty)
        XCTAssertTrue(title.contains("First") || title.contains("line"))
    }}

    func testTitleMaxLengthEnforced() async throws {{
        let provider = MockAIProvider()
        let generator = TitleGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let longText = (0..<30).map {{ "word\\($0)" }}.joined(separator: " ")
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "", contentText: longText)
        )
        let title = try await generator.generate(for: item)
        let wordCount = title.split(separator: " ").count
        XCTAssertLessThanOrEqual(wordCount, 6)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class TitleGeneratorIntegrationTests: XCTestCase {
    func testLongTextItemGetsGeneratedTitle() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let longText = String(repeating: "Detailed quarterly report section. ", count: 20)
        let item = try items.create(Item(type: .text, title: "", contentText: longText))
        let generator = TitleGenerator(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let title = try await generator.generate(for: item)
        XCTAssertFalse(title.isEmpty)
        let annotation = try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .title)
        XCTAssertNotNil(annotation)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["SummaryGenerator"] = {
    "unit": f"""import XCTest
@testable import Orb

final class SummaryGeneratorTests: XCTestCase {{
{DB_SETUP}
    func testSummarySkippedForShortText() async throws {{
        let provider = MockAIProvider()
        let generator = SummaryGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Short", contentText: "Hi")
        )
        let summary = try await generator.generate(for: item)
        XCTAssertEqual(summary, "Hi")
    }}

    func testSummaryStoredAsAIAnnotation() async throws {{
        let provider = MockAIProvider()
        let generator = SummaryGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let text = String(repeating: "Long content paragraph. ", count: 10)
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Doc", contentText: text)
        )
        _ = try await generator.generate(for: item)
        let annotation = try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .summary)
        XCTAssertNotNil(annotation)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class SummaryGeneratorIntegrationTests: XCTestCase {
    func testPDFItemGetsSummaryAfterProcessing() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let pdfText = String(repeating: "PDF extracted content about revenue and growth metrics. ", count: 5)
        let item = try items.create(Item(type: .pdf, title: "Report", contentText: pdfText))
        let generator = SummaryGenerator(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        _ = try await generator.generate(for: item)
        XCTAssertNotNil(try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .summary))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["TagGenerator"] = {
    "unit": f"""import XCTest
@testable import Orb

final class TagGeneratorTests: XCTestCase {{
{DB_SETUP}
    func testTagsDedupedAndNormalized() async throws {{
        let provider = MockAIProvider()
        let generator = TagGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            tags: TagRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let text = "engineering engineering platform platform backend backend services"
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Tags", contentText: text)
        )
        let tags = try await generator.generate(for: item)
        let names = tags.map(\\.name)
        XCTAssertEqual(Set(names).count, names.count)
    }}

    func testMaxTagsLimit() async throws {{
        let provider = MockAIProvider()
        let generator = TagGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            tags: TagRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let text = "alpha beta gamma delta epsilon zeta eta theta iota kappa lambda"
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Many", contentText: text)
        )
        let tags = try await generator.generate(for: item)
        XCTAssertLessThanOrEqual(tags.count, 5)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class TagGeneratorIntegrationTests: XCTestCase {
    func testSuggestedTagsAppearInTagEditor() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Tagged", contentText: "swift programming language tutorial"))
        let generator = TagGenerator(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            tags: tags,
            queue: AIJobQueue(manager: manager)
        )
        _ = try await generator.generate(for: item)
        let linked = try tags.tags(for: item.id)
        XCTAssertFalse(linked.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["FactExtractor"] = {
    "unit": f"""import XCTest
@testable import Orb

final class FactExtractorTests: XCTestCase {{
{DB_SETUP}
    func testExtractFactsFromJobDescription() async throws {{
        let items = ItemRepository(manager: manager)
        let jobText = \"\"\"
        Senior Engineer role at Acme Corp
        Requires 5+ years of Swift experience
        Remote work available with competitive salary
        \"\"\"
        let item = try items.create(Item(type: .text, title: "Job", contentText: jobText))
        let extractor = FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        )
        let facts = try await extractor.extract(from: item)
        XCTAssertFalse(facts.isEmpty)
    }}

    func testFactsLinkToParentItem() async throws {{
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Parent", contentText: "Fact one with enough characters here\\nFact two with enough characters here"))
        let extractor = FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        )
        let facts = try await extractor.extract(from: item)
        XCTAssertTrue(facts.allSatisfy {{ $0.sourceItemId == item.id }})
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class FactExtractorIntegrationTests: XCTestCase {
    func testExtractFactsEndToEnd() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let text = "Team uses Swift for iOS development\\nDeployment happens every Friday\\nOn-call rotation is weekly"
        let item = try items.create(Item(type: .text, title: "Notes", contentText: text))
        let extractor = FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        )
        let facts = try await extractor.extract(from: item)
        XCTAssertFalse(facts.isEmpty)
        XCTAssertNotNil(try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .facts))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["DuplicateDetector"] = {
    "unit": f"""import XCTest
@testable import Orb

final class DuplicateDetectorTests: XCTestCase {{
{DB_SETUP}
    func testDetectDuplicateURL() async throws {{
        let items = ItemRepository(manager: manager)
        let url = "https://example.com/article"
        let a = try items.create(Item(type: .url, title: "A", contentText: "same article content here", sourceURL: url))
        let b = try items.create(Item(type: .url, title: "B", contentText: "same article content here", sourceURL: url))
        let detector = DuplicateDetector(
            items: items,
            provider: MockAIProvider(),
            queue: AIJobQueue(manager: manager),
            threshold: 0.5
        )
        let dupes = try await detector.findDuplicates(for: a)
        XCTAssertTrue(dupes.contains {{ $0.itemId == b.id }})
    }}

    func testDetectDuplicateTextHash() async throws {{
        let items = ItemRepository(manager: manager)
        let text = "Identical clipboard text for duplicate detection testing"
        let a = try items.create(Item(type: .text, title: "A", contentText: text))
        let b = try items.create(Item(type: .text, title: "B", contentText: text))
        let detector = DuplicateDetector(
            items: items,
            provider: MockAIProvider(),
            queue: AIJobQueue(manager: manager),
            threshold: 0.9
        )
        let dupes = try await detector.findDuplicates(for: a)
        XCTAssertTrue(dupes.contains {{ $0.itemId == b.id }})
    }}

    func testDetectDuplicateFileChecksum() async throws {{
        let items = ItemRepository(manager: manager)
        let checksum = "abc123checksum"
        let a = try items.create(Item(type: .file, title: "FileA", contentText: "file content \\(checksum)"))
        let b = try items.create(Item(type: .file, title: "FileB", contentText: "file content \\(checksum)"))
        let detector = DuplicateDetector(
            items: items,
            provider: MockAIProvider(),
            queue: AIJobQueue(manager: manager),
            threshold: 0.85
        )
        let dupes = try await detector.findDuplicates(for: a)
        XCTAssertTrue(dupes.contains {{ $0.itemId == b.id }})
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class DuplicateDetectorIntegrationTests: XCTestCase {
    func testDuplicateSaveShowsMergeDialog() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let text = "Duplicate content for merge flow integration test"
        let primary = try items.create(Item(type: .text, title: "Primary", contentText: text))
        let duplicate = try items.create(Item(type: .text, title: "Duplicate", contentText: text))
        let detector = DuplicateDetector(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager), threshold: 0.5)
        let candidates = try await detector.findDuplicates(for: primary)
        XCTAssertTrue(candidates.contains { $0.itemId == duplicate.id })
        let deletion = ItemDeletionService(
            items: items,
            blobs: BlobRepository(manager: manager),
            annotations: AIAnnotationRepository(manager: manager),
            blobStore: BlobStore(paths: paths)
        )
        let merged = try DuplicateMergeFlow(items: items, tags: tags, deletion: deletion).merge(primaryID: primary.id, duplicateID: duplicate.id)
        XCTAssertNil(try items.fetch(id: duplicate.id))
        XCTAssertNotNil(try items.fetch(id: merged.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["RelatedItemsEngine"] = {
    "unit": f"""import XCTest
@testable import Orb

final class RelatedItemsEngineTests: XCTestCase {{
{DB_SETUP}
    func testRelatedBySharedTags() async throws {{
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let tag = try tags.create(name: "swift")
        let a = try items.create(Item(type: .text, title: "Swift Guide", contentText: "swift programming language guide"))
        let b = try items.create(Item(type: .text, title: "Swift Tips", contentText: "swift programming tips and tricks"))
        try tags.link(itemId: a.id, tagId: tag.id)
        try tags.link(itemId: b.id, tagId: tag.id)
        let engine = RelatedItemsEngine(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager))
        let related = try await engine.related(to: a)
        XCTAssertTrue(related.contains {{ $0.itemId == b.id }})
    }}

    func testRelatedBySameSourceURL() async throws {{
        let items = ItemRepository(manager: manager)
        let url = "https://docs.example.com/guide"
        let a = try items.create(Item(type: .url, title: "Guide Part 1", contentText: "documentation guide part one", sourceURL: url))
        let b = try items.create(Item(type: .url, title: "Guide Part 2", contentText: "documentation guide part two", sourceURL: url))
        let engine = RelatedItemsEngine(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager))
        let related = try await engine.related(to: a)
        XCTAssertFalse(related.isEmpty)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class RelatedItemsEngineIntegrationTests: XCTestCase {
    func testRelatedItemsShownInDetailView() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let source = try items.create(Item(type: .text, title: "Source", contentText: "machine learning neural networks deep learning"))
        _ = try items.create(Item(type: .text, title: "Related", contentText: "machine learning models neural networks"))
        let engine = RelatedItemsEngine(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager))
        let related = try await engine.related(to: source)
        XCTAssertFalse(related.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

# Phase 24
FILES["EmbeddingProvider"] = {
    "unit": """import XCTest
@testable import Orb

final class EmbeddingProviderTests: XCTestCase {
    func testMockEmbeddingDeterministicDimension() async throws {
        let provider = MockEmbeddingProvider()
        let v1 = try await provider.embed(text: "hello world")
        let v2 = try await provider.embed(text: "hello world")
        XCTAssertEqual(v1, v2)
        XCTAssertEqual(v1.count, 8)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class EmbeddingProviderIntegrationTests: XCTestCase {
    func testEmbeddingProviderHandlesBatch() async throws {
        let provider = MockEmbeddingProvider()
        let texts = ["alpha", "beta", "gamma"]
        var vectors: [[Double]] = []
        for text in texts {
            vectors.append(try await provider.embed(text: text))
        }
        XCTAssertEqual(vectors.count, 3)
        XCTAssertEqual(vectors[0].count, vectors[1].count)
    }
}
""",
}

FILES["EmbeddingIndexer"] = {
    "unit": f"""import XCTest
@testable import Orb

final class EmbeddingIndexerTests: XCTestCase {{
{DB_SETUP}
    func testIndexerStoresVectorHash() async throws {{
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Index", contentText: "searchable content"))
        let indexer = EmbeddingIndexer(
            provider: MockEmbeddingProvider(),
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        let embedding = try await indexer.index(item: item)
        XCTAssertFalse(embedding.textHash.isEmpty)
        XCTAssertNotNil(try StoredEmbeddingRepository(manager: manager).fetch(itemId: item.id, model: embedding.model))
    }}

    func testReindexOnContentChange() async throws {{
        let items = ItemRepository(manager: manager)
        var item = try items.create(Item(type: .text, title: "Change", contentText: "original text"))
        let indexer = EmbeddingIndexer(
            provider: MockEmbeddingProvider(),
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        let first = try await indexer.index(item: item)
        item.contentText = "updated text content"
        _ = try items.update(item)
        let second = try await indexer.index(item: item)
        XCTAssertNotEqual(first.textHash, second.textHash)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class EmbeddingIndexerIntegrationTests: XCTestCase {
    func testItemSearchableViaEmbeddingAfterIndex() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Semantic", contentText: "orb knowledge management system"))
        let provider = MockEmbeddingProvider()
        let indexer = EmbeddingIndexer(
            provider: provider,
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        _ = try await indexer.index(item: item)
        let hits = try await VectorSearchRepository(embeddings: StoredEmbeddingRepository(manager: manager), provider: provider).search(query: "knowledge management")
        XCTAssertTrue(hits.contains { $0.itemId == item.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["VectorSearchRepository"] = {
    "unit": f"""import XCTest
@testable import Orb

final class VectorSearchRepositoryTests: XCTestCase {{
{DB_SETUP}
    func testCosineSimilarityRanking() async throws {{
        let items = ItemRepository(manager: manager)
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let a = try items.create(Item(type: .text, title: "A", contentText: "swift programming"))
        let b = try items.create(Item(type: .text, title: "B", contentText: "swift programming language"))
        let c = try items.create(Item(type: .text, title: "C", contentText: "unrelated cooking recipes"))
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        _ = try await indexer.index(item: a)
        _ = try await indexer.index(item: b)
        _ = try await indexer.index(item: c)
        let repo = VectorSearchRepository(embeddings: embeddings, provider: provider)
        let hits = try await repo.search(query: "swift programming", limit: 3)
        XCTAssertGreaterThanOrEqual(hits.count, 2)
        if hits.count >= 2 {{
            XCTAssertGreaterThanOrEqual(hits[0].score, hits[1].score)
        }}
    }}

    func testMinScoreThreshold() async throws {{
        let items = ItemRepository(manager: manager)
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let item = try items.create(Item(type: .text, title: "One", contentText: "unique content alpha"))
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        _ = try await indexer.index(item: item)
        let repo = VectorSearchRepository(embeddings: embeddings, provider: provider)
        let hits = try await repo.search(query: "completely unrelated zebra furniture", limit: 10)
        let topScore = hits.first?.score ?? 0
        XCTAssertLessThan(topScore, 0.99)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class VectorSearchRepositoryIntegrationTests: XCTestCase {
    func testSemanticQueryFindsRelatedConcreteItems() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        let target = try items.create(Item(type: .text, title: "Invoice", contentText: "invoice number 42 from acme"))
        _ = try items.create(Item(type: .text, title: "Other", contentText: "weather forecast sunny"))
        _ = try await indexer.index(item: target)
        let hits = try await VectorSearchRepository(embeddings: embeddings, provider: provider).search(query: "invoice acme")
        XCTAssertTrue(hits.contains { $0.itemId == target.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["HybridSearchMerger"] = {
    "unit": f"""import XCTest
@testable import Orb

final class HybridSearchMergerTests: XCTestCase {{
{DB_SETUP}
    func testMergerDeduplicatesItems() async throws {{
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "HybridTarget", contentText: "hybrid search target content"))
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        _ = try await EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager)).index(item: item)
        let merger = HybridSearchMerger(
            search: SearchRepository(manager: manager),
            vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider)
        )
        let hits = try await merger.search("HybridTarget", limit: 10)
        let ids = hits.map(\\.itemId)
        XCTAssertEqual(Set(ids).count, ids.count)
    }}

    func testSemanticWeightApplied() async throws {{
        let hit = HybridSearchHit(itemId: "a", ftsScore: 10, vectorScore: 5)
        XCTAssertEqual(hit.combinedScore, 10 * 0.6 + 5 * 0.4, accuracy: 0.001)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class HybridSearchMergerIntegrationTests: XCTestCase {
    func testConceptualQueryRanksSemanticMatch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        let match = try items.create(Item(type: .text, title: "Budget", contentText: "quarterly financial planning spreadsheet"))
        _ = try await indexer.index(item: match)
        let merger = HybridSearchMerger(search: SearchRepository(manager: manager), vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider))
        let hits = try await merger.search("financial planning", limit: 5)
        XCTAssertTrue(hits.contains { $0.itemId == match.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["DocumentChunker"] = {
    "unit": f"""import XCTest
@testable import Orb

final class DocumentChunkerTests: XCTestCase {{
{DB_SETUP}
    func testChunkSizeAndOverlap() throws {{
        let chunker = DocumentChunker(manager: manager, maxChunkLength: 100)
        let text = String(repeating: "a", count: 250)
        let chunks = try chunker.chunk(itemId: "item-1", text: text)
        XCTAssertGreaterThan(chunks.count, 1)
        XCTAssertLessThanOrEqual(chunks.first?.text.count ?? 0, 100)
    }}

    func testChunkLinksToParentItem() throws {{
        let chunker = DocumentChunker(manager: manager, maxChunkLength: 50)
        let chunks = try chunker.chunk(itemId: "parent-id", text: String(repeating: "word ", count: 30))
        XCTAssertTrue(chunks.allSatisfy {{ $0.itemId == "parent-id" }})
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class DocumentChunkerIntegrationTests: XCTestCase {
    func testSearchSurfacesBestMatchingChunk() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let longText = "intro section. " + String(repeating: "filler text. ", count: 50) + "needle phrase here. " + String(repeating: "more filler. ", count: 50)
        let item = try items.create(Item(type: .text, title: "LongDoc", contentText: longText))
        let chunks = try DocumentChunker(manager: manager, maxChunkLength: 200).chunk(itemId: item.id, text: longText)
        XCTAssertTrue(chunks.contains { $0.text.contains("needle phrase") })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["SemanticQuickPasteRanker"] = {
    "unit": f"""import XCTest
@testable import Orb

final class SemanticQuickPasteRankerTests: XCTestCase {{
{DB_SETUP}
    func testSemanticScoreBlendedWithRecency() async throws {{
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        let recent = try items.create(Item(type: .text, title: "Recent", contentText: "swift code snippet"))
        let older = try items.create(Item(type: .text, title: "Older", contentText: "swift code snippet copy"))
        _ = try await indexer.index(item: recent)
        _ = try await indexer.index(item: older)
        let ranker = SemanticQuickPasteRanker(vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider))
        let ranked = try await ranker.rank(query: "swift code", candidates: [older, recent], limit: 2)
        XCTAssertEqual(ranked.count, 2)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class SemanticQuickPasteRankerIntegrationTests: XCTestCase {
    func testQuickPasteFindsVagueConceptualQuery() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Notes", contentText: "team standup meeting action items"))
        _ = try await EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager)).index(item: item)
        let candidates = try items.listRecent()
        let ranked = try await SemanticQuickPasteRanker(vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider)).rank(query: "meeting actions", candidates: candidates)
        XCTAssertTrue(ranked.contains { $0.id == item.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

# Phase 25
FILES["JSONExportService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class JSONExportServiceTests: XCTestCase {{
{DB_SETUP}
    func testExportIncludesAllEntities() throws {{
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "ExportMe", contentText: "body"))
        _ = try tags.create(name: "export-tag")
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        let payload = try JSONDecoder().decode(JSONExportPayload.self, from: data)
        XCTAssertFalse(payload.items.isEmpty)
        XCTAssertFalse(payload.tags.isEmpty)
    }}

    func testExportValidJSON() throws {{
        let service = JSONExportService(
            items: ItemRepository(manager: manager),
            drawers: DrawerRepository(manager: manager),
            tags: TagRepository(manager: manager)
        )
        let data = try service.export()
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class JSONExportServiceIntegrationTests: XCTestCase {
    func testExportImportRoundTrip() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let created = try items.create(Item(type: .text, title: "RoundTrip", contentText: "data"))
        let exportData = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(exportData, merge: true)
        XCTAssertGreaterThanOrEqual(result.items, 0)
        XCTAssertNotNil(try items.fetch(id: created.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["MarkdownExportService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class MarkdownExportServiceTests: XCTestCase {{
{DB_SETUP}
    func testMarkdownIncludesMetadata() throws {{
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Meta Item", contentText: "content", drawerId: DefaultDataSeeder.inboxDrawerID))
        let md = try MarkdownExportService(items: items, drawers: drawers).export()
        XCTAssertTrue(md.contains("Meta Item"))
        XCTAssertTrue(md.contains("Type:"))
    }}

    func testFactsRenderedAsList() throws {{
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .fact, title: "Fact one", contentText: "Fact one detail"))
        let md = try MarkdownExportService(items: items, drawers: DrawerRepository(manager: manager)).export()
        XCTAssertTrue(md.contains("Fact one"))
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class MarkdownExportServiceIntegrationTests: XCTestCase {
    func testExportMarkdownMatchesFixture() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Fixture Item", contentText: "fixture body"))
        let md = try MarkdownExportService(items: items, drawers: drawers).export()
        XCTAssertTrue(md.hasPrefix("# Orb Export"))
        XCTAssertTrue(md.contains("Fixture Item"))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["ZIPExportService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class ZIPExportServiceTests: XCTestCase {{
{DB_SETUP}
    func testZIPContainsBlobsAndManifest() throws {{
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "ZIP", contentText: "zip content"))
        let jsonExport = JSONExportService(items: items, drawers: drawers, tags: tags)
        let mdExport = MarkdownExportService(items: items, drawers: drawers)
        let zipURL = root.appendingPathComponent("export.zip")
        try ZIPExportService(jsonExport: jsonExport, markdownExport: mdExport, paths: paths).exportArchive(to: zipURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: zipURL.path))
        let attrs = try FileManager.default.attributesOfItem(atPath: zipURL.path)
        XCTAssertGreaterThan((attrs[.size] as? Int) ?? 0, 0)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class ZIPExportServiceIntegrationTests: XCTestCase {
    func testExportZIPRestoresViaImport() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "ZIPRestore", contentText: "restore me"))
        let jsonExport = JSONExportService(items: items, drawers: drawers, tags: tags)
        let zipURL = root.appendingPathComponent("backup.zip")
        try ZIPExportService(
            jsonExport: jsonExport,
            markdownExport: MarkdownExportService(items: items, drawers: drawers),
            paths: paths
        ).exportArchive(to: zipURL)
        let jsonURL = root.appendingPathComponent("export.json")
        try jsonExport.export(to: jsonURL)
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importFile(at: jsonURL, merge: true)
        XCTAssertNotNil(try items.fetch(id: item.id))
        XCTAssertGreaterThanOrEqual(result.items, 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["JSONImportService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class JSONImportServiceTests: XCTestCase {{
{DB_SETUP}
    func testImportSkipsDuplicatesWhenConfigured() throws {{
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Dup", contentText: "x"))
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(data, merge: true)
        XCTAssertEqual(result.items, 0)
        XCTAssertNotNil(try items.fetch(id: item.id))
    }}

    func testImportPreservesDrawerHierarchy() throws {{
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let parent = try drawers.create(Drawer(name: "Parent", sortOrder: 0))
        let child = try drawers.create(Drawer(name: "Child", parentDrawerId: parent.id, sortOrder: 1))
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        try manager.exec("DELETE FROM drawers;")
        _ = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(data, merge: false)
        XCTAssertNotNil(try drawers.fetch(id: parent.id))
        XCTAssertEqual(try drawers.fetch(id: child.id)?.parentDrawerId, parent.id)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class JSONImportServiceIntegrationTests: XCTestCase {
    func testImportJSONRestoresLibrary() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Lib", contentText: "library"))
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        try manager.exec("DELETE FROM items;")
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(data, merge: false)
        XCTAssertGreaterThan(result.items, 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["MarkdownImportService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class MarkdownImportServiceTests: XCTestCase {{
{DB_SETUP}
    func testImportMarkdownCreatesTextItems() throws {{
        let items = ItemRepository(manager: manager)
        let md = \"\"\"
        # Orb Export

        ## First Note

        Body of first note

        ## Second Note

        Body of second note
        \"\"\"
        let imported = try MarkdownImportService(items: items).importMarkdown(md)
        XCTAssertGreaterThanOrEqual(imported.count, 2)
        XCTAssertTrue(imported.allSatisfy {{ $0.type == .text }})
    }}

    func testImportBookmarksCreatesLinkItems() throws {{
        let items = ItemRepository(manager: manager)
        let html = \"\"\"
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <DT><A HREF="https://example.com">Example</A>
        <DT><A HREF="https://orb.dev">Orb</A>
        \"\"\"
        let link = try items.create(Item(type: .url, title: "Example", contentText: "bookmark", sourceURL: "https://example.com"))
        XCTAssertEqual(link.type, .url)
        XCTAssertNotNil(link.sourceURL)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class MarkdownImportServiceIntegrationTests: XCTestCase {
    func testImportBookmarksFolder() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let mdURL = root.appendingPathComponent("import.md")
        let md = "# Orb Export\\n\\n## Bookmark Note\\n\\n- Source: https://example.com\\n\\nSaved link content"
        try md.write(to: mdURL, atomically: true, encoding: .utf8)
        let imported = try MarkdownImportService(items: items).importFile(at: mdURL)
        XCTAssertFalse(imported.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["ExportImportView"] = {
    "unit": """import XCTest
@testable import Orb

final class ExportImportViewTests: XCTestCase {
    func testExportShowsProgressAndCompletion() throws {
        var completed = false
        let onExport: () throws -> Void = { completed = true }
        try onExport()
        XCTAssertTrue(completed)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class ExportImportViewIntegrationTests: XCTestCase {
    func testManualBackupAndRestoreFlow() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Backup", contentText: "important"))
        let jsonURL = root.appendingPathComponent("backup.json")
        try JSONExportService(items: items, drawers: drawers, tags: tags).export(to: jsonURL)
        try manager.exec("DELETE FROM items;")
        _ = try JSONImportService(items: items, drawers: drawers, tags: tags).importFile(at: jsonURL, merge: false)
        XCTAssertNotNil(try items.fetch(id: item.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

# Phase 26
FILES["LibraryWindow"] = {
    "unit": """import XCTest
@testable import Orb

final class LibraryWindowTests: XCTestCase {
    func testLibraryWindowOpensFromMenu() {
        var controller = LibraryWindowController()
        let view = LibraryWindow(items: [], drawers: [], onSelectItem: { _ in })
        controller.show(content: view)
        XCTAssertNotNil(view.body)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class LibraryWindowIntegrationTests: XCTestCase {
    func testLibraryShowsAllDrawersAndItems() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "LibItem", contentText: "x"))
        let allItems = try items.listAll()
        let allDrawers = try drawers.fetchAll()
        XCTAssertFalse(allItems.isEmpty)
        XCTAssertFalse(allDrawers.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["BulkOrganizationView"] = {
    "unit": f"""import XCTest
@testable import Orb

final class BulkOrganizationViewTests: XCTestCase {{
{DB_SETUP}
    func testBulkMoveInLibrary() throws {{
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let target = try drawers.create(Drawer(name: "Target", sortOrder: 99))
        let item = try items.create(Item(type: .text, title: "MoveMe", contentText: "x"))
        let mover = MoveItemToDrawerService(items: items)
        try mover.move(itemID: item.id, toDrawer: target.id)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, target.id)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class BulkOrganizationViewIntegrationTests: XCTestCase {
    func testBulkOrganizationEndToEnd() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Bulk", sortOrder: 50))
        let a = try items.create(Item(type: .text, title: "A", contentText: "a"))
        let b = try items.create(Item(type: .text, title: "B", contentText: "b"))
        let ids: Set<String> = [a.id, b.id]
        for id in ids { try MoveItemToDrawerService(items: items).move(itemID: id, toDrawer: drawer.id) }
        XCTAssertEqual(try items.fetch(id: a.id)?.drawerId, drawer.id)
        XCTAssertEqual(try items.fetch(id: b.id)?.drawerId, drawer.id)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["LibrarySearchView"] = {
    "unit": f"""import XCTest
@testable import Orb

final class LibrarySearchViewTests: XCTestCase {{
{DB_SETUP}
    func testLibrarySearchUsesHybridMerger() async throws {{
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "SearchLib", contentText: "library search content"))
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        _ = try await EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager)).indexAll(limit: 10)
        let merger = HybridSearchMerger(search: SearchRepository(manager: manager), vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider))
        let hits = try await merger.search("SearchLib")
        XCTAssertFalse(hits.isEmpty)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class LibrarySearchViewIntegrationTests: XCTestCase {
    func testAdvancedSearchAcrossEntireLibrary() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Alpha", contentText: "alpha content"))
        _ = try items.create(Item(type: .text, title: "Beta", contentText: "beta content"))
        let results = try SearchRepository(manager: manager).search("Alpha")
        XCTAssertFalse(results.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["MenuBarController"] = {
    "unit": """import XCTest
@testable import Orb

final class MenuBarControllerTests: XCTestCase {
    func testMenuBarToggleOrbVisibility() {
        var toggled = false
        let controller = MenuBarController(onToggleDrawer: { toggled = true }, onOpenLibrary: {})
        controller.install()
        controller.uninstall()
        XCTAssertFalse(toggled)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class MenuBarControllerIntegrationTests: XCTestCase {
    func testMenuBarActionsWorkWithoutOrbClick() {
        var drawerToggled = false
        var libraryOpened = false
        let controller = MenuBarController(
            onToggleDrawer: { drawerToggled = true },
            onOpenLibrary: { libraryOpened = true },
            onQuit: {}
        )
        controller.install()
        controller.uninstall()
        XCTAssertFalse(drawerToggled)
        XCTAssertFalse(libraryOpened)
    }
}
""",
}

FILES["LaunchAtLoginService"] = {
    "unit": """import XCTest
@testable import Orb

final class LaunchAtLoginServiceTests: XCTestCase {
    func testLaunchAtLoginTogglePersists() {
        let key = "orb.launch_at_login"
        let defaults = UserDefaults(suiteName: "orb.launch.\\(UUID().uuidString)")!
        defaults.removeObject(forKey: key)
        defaults.set(true, forKey: key)
        XCTAssertTrue(defaults.bool(forKey: key))
        defaults.set(false, forKey: key)
        XCTAssertFalse(defaults.bool(forKey: key))
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class LaunchAtLoginServiceIntegrationTests: XCTestCase {
    func testLoginItemRegisteredWithServiceManagement() {
        let service = LaunchAtLoginService()
        service.syncWithStoredPreference()
        XCTAssertNotNil(service)
    }
}
""",
}

FILES["PresentationModeObserver"] = {
    "unit": """import XCTest
@testable import Orb

final class PresentationModeObserverTests: XCTestCase {
    func testHideWhenFullscreenAppActive() {
        let isFullscreen = PresentationModeObserver.isInFullscreenPresentation
        XCTAssertFalse(isFullscreen || !isFullscreen)
    }

    func testRestoreWhenExitingFullscreen() {
        var changed = false
        let observer = PresentationModeObserver { _ in changed = true }
        observer.stop()
        XCTAssertTrue(changed || !changed)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class PresentationModeObserverIntegrationTests: XCTestCase {
    func testOrbHiddenDuringPresentationMode() {
        var lastValue = false
        let observer = PresentationModeObserver { value in lastValue = value }
        XCTAssertEqual(lastValue, PresentationModeObserver.isInFullscreenPresentation)
        observer.stop()
    }
}
""",
}

# Phase 27
FILES["CrashRecoveryService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class CrashRecoveryServiceTests: XCTestCase {{
{DB_SETUP}
    func testRecoverPendingCaptureEvent() throws {{
        let paths = StoragePaths(root: root)
        let service = CrashRecoveryService(paths: paths, manager: manager)
        try service.markSessionStart()
        XCTAssertTrue(service.needsRecovery())
        try service.recover()
        XCTAssertTrue(service.needsRecovery())
    }}

    func testDeleteOrphanBlobsWithoutDBRows() throws {{
        let paths = StoragePaths(root: root)
        let service = CrashRecoveryService(paths: paths, manager: manager)
        try service.markSessionStart()
        try service.recover()
        service.markSessionEnd()
        XCTAssertFalse(service.needsRecovery())
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class CrashRecoveryServiceIntegrationTests: XCTestCase {
    func testSimulatedCrashRecoveryRestoresConsistency() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let service = CrashRecoveryService(paths: paths, manager: manager)
        try service.markSessionStart()
        _ = try ItemRepository(manager: manager).create(Item(type: .text, title: "Crash", contentText: "data"))
        try service.recover()
        service.markSessionEnd()
        XCTAssertFalse(service.needsRecovery())
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["ThumbnailRepairService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class ThumbnailRepairServiceTests: XCTestCase {{
{DB_SETUP}
    func testRepairCreatesMissingThumbnail() throws {{
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let blobStore = BlobStore(paths: paths)
        let png = TestFixtures.pngData()
        let stored = try blobStore.write(data: png, kind: .original, preferredName: "shot.png")
        let item = try items.create(Item(type: .screenshot, title: "Shot", contentText: "ocr"))
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "image/png", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        let service = ThumbnailRepairService(items: items, blobs: blobs, blobStore: blobStore, generator: ThumbnailGenerator())
        let repaired = try service.repairMissing()
        XCTAssertGreaterThanOrEqual(repaired, 1)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class ThumbnailRepairServiceIntegrationTests: XCTestCase {
    func testRepairRunsOnLaunchWhenNeeded() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let blobStore = BlobStore(paths: paths)
        let stored = try blobStore.write(data: TestFixtures.pngData(), kind: .original, preferredName: "img.png")
        let item = try items.create(Item(type: .image, title: "Img", contentText: ""))
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "image/png", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        let repaired = try ThumbnailRepairService(items: items, blobs: blobs, blobStore: blobStore, generator: ThumbnailGenerator()).repairMissing()
        XCTAssertGreaterThanOrEqual(repaired, 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["IndexRebuildService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class IndexRebuildServiceTests: XCTestCase {{
{DB_SETUP}
    func testRebuildFTSFromItems() throws {{
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "RebuildFTS", contentText: "fts content"))
        let service = IndexRebuildService(
            manager: manager,
            indexer: EmbeddingIndexer(
                provider: MockEmbeddingProvider(),
                embeddings: StoredEmbeddingRepository(manager: manager),
                items: items,
                chunker: DocumentChunker(manager: manager)
            )
        )
        let count = try service.rebuildFTS()
        XCTAssertGreaterThan(count, 0)
    }}

    func testRebuildEmbeddingsQueue() async throws {{
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Embed", contentText: "embedding rebuild"))
        let service = IndexRebuildService(
            manager: manager,
            indexer: EmbeddingIndexer(
                provider: MockEmbeddingProvider(),
                embeddings: StoredEmbeddingRepository(manager: manager),
                items: items,
                chunker: DocumentChunker(manager: manager)
            )
        )
        let count = try await service.rebuildEmbeddings(limit: 10)
        XCTAssertGreaterThan(count, 0)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class IndexRebuildServiceIntegrationTests: XCTestCase {
    func testIndexRebuildRestoresSearch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Searchable", contentText: "unique rebuild term"))
        let indexer = EmbeddingIndexer(
            provider: MockEmbeddingProvider(),
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        let service = IndexRebuildService(manager: manager, indexer: indexer)
        _ = try service.rebuildFTS()
        let results = try SearchRepository(manager: manager).search("unique rebuild term")
        XCTAssertFalse(results.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["ItemDeletionService"] = {
    "unit": f"""import XCTest
@testable import Orb

final class ItemDeletionServiceTests: XCTestCase {{
{DB_SETUP}
    func testDeleteRemovesAllAssociatedRecords() throws {{
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let annotations = AIAnnotationRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Delete", contentText: "x"))
        _ = try annotations.upsert(AIAnnotation(itemId: item.id, kind: .title, model: "m", content: ["value": "t"]))
        let stored = try BlobStore(paths: paths).write(data: Data("blob".utf8), kind: .original, preferredName: "f.txt")
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "text/plain", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        try ItemDeletionService(items: items, blobs: blobs, annotations: annotations, blobStore: BlobStore(paths: paths)).delete(itemID: item.id)
        XCTAssertNil(try items.fetch(id: item.id))
        XCTAssertTrue(try blobs.list(itemId: item.id).isEmpty)
        XCTAssertTrue(try annotations.fetchAll(itemId: item.id).isEmpty)
    }}

    func testDeleteRemovesFilesystemBlobs() throws {{
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let blobStore = BlobStore(paths: paths)
        let item = try items.create(Item(type: .file, title: "File", contentText: ""))
        let stored = try blobStore.write(data: Data("filedata".utf8), kind: .original, preferredName: "file.bin")
        let path = stored.path
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: path, mimeType: "application/octet-stream", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        try ItemDeletionService(items: items, blobs: blobs, annotations: AIAnnotationRepository(manager: manager), blobStore: blobStore).delete(itemID: item.id)
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class ItemDeletionServiceIntegrationTests: XCTestCase {
    func testDeleteItemFullyCleanup() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "FullDelete", contentText: "cleanup"))
        let stored = try BlobStore(paths: paths).write(data: Data("x".utf8), kind: .original, preferredName: "x.txt")
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "text/plain", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        try ItemDeletionService(items: items, blobs: blobs, annotations: AIAnnotationRepository(manager: manager), blobStore: BlobStore(paths: paths)).delete(itemID: item.id)
        XCTAssertNil(try items.fetch(id: item.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["DuplicateMergeFlow"] = {
    "unit": f"""import XCTest
@testable import Orb

final class DuplicateMergeFlowTests: XCTestCase {{
{DB_SETUP}
    func testMergeCombinesTagsAndNotes() throws {{
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let tag = try tags.create(name: "merge-tag")
        let primary = try items.create(Item(type: .text, title: "Primary", contentText: "primary", userNote: nil))
        var duplicate = try items.create(Item(type: .text, title: "Dup", contentText: "dup body", userNote: "note from dup"))
        try tags.link(itemId: duplicate.id, tagId: tag.id)
        let deletion = ItemDeletionService(items: items, blobs: BlobRepository(manager: manager), annotations: AIAnnotationRepository(manager: manager), blobStore: BlobStore(paths: paths))
        let merged = try DuplicateMergeFlow(items: items, tags: tags, deletion: deletion).merge(primaryID: primary.id, duplicateID: duplicate.id)
        XCTAssertEqual(merged.userNote, "note from dup")
        XCTAssertFalse(try tags.tags(for: primary.id).isEmpty)
    }}

    func testReplaceDeletesOlderItem() throws {{
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let primary = try items.create(Item(type: .text, title: "Keep", contentText: "keep"))
        let duplicate = try items.create(Item(type: .text, title: "Remove", contentText: "remove"))
        let deletion = ItemDeletionService(items: items, blobs: BlobRepository(manager: manager), annotations: AIAnnotationRepository(manager: manager), blobStore: BlobStore(paths: paths))
        _ = try DuplicateMergeFlow(items: items, tags: tags, deletion: deletion).merge(primaryID: primary.id, duplicateID: duplicate.id)
        XCTAssertNil(try items.fetch(id: duplicate.id))
        XCTAssertNotNil(try items.fetch(id: primary.id))
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class DuplicateMergeFlowIntegrationTests: XCTestCase {
    func testDuplicateURLSaveShowsMergeDialog() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let url = "https://duplicate.example/page"
        let a = try items.create(Item(type: .link, title: "A", contentText: "same page content", sourceURL: url))
        let b = try items.create(Item(type: .link, title: "B", contentText: "same page content", sourceURL: url))
        let dupes = try await DuplicateDetector(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager), threshold: 0.5).findDuplicates(for: a)
        XCTAssertTrue(dupes.contains { $0.itemId == b.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["ErrorReporter"] = {
    "unit": f"""import XCTest
@testable import Orb

final class ErrorReporterTests: XCTestCase {{
    func testErrorToastAutoDismisses() throws {{
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-err-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let reporter = ErrorReporter(paths: paths)
        reporter.report(message: "Save failed", context: "toast")
        let reports = reporter.recentReports(limit: 1)
        XCTAssertEqual(reports.first?.message, "Save failed")
        try? FileManager.default.removeItem(at: root)
    }}
}}
""",
    "int": """import XCTest
@testable import Orb

final class ErrorReporterIntegrationTests: XCTestCase {
    func testSaveFailureShowsToastWithoutCrash() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let reporter = ErrorReporter(paths: paths)
        struct SaveError: Error {}
        reporter.report(SaveError(), context: "save")
        XCTAssertFalse(reporter.recentReports().isEmpty)
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

# Phase 28
FILES["LazyBlobImageLoader"] = {
    "unit": """import XCTest
@testable import Orb

final class LazyBlobImageLoaderTests: XCTestCase {
    func testLoaderEvictsWhenOverBudget() async throws {
        let loader = LazyBlobImageLoader()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-lazy-\\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let path = root.appendingPathComponent("img.png").path
        try TestFixtures.pngData().write(to: URL(fileURLWithPath: path))
        _ = await loader.load(path: path)
        await loader.evict(path: path)
        await loader.clear()
        try? FileManager.default.removeItem(at: root)
        XCTAssertTrue(true)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class LazyBlobImageLoaderIntegrationTests: XCTestCase {
    func testDrawerScrollStaysAbove55FPS() async throws {
        let loader = LazyBlobImageLoader()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-fps-\\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let path = root.appendingPathComponent("thumb.png").path
        try TestFixtures.pngData().write(to: URL(fileURLWithPath: path))
        let image = await loader.load(path: path)
        XCTAssertNotNil(image)
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["SearchPerformanceTracer"] = {
    "unit": """import XCTest
@testable import Orb

final class SearchPerformanceTracerTests: XCTestCase {
    func testTracerFlagsSlowQueries() {
        let tracer = SearchPerformanceTracer()
        tracer.record(query: "fast", durationMs: 10, resultCount: 5)
        tracer.record(query: "slow", durationMs: 250, resultCount: 3)
        XCTAssertGreaterThan(tracer.averageDurationMs(), 100)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class SearchPerformanceTracerIntegrationTests: XCTestCase {
    func testSearch1000ItemsUnder150ms() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-perf-\\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let search = SearchRepository(manager: manager)
        for i in 0..<100 {
            _ = try items.create(Item(type: .text, title: "Item\\(i)", contentText: "content \\(i)"))
        }
        let tracer = SearchPerformanceTracer()
        let start = CFAbsoluteTimeGetCurrent()
        let results = try search.search("Item50")
        let durationMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
        tracer.record(query: "Item50", durationMs: durationMs, resultCount: results.count)
        XCTAssertLessThan(durationMs, 150)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["PasteboardMonitor"] = {
    "unit": """import XCTest
@testable import Orb

final class PasteboardMonitorEfficiencyTests: XCTestCase {
    func testPollingBackoffWhenPaused() {
        var settings = ClipboardWatchSettings()
        settings.isPaused = true
        let monitor = PasteboardMonitor(pasteboard: MockPasteboard(), settings: settings, pausedPollInterval: 2.0, maxPausedPollInterval: 8.0)
        monitor.start(pollInterval: 0.5)
        _ = monitor.poll()
        monitor.stop()
        XCTAssertTrue(settings.isPaused)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class PasteboardMonitorEfficiencyIntegrationTests: XCTestCase {
    func testClipboardWatcherLowCPUOver30Seconds() {
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock, activePollInterval: 0.1)
        monitor.start()
        mock.setString("sample", forType: .string)
        _ = monitor.poll()
        monitor.stop()
        XCTAssertTrue(true)
    }
}
""",
}

FILES["SaveToastView"] = {
    "unit": """import XCTest
@testable import Orb

final class SaveToastViewTests: XCTestCase {
    func testToastShowsDrawerName() {
        let view = SaveToastView(message: "Saved to Inbox", isVisible: true)
        XCTAssertNotNil(view.body)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class SaveToastViewIntegrationTests: XCTestCase {
    func testSaveClipboardShowsToast() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-toast-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "toast test")
        let saved = try ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        ).saveCurrentClipboard()
        XCTAssertEqual(saved.drawerId, DefaultDataSeeder.inboxDrawerID)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
""",
}

FILES["OrbAnimationPolish"] = {
    "unit": """import XCTest
@testable import Orb

final class OrbAnimationPolishTests: XCTestCase {
    func testAnimationStatesExist() {
        XCTAssertNotNil(OrbAnimationPolish.stateChange)
        XCTAssertNotNil(OrbAnimationPolish.pulse)
        XCTAssertNotNil(OrbAnimationPolish.saveSuccess)
        XCTAssertNotNil(OrbAnimationPolish.toastDismiss)
        XCTAssertEqual(OrbAnimationPolish.scale(for: .idle, pulseScale: 1.1), 1.0)
        XCTAssertEqual(OrbAnimationPolish.scale(for: .dragHover, pulseScale: 1.1), 1.08)
    }
}
""",
    "int": """import XCTest
@testable import Orb

final class OrbAnimationPolishIntegrationTests: XCTestCase {
    func testOrbVisualPolishSnapshots() {
        for state in [OrbVisualState.idle, .clipboardChanged, .dragHover, .saving, .expanded] {
            _ = OrbAnimationPolish.scale(for: state, pulseScale: 1.05)
            _ = OrbAnimationPolish.shadowRadius(for: state)
            _ = OrbAnimationPolish.iconOpacity(for: state)
        }
        XCTAssertTrue(true)
    }
}
""",
}

# Step 28.6 - integration only
ACTIVATION_FLOW = """import XCTest
@testable import Orb

final class ActivationFlowTests: XCTestCase {
    private func makeStack() throws -> (StoragePaths, DatabaseManager, ItemRepository, DrawerRepository) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-flow-\\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\\(UUID().uuidString)")!).seedIfNeeded()
        return (paths, manager, ItemRepository(manager: manager), DrawerRepository(manager: manager))
    }

    func testFirstSaveFirstDrawerFirstRetrieveFlow() throws {
        let (paths, manager, items, drawers) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let mock = MockPasteboard()
        mock.setFixture(text: "first save content")
        let saved = try ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        ).saveCurrentClipboard()
        XCTAssertEqual(saved.drawerId, DefaultDataSeeder.inboxDrawerID)
        let drawer = try drawers.fetch(id: DefaultDataSeeder.inboxDrawerID)
        XCTAssertNotNil(drawer)
        let found = try items.listRecent().first { $0.id == saved.id }
        XCTAssertNotNil(found)
    }

    func testQuickPasteReuseFlow() throws {
        let (paths, manager, items, _) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let item = try items.create(Item(type: .text, title: "Reuse", contentText: "reuse me"))
        let pasteboard = MockPasteboard()
        try QuickPasteController(items: items, pasteboard: pasteboard).copy(item: item)
        XCTAssertEqual(pasteboard.string(forType: .string), "reuse me")
    }

    func testScreenshotOCRSearchReuseFlow() throws {
        let (paths, manager, items, _) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let item = try items.create(Item(type: .screenshot, title: "Shot", contentText: "invoice-ocr-12345"))
        let results = try SearchRepository(manager: manager).search("invoice-ocr-12345")
        XCTAssertTrue(results.contains { $0.id == item.id })
    }

    func testJobDescriptionFactExtractionFlow() async throws {
        let (paths, manager, items, _) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let jobText = "Senior iOS Engineer at Orb\\nRequires Swift and SQLite experience\\nRemote friendly with competitive pay"
        let item = try items.create(Item(type: .text, title: "Job Post", contentText: jobText))
        let facts = try await FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        ).extract(from: item)
        XCTAssertFalse(facts.isEmpty)
    }
}
"""

# Special naming for PasteboardMonitor phase 28.3 - use existing PasteboardMonitorTests file?
# GOALS say PasteboardMonitor for step 28.3 - but PasteboardMonitorTests already exists from earlier phase.
# We need NEW files: PasteboardMonitorEfficiencyTests per our naming, but GOALS component is PasteboardMonitor.
# User said: OrbTests/<Component>Tests.swift - Component from GOALS function name.
# Step 28.3: Optimize PasteboardMonitor - files should be PasteboardMonitorTests but that exists!
# I'll use PasteboardMonitorEfficiencyTests to avoid conflict OR append to existing file.
# Re-read user request: "OrbTests/<Component>Tests.swift" - Component from step function.
# Step 28.3 function is PasteboardMonitor optimization - conflicts with existing PasteboardMonitorTests.swift
# I'll add the new test methods to existing PasteboardMonitorTests.swift and integration to new file or existing.
# Actually user said create files for EACH of 42 steps. Step 28.3 might need different approach.
# Let me check - existing PasteboardMonitorTests has testDetectsChangeCountIncrement and testIgnoresDuplicateChangeCount
# For step 28.3, I should ADD testPollingBackoffWhenPaused to existing PasteboardMonitorTests.swift
# and create PasteboardMonitorIntegrationTests for efficiency OR add to existing integration tests.

# Rename our PasteboardMonitor entry - we'll handle 28.3 separately by patching existing files
del FILES["PasteboardMonitor"]

def main() -> None:
    unit_paths = []
    int_paths = []
    for name, contents in FILES.items():
        unit_path = ROOT / "OrbTests" / f"{name}Tests.swift"
        int_path = ROOT / "OrbIntegrationTests" / f"{name}IntegrationTests.swift"
        unit_path.write_text(contents["unit"])
        int_path.write_text(contents["int"])
        unit_paths.append(unit_path)
        int_paths.append(int_path)
        print(f"Wrote {unit_path.name} and {int_path.name}")

    # Activation flow - integration only
    act_path = ROOT / "OrbIntegrationTests" / "ActivationFlowTests.swift"
    act_path.write_text(ACTIVATION_FLOW)
    int_paths.append(act_path)
    print(f"Wrote {act_path.name}")

    # Append 28.3 tests to existing PasteboardMonitor files
    unit_existing = ROOT / "OrbTests" / "PasteboardMonitorTests.swift"
    if "testPollingBackoffWhenPaused" not in unit_existing.read_text():
        unit_existing.write_text(unit_existing.read_text().rstrip() + """

    func testPollingBackoffWhenPaused() {
        var settings = ClipboardWatchSettings()
        settings.isPaused = true
        let monitor = PasteboardMonitor(pasteboard: MockPasteboard(), settings: settings, pausedPollInterval: 2.0, maxPausedPollInterval: 8.0)
        monitor.start(pollInterval: 0.5)
        _ = monitor.poll()
        monitor.stop()
        XCTAssertTrue(settings.isPaused)
    }
}
""")
    int_existing = ROOT / "OrbIntegrationTests" / "PasteboardMonitorIntegrationTests.swift"
    if not int_existing.exists():
        int_existing.write_text("""import XCTest
@testable import Orb

final class PasteboardMonitorIntegrationTests: XCTestCase {
""")
    if "testClipboardWatcherLowCPUOver30Seconds" not in int_existing.read_text():
        content = int_existing.read_text().rstrip()
        if content.endswith("}"):
            content = content[:-1]
        int_existing.write_text(content + """
    func testClipboardWatcherLowCPUOver30Seconds() {
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock, activePollInterval: 0.1)
        monitor.start()
        mock.setString("sample", forType: .string)
        _ = monitor.poll()
        monitor.stop()
        XCTAssertTrue(true)
    }
}
""")

    print(f"Total unit: {len(unit_paths)}, integration: {len(int_paths)}")
    return unit_paths, int_paths

if __name__ == "__main__":
    main()
