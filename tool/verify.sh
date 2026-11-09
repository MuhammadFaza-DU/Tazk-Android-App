#!/usr/bin/env bash
# Local gate — same checks as .github/workflows/ci.yml.
# Run before a checkpoint/tag:  bash tool/verify.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== flutter pub get =="
flutter pub get

echo "== dart analyze =="
dart analyze

echo "== flutter test =="
flutter test

echo "GATE OK"