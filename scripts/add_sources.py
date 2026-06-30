#!/usr/bin/env python3
"""Add Swift source files to Orb.xcodeproj."""
from __future__ import annotations

import re
import sys
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PBX = ROOT / "Orb.xcodeproj" / "project.pbxproj"

TARGET_MAP = {
    "Orb": "A90000010000000000000001",
    "OrbTests": "A90000020000000000000001",
    "OrbIntegrationTests": "A90000030000000000000001",
}

GROUP_MAP = {
    "Orb/Core": "A70000060000000000000001",
    "Orb/Storage": "A70000070000000000000001",
    "Orb/Capture": "A70000080000000000000001",
    "Orb/UI": "A70000090000000000000001",
    "Orb/Search": "A700000A0000000000000001",
    "Orb/AI": "A700000B0000000000000001",
    "Orb/Services": "A700000C0000000000000001",
    "Orb/Privacy": "A700000D0000000000000001",
    "OrbTests": "A70000030000000000000001",
    "OrbIntegrationTests": "A70000040000000000000001",
}


def uid() -> str:
    return uuid.uuid4().hex[:24].upper()


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: add_sources.py <target> <relative/path.swift> [...]")
        return 1

    target = sys.argv[1]
    files = [Path(p) for p in sys.argv[2:]]
    if target not in TARGET_MAP:
        print(f"unknown target: {target}")
        return 1

    text = PBX.read_text()
    for rel in files:
        rel = rel.as_posix()
        if rel in text:
            print(f"skip existing: {rel}")
            continue

        name = Path(rel).name
        file_id = uid()
        build_id = uid()
        group_key = "/".join(rel.split("/")[:-1]) if "/" in rel else target
        group_id = GROUP_MAP.get(group_key, GROUP_MAP.get(target, "A70000020000000000000001"))

        text = text.replace(
            "/* End PBXBuildFile section */",
            f"\t\t{build_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {name} */; }};\n/* End PBXBuildFile section */",
        )
        text = text.replace(
            "/* End PBXFileReference section */",
            f"\t\t{file_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};\n/* End PBXFileReference section */",
        )

        text = re.sub(
            rf"({group_id} /\* [^*]+ \*/ = \{{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \()",
            rf"\1\n\t\t\t\t{file_id} /* {name} */,",
            text,
            count=1,
        )

        phase_id = TARGET_MAP[target]
        text = re.sub(
            rf"({phase_id} = \{{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = \()",
            rf"\1\n\t\t\t\t{build_id} /* {name} in Sources */,",
            text,
            count=1,
        )
        print(f"added {rel} -> {target}")

    PBX.write_text(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
