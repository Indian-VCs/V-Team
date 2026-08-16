#!/usr/bin/env bash
# Create the V-Team's own brain — isolated from the personal one.
#
#   ./scripts/setup-brain.sh              # create / repair (idempotent)
#   ./scripts/setup-brain.sh --status
#   ./scripts/setup-brain.sh --mcp        # mint a per-resource OAuth client and
#                                         # register one HTTP MCP server each
#
# ORDER MATTERS for --mcp, and the script now owns the order rather than asking
# you to remember it. Minting a client writes to PGLite, so it needs the server
# STOPPED; issuing that client an access token goes through the OAuth /token
# endpoint, so it needs the server UP. Those are opposite requirements, which is
# why --mcp runs in two phases and starts the server itself between them.
#
# Start it with the server stopped. Then restart your session: a registration
# only reaches a NEW session, and an agent dispatched from the session already
# running will not see it.
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
#
# Callsign moved from a `resources:` row to `people:` in docs/org-model.md's
# migration (stage 1+2) — a store belongs to a PERSON, which is what the field
# meant all along. Block-scoped to `people:` specifically: `retired_callsigns:`
# uses the identical "  - callsign: " shape, and a file-wide grep would try to
# mint tokens for six dead names on every run.
STORES="$(awk '
  /^people:/  { inb=1; next }
  /^[a-z_]+:/ { inb=0 }
  inb && /^  - callsign: / { c=$0; sub(/^  - callsign: /,"",c); sub(/[[:space:]]*#.*/,"",c); gsub(/[[:space:]]*$/,"",c); print c }
' "$ROOT/registry.yaml" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
[[ -n "${STORES// }" ]] || { echo "no callsigns in registry.yaml people: — refusing to run"; exit 1; }

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

# Creating a source and seeding an orientation page both WRITE, so both need the
# PGLite file — which a running `gbrain serve` holds. Skip them loudly rather
# than aborting: `--mcp` re-runs (refresh a token, re-register a server, rewrite
# a client config) need none of this, and before this guard the whole script
# died here on `set -e` the moment the server it had just started was up.
BRAIN_OPEN=yes
gbrain sources list >/dev/null 2>&1 || BRAIN_OPEN=""
if [[ -z "$BRAIN_OPEN" ]]; then
  echo
  echo "sources/orientation: SKIPPED — the brain is open through a running 'gbrain serve'."
  echo "  Both write to the PGLite file. If a store or an orientation page is"
  echo "  missing, stop the server and re-run:  pkill -TERM -f 'gbrain serve'"
fi

# `default` is federated — every resource searches it without asking. That is
# the TEAM store: shared findings, conventions, anything meant to be common.
if [[ -n "$BRAIN_OPEN" ]]; then
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
fi  # BRAIN_OPEN

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

  SECRETS="${VT_SECRETS:-$HOME/.v-team/secrets}"
  mkdir -p "$SECRETS"; chmod 700 "$SECRETS"

  # Minting writes to the DB, so it needs the PGLite file and therefore needs
  # `serve` stopped. Re-running to refresh configs or registrations needs
  # neither. Demand the lock only when something is actually missing, or the
  # script stops being re-runnable the moment it has succeeded once — which is
  # the state it spends almost all of its life in.
  NEED_MINT=""
  for s in $STORES; do
    [[ -s "$SECRETS/$s-client-id" && -s "$SECRETS/$s-client-secret" ]] || NEED_MINT="yes"
  done
  if [[ -n "$NEED_MINT" ]] && ! gbrain auth list >/dev/null 2>&1; then
    echo "cannot mint clients: the brain is locked (a 'gbrain serve' is running?)."
    echo "stop it, re-run '$0 --mcp' — it will restart the server itself:"
    echo "  pkill -TERM -f 'gbrain serve'"
    exit 1
  fi

  # PHASE 1 — mint one OAuth client per callsign, server STOPPED.
  #
  # `register-client` writes to the DB, so it needs the PGLite file. It prints
  # the client id and secret as text and exits; there is no --json on this
  # subcommand, so the values are read back with a regex on the exact token
  # prefixes gbrain mints (`gbrain_cl_` / `gbrain_cs_`). Both are shown once
  # and never again, which is why they are captured here rather than re-derived.
  #
  # read ONLY, federated onto its own store plus the shared team store. Never
  # the full-access token in $SECRETS/mcp-token — that one is unscoped, reads
  # every store, and is reserved for the write path.
  for s in $STORES; do
    if [[ -s "$SECRETS/$s-client-id" && -s "$SECRETS/$s-client-secret" ]]; then
      echo "  $s — client exists"
      continue
    fi
    out="$(gbrain auth register-client "vteam-$s" \
             --grant-types client_credentials --scopes "read" \
             --source "$s" --federated-read "$s,default" 2>&1)" || true
    grep -oE 'gbrain_cl_[A-Za-z0-9_-]+' <<<"$out" | head -1 > "$SECRETS/$s-client-id"
    grep -oE 'gbrain_cs_[A-Za-z0-9_-]+' <<<"$out" | head -1 > "$SECRETS/$s-client-secret"
    unset out
    if [[ -s "$SECRETS/$s-client-id" && -s "$SECRETS/$s-client-secret" ]]; then
      chmod 600 "$SECRETS/$s-client-id" "$SECRETS/$s-client-secret"
      echo "  $s — client minted"
    else
      rm -f "$SECRETS/$s-client-id" "$SECRETS/$s-client-secret"
      echo "  $s — MINT FAILED (see docs/memory.md)"
    fi
  done

  # PHASE 2 — the server has to be UP for this half.
  #
  # An access token is issued by the OAuth `/token` endpoint, not by
  # register-client, so it cannot be obtained while the server is stopped.
  # That is the ordering the previous revision got backwards: it tried to read
  # an `access_token` out of the minting call, which never contained one.
  if ! curl -fsS -m 3 "http://127.0.0.1:$VT_MCP_PORT/health" >/dev/null 2>&1; then
    echo
    echo "starting the HTTP MCP server on 127.0.0.1:$VT_MCP_PORT"
    mkdir -p "$HOME/.v-team/logs"
    ( GBRAIN_HOME="$GBRAIN_HOME" nohup gbrain serve --http --port "$VT_MCP_PORT" \
        --bind 127.0.0.1 --token-ttl 31536000 --suppress-bootstrap-token \
        >> "$HOME/.v-team/logs/serve-http.log" 2>&1 & )
    for _ in $(seq 1 30); do
      curl -fsS -m 2 "http://127.0.0.1:$VT_MCP_PORT/health" >/dev/null 2>&1 && break
      sleep 1
    done
  fi
  curl -fsS -m 3 "http://127.0.0.1:$VT_MCP_PORT/health" >/dev/null 2>&1 || {
    echo "server did not come up on :$VT_MCP_PORT — see $HOME/.v-team/logs/serve-http.log"
    exit 1
  }

  echo
  for s in $STORES; do
    tokfile="$SECRETS/$s-access-token"
    if [[ ! -s "$tokfile" ]]; then
      [[ -s "$SECRETS/$s-client-id" ]] || { echo "  $s — no client, skipped"; continue; }
      # client_credentials: the grant that needs no human at a browser, which is
      # the whole point for an unattended resource.
      curl -fsS -m 15 -X POST "http://127.0.0.1:$VT_MCP_PORT/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "client_id=$(cat "$SECRETS/$s-client-id")" \
        --data-urlencode "client_secret=$(cat "$SECRETS/$s-client-secret")" \
        2>/dev/null | jq -r '.access_token // empty' > "$tokfile" || true
      [[ -s "$tokfile" ]] && chmod 600 "$tokfile"
    fi
    if [[ ! -s "$tokfile" ]]; then
      rm -f "$tokfile"
      echo "  $s — NO TOKEN (mint manually, see docs/memory.md)"
      continue
    fi
    # Thin-client config: the SAME OAuth client, reachable from plain Bash.
    #
    # This is the path that works in a session that is already running. An MCP
    # registration only reaches a NEW session, so a resource dispatched right
    # now has no MCP tools — and the old fallback ("export GBRAIN_HOME=the
    # brain") opens the PGLite file directly and therefore fails for exactly as
    # long as the server is up. That left the common case with no working path
    # at all, which is the failure this whole change exists to remove.
    #
    # `remote_mcp` puts the CLI in thin-client mode: gbrain routes each op
    # through the running server over HTTP instead of opening the file, and
    # renders it with the same formatter. Same grant, same denials.
    cdir="$HOME/.v-team/clients/$s/.gbrain"
    mkdir -p "$cdir"
    umask 077
    cat > "$cdir/config.json" <<EOF
{
  "remote_mcp": {
    "issuer_url": "http://127.0.0.1:$VT_MCP_PORT",
    "mcp_url": "http://127.0.0.1:$VT_MCP_PORT/mcp",
    "oauth_client_id": "$(cat "$SECRETS/$s-client-id")",
    "oauth_client_secret": "$(cat "$SECRETS/$s-client-secret")"
  },
  "embedding_model": "$EMBED",
  "embedding_dimensions": $DIMS
}
EOF
    chmod 600 "$cdir/config.json"

    claude mcp remove "vteam-brain-$s" --scope user >/dev/null 2>&1 || true
    if claude mcp add --transport http --scope user "vteam-brain-$s" \
         "http://127.0.0.1:$VT_MCP_PORT/mcp" \
         --header "Authorization: Bearer $(cat "$tokfile")" >/dev/null 2>&1; then
      # ${s} braced: `$s__` is a legal identifier, so under `set -u` the
      # unbraced form expanded to an unbound variable and aborted the loop.
      echo "  $s — registered 'vteam-brain-$s' (tools: mcp__vteam-brain-${s}__*)"
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
