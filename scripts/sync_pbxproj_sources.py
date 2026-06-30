#!/usr/bin/env python3
"""Sync PBXSourcesBuildPhase entries from existing PBXBuildFile records."""
from __future__ import annotations

import re
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PBX = ROOT / "Orb.xcodeproj" / "project.pbxproj"

PHASES = {
    "Orb": "A90000010000000000000001",
    "OrbTests": "A90000020000000000000001",
    "OrbIntegrationTests": "A90000030000000000000001",
}

PREFIXES = {
    "Orb": "Orb/",
    "OrbTests": "OrbTests/",
    "OrbIntegrationTests": "OrbIntegrationTests/",
}


SHARED_INTEGRATION_HELPERS = ("MockPasteboard.swift", "TestFixtures.swift")


def ensure_integration_helpers(
    text: str, build_files: dict[str, tuple[str, str]]
) -> tuple[list[str], str]:
    entries: list[str] = []
    for helper in SHARED_INTEGRATION_HELPERS:
        matching = [bid for bid, (name, _) in build_files.items() if name == helper]
        if not matching:
            continue
        ref_id = build_files[matching[0]][1]
        if len(matching) >= 2:
            integration_build_id = matching[1]
        else:
            integration_build_id = uuid.uuid4().hex[:24].upper()
            text = text.replace(
                "/* End PBXBuildFile section */",
                (
                    f"\t\t{integration_build_id} /* {helper} in Sources */ = "
                    f"{{isa = PBXBuildFile; fileRef = {ref_id} /* {helper} */; }};\n"
                    "/* End PBXBuildFile section */"
                ),
            )
            build_files[integration_build_id] = (helper, ref_id)
        entries.append(f"\t\t\t\t{integration_build_id} /* {helper} in Sources */,")
    return entries, text


def main() -> int:
    text = PBX.read_text()

    file_refs: dict[str, str] = {}
    for match in re.finditer(
        r"(\w+) /\* ([^*]+\.swift) \*/ = \{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ([^;]+);",
        text,
    ):
        file_refs[match.group(1)] = match.group(3)

    build_files: dict[str, tuple[str, str]] = {}
    for match in re.finditer(
        r"(\w+) /\* ([^*]+\.swift) in Sources \*/ = \{isa = PBXBuildFile; fileRef = (\w+)",
        text,
    ):
        build_files[match.group(1)] = (match.group(2), match.group(3))

    by_target: dict[str, list[str]] = {target: [] for target in PHASES}
    for build_id, (name, ref_id) in build_files.items():
        path = file_refs.get(ref_id, name)
        for target, prefix in PREFIXES.items():
            if path.startswith(prefix) or (target != "Orb" and path == name and prefix.rstrip("/") in path):
                pass
        for target, prefix in PREFIXES.items():
            rel = None
            if path.startswith(prefix):
                rel = path
            elif path == name:
                if target == "OrbTests" and (ROOT / "OrbTests" / name).exists():
                    rel = f"OrbTests/{name}"
                elif target == "OrbIntegrationTests" and (ROOT / "OrbIntegrationTests" / name).exists():
                    rel = f"OrbIntegrationTests/{name}"
                elif target == "Orb" and (ROOT / "Orb").rglob(name):
                    matches = list((ROOT / "Orb").rglob(name))
                    if matches:
                        rel = str(matches[0].relative_to(ROOT)).replace("\\", "/")
            if rel and rel.startswith(prefix):
                by_target[target].append(f"\t\t\t\t{build_id} /* {name} in Sources */,")
                break

    helper_entries, text = ensure_integration_helpers(text, build_files)
    by_target["OrbIntegrationTests"].extend(helper_entries)

    for target, phase_id in PHASES.items():
        entries = sorted(set(by_target[target]))
        replacement = (
            f"{phase_id} = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (\n"
            + "\n".join(entries)
            + "\n\t\t\t); runOnlyForDeploymentPostprocessing = 0; };"
        )
        text, count = re.subn(
            rf"{phase_id} = \{{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = \([\s\S]*?\); runOnlyForDeploymentPostprocessing = 0; \}};",
            replacement,
            text,
            count=1,
        )
        if count != 1:
            raise SystemExit(f"failed to update sources phase for {target}")
        print(f"{target}: {len(entries)} sources")

    PBX.write_text(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
