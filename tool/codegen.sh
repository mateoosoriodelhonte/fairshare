#!/usr/bin/env bash
# Regenerates Drift code and formats it with the project's line width so the
# committed output is byte-identical on every machine and in CI.
set -euo pipefail
cd "$(dirname "$0")/.."
dart run build_runner build --delete-conflicting-outputs
dart format lib/data/db
