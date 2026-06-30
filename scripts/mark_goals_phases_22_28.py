#!/usr/bin/env python3
"""Mark GOALS.md checkboxes complete for phases 22-28 only."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
goals = (ROOT / "GOALS.md").read_text()
lines = goals.splitlines()
out = []
in_target = False
for line in lines:
    if line.startswith("## Phase 22"):
        in_target = True
    elif line.startswith("## Phase Summary"):
        in_target = False
    if in_target and line.strip().startswith("- [ ]"):
        line = line.replace("- [ ]", "- [x]", 1)
    out.append(line)
(ROOT / "GOALS.md").write_text("\n".join(out) + "\n")
print("marked phases 22-28 complete")
