#!/usr/bin/env bash
# Shared helpers for the V-Team scheduled routines.
#
# Sourced by beat.sh and weekly.sh. Not executable on its own.

VT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VT_STATE="${VT_STATE:-$HOME/.v-team}"
VT_STAMPS="$VT_STATE/stamps"
VT_LOGS="$VT_STATE/logs"
mkdir -p "$VT_STAMPS" "$VT_LOGS"

# --- logging -----------------------------------------------------------------
# Every run leaves a trace whether it did anything or not. A routine that fails
# silently is worse than one that never ran, because you believe it is working
# (see the gbrain sync that had never once succeeded).
vt_log() {
  printf '%s  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" \
    | tee -a "$VT_LOGS/$(date -u '+%Y-%m').log" >&2
}

# --- locking -----------------------------------------------------------------
# No flock on macOS. `mkdir` is atomic on every filesystem we care about.
# A stale lock older than 2h is broken automatically — a hung run must not
# silence the schedule forever.
vt_lock() {
  local name="$1" dir="$VT_STATE/lock-$1"
  if ! mkdir "$dir" 2>/dev/null; then
    local age
    age=$(( $(date +%s) - $(stat -f %m "$dir" 2>/dev/null || date +%s) ))
    if (( age > 7200 )); then
      vt_log "lock $name stale (${age}s) — breaking"
      rm -rf "$dir"; mkdir "$dir" 2>/dev/null || return 1
    else
      vt_log "lock $name held (${age}s) — exiting"
      return 1
    fi
  fi
  # shellcheck disable=SC2064
  trap "rm -rf '$dir'" EXIT
  return 0
}

# --- stamps ------------------------------------------------------------------
# Written ONLY on full success, so a failed run retries on the next window.
vt_stamp_age_hours() {                       # $1 = stamp name; 99999 if never
  local f="$VT_STAMPS/$1"
  [[ -f "$f" ]] || { echo 99999; return; }
  echo $(( ( $(date +%s) - $(stat -f %m "$f") ) / 3600 ))
}
vt_stamp_touch() { date -u '+%Y-%m-%dT%H:%M:%SZ' > "$VT_STAMPS/$1"; }

# --- run mode ----------------------------------------------------------------
# The catch-up rule that matters: the cap is per RUN, never per missed day.
# Returning from a two-week gap must produce one good digest, not seventy
# stale ones — an unread proposal queue kills the loop faster than no loop.
vt_mode() {                                   # $1 = stamp age in hours
  local h="$1"
  if   (( h >= 99999 )); then echo cold-start   # never run — bounded, not "since 1970"
  elif (( h < 24  ));    then echo normal
  elif (( h < 168 ));    then echo catch-up
  else                        echo backfill
  fi
}

# Backfill is capped at 30 days. Beyond a month the material is no longer
# "what changed while you were away" — it is a literature review, and five
# ranked items cannot represent it honestly.
VT_BACKFILL_MAX_DAYS="${VT_BACKFILL_MAX_DAYS:-30}"

# --- registry ----------------------------------------------------------------
vt_resources() { grep -E '^  - name: ' "$VT_ROOT/registry.yaml" | sed 's/.*name: //' | tr -d ' '; }

vt_field() {                                  # $1 = resource, $2 = field
  awk "/^  - name: $1\$/,/^\$/" "$VT_ROOT/registry.yaml" \
    | grep -m1 "^    $2: " | sed "s/^    $2: //; s/[[:space:]]*$//"
}

# --- model -------------------------------------------------------------------
# Pluggable on purpose. Defaults to the Claude Code CLI; point VT_MODEL_CMD at
# a gateway script to move this work off the interactive quota without
# touching the routines. Reads the prompt on stdin, writes the answer to
# stdout.
VT_MODEL_CMD="${VT_MODEL_CMD:-}"
vt_model() {
  if [[ -n "$VT_MODEL_CMD" ]]; then
    $VT_MODEL_CMD
  elif command -v claude >/dev/null 2>&1; then
    claude -p --output-format text 2>/dev/null
  else
    vt_log "no model available (set VT_MODEL_CMD or install the claude CLI)"
    return 1
  fi
}

# --- memory ------------------------------------------------------------------
# Each resource reads and writes its OWN isolated gbrain source. Never another
# resource's — that is what keeps the independence rule real (docs/memory.md).
export VT_BRAIN_HOME="${VT_BRAIN_HOME:-$HOME/.v-team/brain}"

vt_brain() {                                  # $1 = source (callsign), rest = gbrain args
  local src="$1"; shift
  GBRAIN_HOME="$VT_BRAIN_HOME" GBRAIN_SOURCE="$src" gbrain "$@" 2>&1 | grep -v UPGRADE_AVAILABLE
}

# PGLite is SINGLE-WRITER: while `gbrain serve` holds the brain for MCP, a CLI
# write is refused. Spool instead of losing the write, and surface it — a
# scheduled job that fails silently is worse than one that never ran.
vt_brain_put() {                              # $1 = source, $2 = slug, content on stdin
  local src="$1" slug="$2" body spool
  body="$(cat)"
  if printf '%s' "$body" | GBRAIN_HOME="$VT_BRAIN_HOME" GBRAIN_SOURCE="$src" \
       gbrain put "$slug" >/dev/null 2>&1; then
    return 0
  fi
  spool="$VT_STATE/spool/$src"; mkdir -p "$spool"
  printf '%s' "$body" > "$spool/$slug.md"
  vt_log "brain locked — spooled $src/$slug (retries next window)"
  return 1
}

# Drain anything a previous run could not write.
vt_brain_drain() {
  local d="$VT_STATE/spool"; [[ -d "$d" ]] || return 0
  local f src slug
  for f in "$d"/*/*.md; do
    [[ -e "$f" ]] || continue
    src="$(basename "$(dirname "$f")")"; slug="$(basename "$f" .md)"
    if GBRAIN_HOME="$VT_BRAIN_HOME" GBRAIN_SOURCE="$src" gbrain put "$slug" < "$f" >/dev/null 2>&1; then
      rm -f "$f"; vt_log "drained $src/$slug"
    fi
  done
}

# --- daily journal -----------------------------------------------------------
vt_journal() {                                # append one line to today's journal
  local f="$VT_ROOT/ledger/reports/daily/$(date -u '+%Y-%m-%d').md"
  [[ -f "$f" ]] || printf '# Daily journal — %s\n\nRaw. No conclusions, no state changes.\n\n' \
    "$(date -u '+%Y-%m-%d')" > "$f"
  printf -- '- %s\n' "$*" >> "$f"
}
