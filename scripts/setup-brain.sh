#!/usr/bin/env bash
# Create the V-Team's own brain — isolated from the personal one.
#
#   ./scripts/setup-brain.sh              # create / repair (idempotent)
#   ./scripts/setup-brain.sh --status
#   ./scripts/setup-brain.sh --mcp        # mint a per-resource OAuth client and
#                                         # register one HTTP MCP server each
#
# ORDER MATTERS for --mcp: it mints clients through the CLI, which cannot open
# the PGLite file while `gbrain serve` holds it. Run it with the server STOPPED,
# then start the server, then restart your session.
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
# The HTTP MCP server resources read through. Loopback only — see docs/memory.md.
VT_MCP_PORT="${VT_MCP_PORT:-7433}"

# Callsign -> resource. The source id is the callsign: a store belongs to
# someone, and `--source heimdall` reads better than `--source adversarial-reviewer`.
#
# DERIVED FROM registry.yaml, never hand-listed. It was a frozen list until
# 2026-08-16, which is exactly how ariadne, marshal and janus ended up with no
# store: setup-brain.sh created sources for the resources that existed the day
# it ran, and nothing in the /hire path added one afterwards. Their orientation
# notes fell through to `default` — which is FEDERATED, so every resource could
# read them — and all three wrote the same slug, so two were overwritten and
# lost. See ledger/escapes/2026-08-16-hire-path-no-brain-source.md.
STORES="$(grep -E '^    callsign: ' "$ROOT/registry.yaml" \
          | sed 's/.*callsign: //; s/#.*//' | tr -d ' ' | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
[[ -n "${STORES// }" ]] || { echo "no callsigns in registry.yaml — refusing to run"; exit 1; }

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
  # ONE HTTP SERVER, ONE REGISTRATION PER RESOURCE.
  #
  # This used to register a single STDIO server (`command: gbrain`, `args:
  # [serve]`) and it never once connected: an MCP server inherits the spawning
  # process's PATH, gbrain lives in ~/.bun/bin, and that PATH does not have it.
  # Stdio was also the wrong shape — every client spawns its OWN `gbrain serve`,
  # each tries to open the same PGLite file, and all but the first are refused.
  # Stdio cannot fix a single-writer problem because stdio multiplies writers.
  #
  # Over HTTP one server owns the file and everyone else is a network client.
  # And because the BEARER TOKEN CARRIES THE IDENTITY — its source_id and the
  # sources it may read — one shared registration would hand every resource the
  # same identity, which is worse than what it replaces. So: one OAuth client
  # and one registration per callsign. See docs/memory.md.
  if ! command -v claude >/dev/null 2>&1; then
    echo "claude CLI not found — see docs/memory.md to register manually"
    exit 0
  fi

  # register-client writes to the DB, so it cannot run while `serve` holds the
  # PGLite lock. Say so plainly instead of emitting eight identical failures.
  if ! gbrain auth list >/dev/null 2>&1; then
    echo "cannot mint clients: the brain is locked (a 'gbrain serve' is running?)."
    echo "stop it, re-run '$0 --mcp', then start the server again:"
    echo "  gbrain serve --http --port $VT_MCP_PORT --bind 127.0.0.1 \\"
    echo "    --token-ttl 31536000 --suppress-bootstrap-token \\"
    echo "    >> $HOME/.v-team/logs/serve-http.log 2>&1 &"
    exit 1
  fi

  SECRETS="${VT_SECRETS:-$HOME/.v-team/secrets}"
  mkdir -p "$SECRETS"; chmod 700 "$SECRETS"

  for s in $STORES; do
    tokfile="$SECRETS/$s-access-token"
    if [[ ! -s "$tokfile" ]]; then
      # read ONLY, and federated onto its own store plus the shared team store.
      # Never the full-access token in $SECRETS/mcp-token — that one is unscoped,
      # reads every store, and is reserved for the write path.
      #
      # UNVERIFIED: the flags are from `gbrain auth register-client --help` and
      # the resulting grant was confirmed against the live server via `whoami`
      # for `samwise`, but this minting call was never executed — the brain was
      # locked by a running `serve` throughout, which is the whole reason this
      # block insists on being run with the server stopped. If the token does
      # not land, check the real key name in $SECRETS/<callsign>-client.json.
      if gbrain auth register-client "vteam-$s" \
           --scopes "read" --source "$s" --federated-read "$s,default" \
           --json > "$SECRETS/$s-client.json" 2>/dev/null; then
        jq -r '.access_token // .token // empty' "$SECRETS/$s-client.json" > "$tokfile"
        chmod 600 "$tokfile" "$SECRETS/$s-client.json"
      fi
    fi
    if [[ ! -s "$tokfile" ]]; then
      echo "  $s — NO TOKEN (mint manually, see docs/memory.md)"
      continue
    fi
    claude mcp remove "vteam-brain-$s" --scope user >/dev/null 2>&1 || true
    if claude mcp add --transport http --scope user "vteam-brain-$s" \
         "http://127.0.0.1:$VT_MCP_PORT/mcp" \
         --header "Authorization: Bearer $(cat "$tokfile")" >/dev/null 2>&1; then
      echo "  $s — registered 'vteam-brain-$s' (tools: mcp__vteam-brain-$s__*)"
    else
      echo "  $s — registration FAILED, see docs/memory.md"
    fi
  done

  # The stdio registration this replaces. Left connected it shadows nothing, but
  # it does keep reporting a failure in `claude mcp list` forever.
  claude mcp remove vteam-brain --scope user >/dev/null 2>&1 \
    && echo "  removed the old stdio 'vteam-brain' registration"

  echo
  echo "A NEW REGISTRATION ONLY REACHES A NEW SESSION. A server added mid-session"
  echo "is invisible to agents dispatched from the session already running."
  echo "Restart your session before believing any of this works."
fi

echo
echo "done. status: $0 --status"
echo "query as a resource:  GBRAIN_HOME=$GBRAIN_HOME GBRAIN_SOURCE=heimdall gbrain query '...'"
