#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="$(mktemp -d /tmp/visidelta-fixture.XXXXXX)"
OUT_DIR="$(mktemp -d /tmp/visidelta-output.XXXXXX)"

cleanup() {
  rm -rf "$FIXTURE_DIR" "$OUT_DIR"
}
trap cleanup EXIT

git -C "$FIXTURE_DIR" init -b main >/dev/null
git -C "$FIXTURE_DIR" config user.name "visidelta-ci"
git -C "$FIXTURE_DIR" config user.email "visidelta-ci@example.com"

cat > "$FIXTURE_DIR/index.md" <<'MD'
# Home

This is the base home page.
MD

cat > "$FIXTURE_DIR/about.md" <<'MD'
# About

Base about content.
MD

git -C "$FIXTURE_DIR" add .
git -C "$FIXTURE_DIR" commit -m "base" >/dev/null

cat > "$FIXTURE_DIR/index.md" <<'MD'
# Home

This is the updated home page with extra details.
MD

git -C "$FIXTURE_DIR" add index.md
git -C "$FIXTURE_DIR" commit -m "update home" >/dev/null

# shellcheck disable=SC2016
BUILD_CMD='mkdir -p "$DEST_DIR"; cp "$SRC_DIR/index.md" "$DEST_DIR/index.html"; mkdir -p "$DEST_DIR/about"; cp "$SRC_DIR/about.md" "$DEST_DIR/about/index.html"'

BUILD_OLD_CMD="$BUILD_CMD" BUILD_NEW_CMD="$BUILD_CMD" \
  "$ROOT_DIR/scripts/visidelta.sh" "HEAD~1" "$OUT_DIR" build "$FIXTURE_DIR"

test -f "$OUT_DIR/index.html"
test -f "$OUT_DIR/viewer.html"
test -f "$OUT_DIR/routes.json"
test -f "$OUT_DIR/diffs/p001.add.txt"
test -f "$OUT_DIR/diffs/p001.del.txt"

grep -q "viewer.html" "$OUT_DIR/index.html"
grep -q '"file":"index.md"' "$OUT_DIR/routes.json"

echo "Smoke test passed: generated output in $OUT_DIR"
