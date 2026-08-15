#!/usr/bin/env bash
# Orientation — the ramp a new hire gets and a resource previously did not.
#
#   ./scripts/orient.sh                    # any resource not yet oriented
#   ./scripts/orient.sh heimdall           # one, forced
#   ./scripts/orient.sh --status
#
# setup-brain.sh seeds an `orientation` PAGE telling a resource what to read.
# Nothing made it read. This runs the ramp for real: it puts the product's hard
# rules and the escapes touching that resource's surfaces in front of it, and
# writes what it took away into ITS OWN store.
#
# Runs once per resource. Re-running is safe and is the right move after a
# resource's definition changes — a changed resource is a different worker.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

PRODUCT="${VT_PRODUCT:-$VT_ROOT/../prism-platform}"
ARG="${1:-}"

callsign_of() { vt_field "$1" callsign | tr '[:upper:]' '[:lower:]'; }

if [[ "$ARG" == "--status" ]]; then
  for r in $(vt_resources); do
    a=$(vt_stamp_age_hours "orient-$r")
    printf '%-28s %s\n' "$r" "$( (( a < 99999 )) && echo "oriented ${a}h ago" || echo 'NOT ORIENTED' )"
  done
  exit 0
fi

[[ -d "$PRODUCT" ]] || { vt_log "orient: product repo not found at $PRODUCT"; exit 1; }
vt_lock orient || exit 0
vt_brain_drain

for r in $(vt_resources); do
  if [[ -n "$ARG" ]]; then
    [[ "$ARG" != "$r" && "$ARG" != "$(callsign_of "$r")" ]] && continue
  else
    # Unattended: only the un-oriented. Orientation is one-time, not a beat.
    (( $(vt_stamp_age_hours "orient-$r") < 99999 )) && continue
  fi

  cs="$(callsign_of "$r")"; [[ -z "$cs" ]] && cs="$r"
  surfaces="$(awk "/^  - name: $r\$/,/^\$/" "$VT_ROOT/registry.yaml" \
              | sed -n '/^    surfaces:/,/^    [a-z_]*:/p' | grep -E '^      - ' | sed 's/^      - //' | tr '\n' ' ')"

  vt_log "orient: $r ($cs) — surfaces: ${surfaces:-none declared}"

  prompt=$(cat <<EOF
You are '$r' (callsign $cs) on the IndianVCs V-Team, doing your ONE-TIME
orientation before taking real work. You are a new hire reading before touching
anything.

Read, in this order:
1. $VT_ROOT/resources/$r.md          — your own definition
2. $VT_ROOT/docs/protocol.md          — the rules that bind every resource
3. $VT_ROOT/docs/difficulty.md        — where the gate is blind
4. $PRODUCT/CLAUDE.md                 — especially "Hard rules & gotchas"
5. $VT_ROOT/ledger/escapes/           — every escape recorded so far

YOUR DECLARED SURFACES: ${surfaces:-none declared — read broadly}

Produce orientation notes for YOURSELF. Not a summary of what you read —
notes you would want in front of you on your first task. Specifically:

- Which of the hard rules in that CLAUDE.md apply to YOUR surfaces, and what
  each one actually breaks when violated.
- Which recorded escapes touched your surfaces, and what would have caught
  each one earlier.
- Where the gate is blind on your surfaces — that is where your effort goes.
- Anything that contradicts your own definition. Say so plainly if you find it.

Write in the first person, terse, no preamble. Markdown body only, no
frontmatter, no code fence around the whole thing. Aim for under 400 words:
notes you will actually re-read, not a document you will skim.
EOF
)

  if [[ -n "${VT_DRY:-}" ]]; then
    printf '\n===== orient %s =====\n%s\n' "$r" "$prompt"; continue
  fi

  notes="$(printf '%s' "$prompt" | vt_model)" || { vt_log "orient: $r — model call failed"; continue; }
  [[ -z "${notes// }" ]] && { vt_log "orient: $r — empty response, stamp NOT advanced"; continue; }

  {
    echo '---'
    echo "title: Orientation notes — $cs"
    echo 'type: reference'
    echo 'tags: [v-team, orientation, first-person]'
    echo '---'
    echo
    echo "# Orientation notes — $cs"
    echo
    echo "_Written by $r on $(date -u '+%Y-%m-%d') from its own reading. First-person;"
    echo "this is memory, not law. Rules live in the repo._"
    echo
    printf '%s\n' "$notes"
  } | vt_brain_put "$cs" "orientation-notes" \
      && { vt_stamp_touch "orient-$r"; vt_journal "$r completed orientation"; vt_log "orient: $r — done"; } \
      || vt_log "orient: $r — spooled (brain locked), stamp NOT advanced"
done

exit 0
