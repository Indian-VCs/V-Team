#!/usr/bin/env bash
# Create the V-Team's own brain — isolated from the personal one.
#
#   ./scripts/setup-brain.sh              # create / repair (idempotent)
#   ./scripts/setup-brain.sh --status
#   ./scripts/setup-brain.sh --mcp        # also register the MCP server
#
# WHY A SEPARATE BRAIN, not a source inside ~/.gbrain:
#   The personal brain is BEHAVIOURAL ONLY by standing doctrine — preferences,
#   decisions and their rationale, never knowledge or code. A resource's
#   episodic memory ("this file bit me twice") is knowledge. Mixing them
#   violates a rule already written, and it would put an automated writer
#   inside the store that holds how Dhayan works.
#
# GBRAIN_HOME gives a genuinely separate config + database. ~/.gbrain is never
# read or written by anything here.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GBRAIN_HOME="${VT_BRAIN_HOME:-$HOME/.v-team/brain}"
EMBED="${VT_EMBED:-ollama:nomic-embed-text}"
DIMS="${VT_EMBED_DIMS:-768}"

# Callsign -> resource. The source id is the callsign: a store belongs to
# someone, and `--source heimdall` reads better than `--source adversarial-reviewer`.
STORES="hermione neo heimdall samwise alfred"

case "${1:-setup}" in
  --status)
    echo "GBRAIN_HOME=$GBRAIN_HOME"
    [[ -d "$GBRAIN_HOME/.gbrain" ]] || { echo "not initialised — run $0"; exit 1; }
    gbrain sources list 2>/dev/null | grep -v UPGRADE_AVAILABLE
    echo; echo "personal brain (untouched): $(jq -r .database_path ~/.gbrain/config.json 2>/dev/null)"
    exit 0 ;;
esac

mkdir -p "$GBRAIN_HOME"

if [[ -d "$GBRAIN_HOME/.gbrain" ]]; then
  echo "brain exists at $GBRAIN_HOME/.gbrain — leaving it alone"
else
  echo "creating V-Team brain at $GBRAIN_HOME/.gbrain ($EMBED @${DIMS}d)"
  # Ollama: embeddings cost nothing and run on-device, and it is already a
  # login service here. The scheduled routines embed on every write, so a
  # metered embedding provider would turn the beat into a recurring bill.
  gbrain init --pglite --non-interactive \
    --embedding-model "$EMBED" --embedding-dimensions "$DIMS" >/dev/null 2>&1 \
    || { echo "gbrain init failed"; exit 1; }
fi

# `default` is federated — every resource searches it without asking. That is
# the TEAM store: shared findings, conventions, anything meant to be common.
echo
echo "sources:"
for s in $STORES; do
  if gbrain sources list 2>/dev/null | grep -qE "^  $s "; then
    echo "  $s — exists"
  else
    # No --path => ISOLATED: only searched when explicitly named via --source.
    # This is what makes episodic memory first-person by construction rather
    # than by policy. Heimdall cannot read Neo's notebook even if it tried,
    # which is what keeps the independence rule intact.
    gbrain sources add "$s" >/dev/null 2>&1 && echo "  $s — created (isolated)"
  fi
done

# Orientation. A new hire reads before touching anything; a new resource had no
# equivalent. One page per store, written once, never overwritten.
echo
echo "orientation:"
for s in $STORES; do
  if GBRAIN_SOURCE="$s" gbrain get "orientation" >/dev/null 2>&1; then
    echo "  $s — already oriented"
    continue
  fi
  GBRAIN_SOURCE="$s" gbrain put "orientation" >/dev/null 2>&1 <<EOF
---
title: Orientation — $s
type: reference
tags: [v-team, orientation]
---

# Orientation

This store is **yours alone**. It is an isolated gbrain source: nothing else on
the team can read it, and you must not read anyone else's. That isolation is
what keeps the independence rule real — two resources that read each other are
one resource.

## What belongs here

- **Episodic memory.** What *you* observed, and what happened to *your*
  findings. "Flagged the RSC boundary in Table.tsx on 2026-08-14 — confirmed."
- **Surface notes.** Accumulated per file or module: \`surface-<path>\`. Where
  things have bitten you before.
- **Your record.** Findings raised, confirmed, dismissed. Derived, not claimed.

## What does not

- Another resource's conclusions. First-person only.
- Anything meant to be shared — that goes to the \`default\` (team) source,
  which everyone searches.
- Rules. Rules live in the repo and move through states on evidence
  (\`docs/learning.md\`). This store is memory, not law.

## Before your first real task

Read, in the product repo: \`CLAUDE.md\` (especially "Hard rules & gotchas"),
then \`ledger/escapes/\` for anything touching your surfaces. Most of what will
bite you has already bitten someone.
EOF
  echo "  $s — oriented"
done

if [[ "${1:-}" == "--mcp" ]]; then
  echo
  if command -v claude >/dev/null 2>&1; then
    claude mcp add vteam-brain --scope user --env "GBRAIN_HOME=$GBRAIN_HOME" -- gbrain serve \
      && echo "registered MCP server 'vteam-brain' (tools: mcp__vteam-brain__*)" \
      || echo "MCP registration failed — register manually, see docs/memory.md"
  else
    echo "claude CLI not found — see docs/memory.md to register manually"
  fi
fi

echo
echo "done. status: $0 --status"
echo "query as a resource:  GBRAIN_HOME=$GBRAIN_HOME GBRAIN_SOURCE=heimdall gbrain query '...'"
