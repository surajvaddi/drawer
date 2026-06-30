# Product Spec: Floating Orb Clipboard Vault for macOS

## 1. Product Name

Working name: **Orb**

Other possible names:

- ClipOrb
- Orbit
- Docklet
- Pocket
- Capsule
- Shelf
- Nucleus
- Recall

## 2. One-Line Description

A floating, persistent macOS orb that lets users instantly save, organize, search, preview, copy, and reuse important links, facts, documents, screenshots, and clipboard content from anywhere on their computer.

## 3. Product Thesis

Modern workflows create a constant stream of useful fragments: copied links, research quotes, screenshots, PDFs, code snippets, job posts, names, facts, API docs, emails, and notes. These fragments are usually too small for a full notes app but too important to lose in clipboard history.

Orb solves this by acting as a spatial clipboard vault: a small floating object that is always available, captures important material intentionally, and expands into a drawer-based memory interface.

The product should feel less like "taking notes" and more like throwing something into a persistent pocket.

## 4. Target User

Primary users:

- Researchers
- Students
- Engineers
- Founders
- Job seekers
- Consultants
- Writers
- Designers
- Analysts
- Anyone who constantly collects small pieces of information across apps

The core user has many browser tabs, PDFs, screenshots, copied facts, links, and documents spread across their desktop. They need fast capture and fast retrieval without opening a heavy workspace.

## 5. Core User Problem

Users frequently encounter information they know will matter later, but saving it properly creates friction.

Current options are flawed:

- Clipboard history is temporary and unorganized.
- Notes apps are too heavy for quick fragments.
- Bookmarks only handle links.
- Finder handles files but not thoughts/snippets.
- Screenshots get lost on the desktop.
- Documents are disconnected from extracted facts.
- AI chat histories are not structured enough for reusable recall.
- Search requires remembering where something was saved.

Orb provides a persistent, local-first, structured capture layer.

## 6. Product Principles

### 6.1 Capture must be lighter than note-taking

The user should be able to save something in less than one second.

Core capture actions:

- Copy something, then save current clipboard.
- Drag something onto the orb.
- Screenshot something into the orb.
- Highlight text and send it to the orb.
- Drop files, PDFs, or links into the orb.
- Use a global hotkey to save the current clipboard.

### 6.2 Retrieval must be faster than searching browser history

The drawer should let users find saved content by:

- Recent items
- Drawer/folder
- Source app
- Type
- Tags
- Exact text
- Semantic meaning
- Screenshot OCR
- Document text
- Link title
- User-created notes

### 6.3 The orb should be persistent but not annoying

It should be visible, draggable, small, and useful. It should never feel like malware, spyware, or visual clutter.

### 6.4 Organization should happen after capture, not before

The user should not have to decide where something goes before saving it. The app can suggest a drawer, title, icon, and tags after capture.

### 6.5 Local-first by default

The app should work without cloud sync. User data should be stored locally first. Optional sync can be added later.

## 7. Core Mac Platform Assumptions

Orb is a native macOS application.

Recommended stack:

- Swift
- SwiftUI
- AppKit
- SQLite
- Filesystem-backed blob storage
- Optional local embedding model or remote LLM provider
- Optional cloud sync later

Important macOS APIs:

- **NSPasteboard** for reading and writing clipboard content.
- **NSPanel** or borderless AppKit windows for floating UI.
- **ScreenCaptureKit** for custom screen capture workflows.
- **Vision framework OCR** using `VNRecognizeTextRequest`.

## 8. Primary User Experience

### 8.1 Floating Orb

The orb is a small circular floating object on the desktop.

Default behavior:

- Always on top, but minimally intrusive.
- Can be dragged anywhere.
- Snaps gently to screen edges if desired.
- Click opens drawer.
- Right-click opens quick actions.
- Drag content onto orb to save.
- Orb pulses when new clipboard content is detected.
- Orb can be hidden from presentation mode or full-screen apps.
- Orb has configurable size, opacity, and color.

**States:**

1. **Idle** — Small orb, no active animation, subtle icon or user-selected symbol.
2. **Clipboard changed** — Orb pulses once, optional tiny badge, user can click to save latest clipboard.
3. **Dragging over orb** — Orb expands slightly, shows "Drop to save," supports text, links, files, images, PDFs, folders.
4. **Saving** — Quick animation, item enters drawer, optional toast: "Saved to Inbox."
5. **Expanded** — Drawer opens from orb; user can search, browse, copy, organize, preview, or paste.

### 8.2 Drawer Interface

Clicking the orb opens a vertical drawer — a compact column, not a full app window.

