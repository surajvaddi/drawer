#!/usr/bin/env python3
"""Commit uncommitted GOALS steps one at a time."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path(__file__).with_name("goals_manifest.json")
GOALS = ROOT / "GOALS.md"
GENERATE = ROOT / "scripts" / "generate_pbxproj.py"

APP_DELEGATE_NO_LOGGER = '''import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
'''

APP_DELEGATE_WITH_LOGGER = '''import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        OrbLogger.shared.info("Orb application did finish launching")
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
'''


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, **kwargs)


def step_files(step: str, manifest: dict) -> list[str]:
    entry = manifest["steps"][step]
    files = []
    for key in ("orb", "orbtests", "integration", "other", "patches"):
        files.extend(entry.get(key, []))
    files.append("Orb.xcodeproj/project.pbxproj")
    return files


def mark_goals(step: str) -> None:
    title_map = {
        "0.1": "Step 0.1: Create Xcode macOS App Target",
        "0.2": "Step 0.2: Add Test Targets and CI Script",
        "0.3": "Step 0.3: Define Module Folder Structure",
        "0.4": "Step 0.4: Add Shared Utilities and Logging",
        "1.1": "Step 1.1: Implement ItemType and SensitivityLevel Enums",
        "1.2": "Step 1.2: Implement Item Model",
        "1.3": "Step 1.3: Implement Drawer Model",
        "1.4": "Step 1.4: Implement Tag and ItemTag Models",
        "1.5": "Step 1.5: Implement Blob, Embedding, and CaptureEvent Models",
        "1.6": "Step 1.6: Implement DrawerRule and AIAnnotation Models",
    }
    title = title_map[step]
    text = GOALS.read_text()
    pattern = rf"(### {re.escape(title)}\n\n)- \[ \]"
    new_text, n = re.subn(pattern, r"\1- [x]", text, count=1)
    if n != 1:
        raise SystemExit(f"could not mark {step} in GOALS.md")
    GOALS.write_text(new_text)


def prepare_app_delegate(step: str, order: list[str]) -> None:
  idx = order.index(step)
  use_logger = any(s in order[: idx + 1] for s in ("0.4",))
  content = APP_DELEGATE_WITH_LOGGER if use_logger else APP_DELEGATE_NO_LOGGER
  (ROOT / "Orb/AppDelegate.swift").write_text(content)


def fix_integration_imports() -> None:
    for path in (ROOT / "OrbIntegrationTests").glob("*.swift"):
        text = path.read_text()
        if "@testable import Orb" in text or "import XCTest\n\nfinal class CIScript" in text:
            continue
        if "ItemType" in text or "Item(" in text or "Drawer" in text or "Tag" in text or "CaptureEvent" in text or "AIAnnotation" in text:
            text = text.replace("import XCTest\n", "import XCTest\n@testable import Orb\n", 1)
            path.write_text(text)


def commit_step(step: str, manifest: dict) -> str:
    entry = manifest["steps"][step]
    prepare_app_delegate(step, manifest["order"])
    fix_integration_imports()

    # ensure gitkeep dirs exist for 0.3+
    for folder in ["Storage", "Capture", "UI", "Search", "AI", "Services"]:
        p = ROOT / "Orb" / folder
        p.mkdir(parents=True, exist_ok=True)
        keep = p / ".gitkeep"
        if not keep.exists():
            keep.write_text("")

    gen = run([sys.executable, str(GENERATE), step])
    if gen.returncode != 0:
        raise SystemExit(gen.stderr or gen.stdout)

    files = step_files(step, manifest)
    if step in manifest["order"] and manifest["order"].index(step) >= manifest["order"].index("0.4"):
        pass  # AppDelegate already written

  # stage only this step's new files + pbxproj + goals
    for f in files:
        path = ROOT / f
        if not path.exists():
            raise SystemExit(f"missing file for {step}: {f}")

    mark_goals(step)

    run(["git", "add"] + files + ["GOALS.md"])
    msg = entry["message"]
    commit = run(["git", "commit", "-m", msg])
    if commit.returncode != 0:
        raise SystemExit(commit.stderr or commit.stdout)
    rev = run(["git", "rev-parse", "--short", "HEAD"]).stdout.strip()
    return f"{rev} {msg}"


def main() -> int:
    start = sys.argv[1] if len(sys.argv) > 1 else None
    end = sys.argv[2] if len(sys.argv) > 2 else None
    manifest = json.loads(MANIFEST.read_text())
    order = manifest["order"]
    if start:
        order = order[order.index(start):]
    if end:
        order = order[: order.index(end) + 1]

    commits = []
    for step in order:
        print(f"=== Committing step {step} ===")
        commits.append(commit_step(step, manifest))
        print(commits[-1])

    print("\nDone. Commits:")
    for c in commits:
        print(c)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
