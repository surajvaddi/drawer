#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="Orb"
DESTINATION="platform=macOS"

cd "$ROOT"

if [[ "${ORB_CI_NESTED:-0}" == "1" ]]; then
  xcodebuild \
    -project Orb.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -quiet \
    build-for-testing
else
  xcodebuild \
    -project Orb.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -quiet \
    test
fi