```
┌──────────────────────────────┐
│ Search Orb...                │
├──────────────────────────────┤
│ + Save Clipboard             │
│ + Screenshot                 │
│ + New Drawer                 │
├──────────────────────────────┤
│ Inbox                        │
│   🔗 Modal docs              │
│   🖼 Screenshot: pricing     │
│   ✂️ Python snippet          │
│   📄 Kind Designs PDF        │
├──────────────────────────────┤
│ Drawers                      │
│   🟦 Jobs                    │
│   🟩 Research                │
│   🟨 Companies               │
│   🟥 Trading Systems         │
└──────────────────────────────┘
```

The drawer should support:

- Compact item cards
- Expandable folders/drawers
- Color-coded drawer names
- Icons per drawer
- Drag-and-drop reordering
- Drag item into drawer
- Right-click item actions
- Keyboard navigation
- Search-first behavior

### 8.3 Item Card

Each saved item appears as a card with: icon, title, type, preview, source app, created time, drawer, tags, and actions.

### 8.4 Item Expansion

Clicking an item expands it inline or opens a side preview with full content, copy/open/move/tag/rename/delete, OCR/document text, AI summary, related items, and source metadata.

## 9. Clipboard Integration

### 9.1 Clipboard Listener

Orb observes the macOS general pasteboard:

- Detect when pasteboard changes
- Read available pasteboard types
- Classify content
- Show subtle orb pulse
- Do not automatically save everything by default
- Let user explicitly save current clipboard

### 9.2 Commands

Default global shortcuts:

| Shortcut | Action |
|----------|--------|
| Cmd + Shift + S | Save current clipboard to Orb |
| Cmd + Shift + V | Open Orb quick paste/search |
| Cmd + Shift + O | Toggle Orb drawer |
| Cmd + Shift + 2 | Capture screenshot to Orb |
| Cmd + Shift + D | Save clipboard directly into selected drawer |

### 9.3 Copy Behavior

Every saved item should be copyable back to the system clipboard via click, Enter, double-click, drag, or quick paste picker.

### 9.4 Clipboard Privacy

- Do not save every clipboard item by default
- Detect likely passwords, tokens, private keys, SSNs, credit card numbers
- Show warning before saving sensitive-looking content
- Allow excluded apps, private mode, pause clipboard watching

## 10. Screenshot Integration

Three screenshot workflows: save copied screenshot, orb screenshot shortcut with region selection, drop screenshot file onto orb.

Processing: original image, thumbnail, OCR text, optional visual summary, source metadata, suggested drawer/tags.

## 11. Documents and Files

Capture via drag onto orb, clipboard file URLs, or "Add File" from drawer.

Storage: reference original file or import copy into Orb storage.

Processing: extract text, searchable index, thumbnail, title, summary, headings, passage extraction.

## 12. Drawers

Folder-like collections with name, icon, color, optional parent, sort behavior, pinned status, and capture rules. Supports nesting and visual customization.

## 13. Item Types

- Text Snippet
- Link
- Fact Card
- Screenshot
- File
- Code Snippet
- Rich Clip

## 14. Search and Retrieval

Global search across title, content, URL, OCR, document text, tags, drawer, source app, notes, AI summary, and date.

Modes: exact keyword, fuzzy, semantic, type/drawer/date filters.

Quick paste search via Cmd + Shift + V. Query filters: `type:`, `drawer:`, `source:`, `before:`, `after:`, `tag:`, `has:`.

## 15. AI Features

Auto-title, auto-summary, suggested drawer/tags, fact extraction, duplicate detection, semantic recall. Privacy modes: local only, ask before cloud, cloud enabled, exclude sensitive drawers.

## 16. Data Model

### 16.1 Core Tables

**Item**

```
Item {
  id: string
  type: ItemType
  title: string
  preview: string
  contentText: string | null
  contentHTML: string | null
  sourceURL: string | null
  sourceApp: string | null
  sourceWindowTitle: string | null
  originalCreatedAt: Date | null
  createdAt: Date
  updatedAt: Date
  lastAccessedAt: Date | null
  drawerId: string | null
  isPinned: boolean
  isFavorite: boolean
  isArchived: boolean
  sensitivity: SensitivityLevel
}
```

**ItemType**

```
type ItemType =
  | "text"
  | "url"
  | "image"
  | "screenshot"
  | "file"
  | "pdf"
  | "code"
  | "html"
  | "fact"
  | "rich_clip"
```

**Drawer**, **Blob**, **Tag**, **ItemTag**, **Embedding**, **CaptureEvent**, **DrawerRule** — see `GOALS.md` Phase 2 for implementation mapping.

## 17. Local Storage Architecture

```
~/Library/Application Support/Orb/
  orb.sqlite
  blobs/
    originals/
    thumbnails/
    previews/
    ocr/
  indexes/
    fts/
    vector/
  backups/
  logs/
```

SQLite for metadata and FTS5 full-text search. Filesystem for blobs.

## 18. System Architecture

```
Orb App
  ├── Floating Window Manager
  ├── Drawer UI
  ├── Clipboard Monitor
  ├── Screenshot Controller
  ├── Drag-and-Drop Importer
  ├── Capture Classifier
  ├── Item Processor
  ├── Storage Engine
  ├── Search Engine
  ├── AI Assistant Layer
  ├── Permissions Manager
  └── Settings Manager
```

