#!/usr/bin/env bash
# Sync V-Team resource definitions into a product repo.
#
#   ./scripts/sync.sh ../prism-platform            # copy in
#   ./scripts/sync.sh ../prism-platform --check    # fail on drift, copy nothing
#
# This repo is the source of truth. A product's .claude/agents/ is a mirror —
# never edit it there; edit here and re-sync. Mirrors the CLAUDE.md/AGENTS.md
# drift check prism-platform already runs.

set -euo pipefail

TARGET="${1:-}"
MODE="${2:-write}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/resources"

if [[ -z "$TARGET" ]]; then
  echo "usage: $0 <path-to-product-repo> [--check]" >&2
  exit 2
fi

if [[ ! -d "$TARGET/.git" ]]; then
  echo "error: $TARGET is not a git repository" >&2
  exit 2
fi

DEST="$TARGET/.claude/agents"

if [[ "$MODE" == "--check" ]]; then
  status=0
  for f in "$SRC"/*.md; do
    name="$(basename "$f")"
    if [[ ! -f "$DEST/$name" ]]; then
      echo "::error::missing in $TARGET: .claude/agents/$name"
      status=1
    elif ! diff -q "$f" "$DEST/$name" >/dev/null; then
      echo "::error::drifted: .claude/agents/$name — re-run sync.sh from v-team"
      diff -u "$f" "$DEST/$name" || true
      status=1
    fi
  done
  [[ $status -eq 0 ]] && echo "in sync: $TARGET"
  exit $status
fi

mkdir -p "$DEST"
cp "$SRC"/*.md "$DEST/"
echo "synced $(ls -1 "$SRC"/*.md | wc -l | tr -d ' ') resources -> $DEST"
echo "commit them in $TARGET on a branch — never straight to master."