### 18.2 Capture Pipeline

```
Input event → Read raw content → Detect content type → Normalize content
→ Create item shell → Store raw blob/text → Generate preview
→ Extract text/OCR if needed → Generate title/tags/summary → Index item → Show in drawer
```

### 18.3 Clipboard Pipeline

```
Pasteboard change detected → Classify types → Show orb pulse → User saves clipboard
→ Read representation → Normalize item → Persist and index
```

### 18.4 Screenshot Pipeline

```
Screenshot shortcut → Region selection overlay → Capture image → Save blob
→ Generate thumbnail → Run OCR → Generate title/summary/tags → Index → Add to drawer
```

### 18.5 Search Pipeline

```
User query → Parse filters → Keyword search → Semantic search
→ Merge and rank → Display cards → User copies/opens/previews
```

## 19. UI Specification

- **Orb:** 44–56 px circular, semi-translucent, draggable, hover/drag/drop/pulse animations.
- **Drawer:** 320–420 px wide, dynamic height (max 80% screen), anchored near orb.
- **Full library:** optional detached window for bulk organization, advanced search, settings.
- **Command palette:** save clipboard, capture screenshot, create drawer, move/copy/open/summarize.

## 20. Keyboard UX

| Shortcut | Action |
|----------|--------|
| Cmd + Shift + S | Save clipboard |
| Cmd + Shift + V | Quick paste/search |
| Cmd + Shift + O | Toggle drawer |
| Cmd + Shift + 2 | Screenshot to Orb |
| Cmd + Shift + N | New drawer |
| Cmd + Enter | Copy selected item |
| Space | Preview selected item |
| Delete | Delete selected item |
| Esc | Close drawer |
| Arrow keys | Navigate |

## 21. Permissions

Clipboard, Accessibility (global shortcuts/auto-paste), Screen Recording (screenshot capture), Files and folders, Automation. Graceful degradation when denied.

## 22. Privacy and Security

Local-first, no cloud by default, sensitive content detection, private drawers, excluded apps, optional encryption, easy delete/export.

## 23. AI / LLM Architecture

AI tasks: title, tags, drawer suggestions, summarization, fact extraction, duplicate detection, semantic search, screenshot interpretation, document chunking, related items.

Queue states: `pending`, `processing`, `complete`, `failed`, `skipped_private`, `requires_user_permission`.

## 24. Performance Requirements

- Orb click to drawer open: < 100 ms
- Save text clipboard: < 200 ms
- Save image screenshot shell: < 500 ms
- Search first results: < 150 ms
- Copy item to clipboard: < 100 ms
- Drawer scroll: 60 FPS
- Idle memory: < 150 MB

## 25. Reliability Requirements

Transactional writes, coordinated blob + DB saves, crash recovery on launch, duplicate handling via checksums.

## 26. Settings

General, Capture, Search/Paste, AI, Privacy, Storage sections.

## 27. Export and Import

Export: JSON, Markdown, CSV, ZIP. Import: clipboard manager exports, Markdown, bookmarks, folders, JSON backups.

## 28. Product Differentiation

Combines clipboard history, floating spatial UI, screenshot OCR, document vault, drawer organization, AI summarization, fact extraction, semantic recall, and quick paste.

## 29. Example End-to-End Flows

Saving a link, saving a screenshot, saving a job requirement, using quick paste — see `GOALS.md` integration test scenarios.

## 30. Engineering Implementation Notes

Suggested modules: `OrbApp`, `AppDelegate`, `FloatingOrbWindow`, `DrawerWindow`, `QuickPasteWindow`, `ClipboardService`, `ScreenshotService`, `StorageService`, `SearchService`, `AIService`, `PermissionService`, `SettingsService`.

## 31. Ranking Logic

```
score =
  4.0 * title_match
+ 3.0 * tag_match
+ 2.5 * drawer_match
+ 2.0 * content_match
+ 2.0 * semantic_similarity
+ 1.0 * recency_boost
+ 1.0 * access_frequency
+ 3.0 * pinned_boost
```

## 32. Risks and Mitigations

Orb annoyance, clutter, privacy, wrong AI summaries, performance drag — each mitigated in spec sections 6, 15, 22, 24.

## 33. Success Metrics

Activation, engagement, retention, quality metrics including search success rate and reuse ratio.

## 34. North Star Metric

**Number of saved items successfully reused.**

## 35. Final Product Definition

Orb is a floating local-first memory layer for macOS.

The core feeling:

> I found something important. I threw it into the orb. Now I can get it back instantly.

The main technical point: this is absolutely buildable on macOS. The hardest parts are interaction polish, privacy model, and search/organization quality. The product wins if saving and retrieving feels nearly frictionless.
