#!/usr/bin/env bash
# Track record — derived, never claimed.
#
#   ./scripts/record.sh            # recompute every resource's `record` page
#   ./scripts/record.sh heimdall   # one
#   ./scripts/record.sh --print    # to stdout, write nothing
#
# Every number here comes from ledger artifacts a resource CANNOT write about
# itself. No metric reads a resource's own account of how it did — that is the
# same rule the whole system runs on, applied to the resource's own file.
#
# This is what the MONTHLY report reads to propose autonomy changes. A week is
# noise for a trust decision; a month is roughly the right evidence window.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ONLY="${1:-}"; PRINT=""
[[ "$ONLY" == "--print" ]] && { PRINT=1; ONLY=""; }

callsign_of() { vt_field "$1" callsign | tr '[:upper:]' '[:lower:]'; }

for r in $(vt_resources); do
  [[ -n "$ONLY" && "$ONLY" != "$r" && "$ONLY" != "$(callsign_of "$r")" ]] && continue
  cs="$(callsign_of "$r")"; [[ -z "$cs" ]] && cs="$r"

  cd "$VT_ROOT"

  # --- learning ---------------------------------------------------------------
  # Every count below is only meaningful if there was anything to count. A `0`
  # from an empty or absent `ledger/learnings/` is indistinguishable from a
  # resource that proposed nothing, and the two are opposite facts. So the
  # corpus size is measured first, and when it is zero the whole block reads
  # `no data` -- the word `conv` has always used, not a second convention.
  corpus=$(ls ledger/learnings/*.md 2>/dev/null | wc -l | tr -d ' ')

  proposed=0; active=0; contested=0; retired=0; adopted=0
  if (( corpus > 0 )); then
    proposed=$(grep -l "^resource: $r\$" ledger/learnings/*.md 2>/dev/null | wc -l | tr -d ' ')
    if (( proposed > 0 )); then
      active=$(   grep -l "^resource: $r\$" ledger/learnings/*.md 2>/dev/null | xargs grep -l '^state:   active'    2>/dev/null | wc -l | tr -d ' ')
      contested=$(grep -l "^resource: $r\$" ledger/learnings/*.md 2>/dev/null | xargs grep -l '^state:   contested' 2>/dev/null | wc -l | tr -d ' ')
      retired=$(  grep -l "^resource: $r\$" ledger/learnings/*.md 2>/dev/null | xargs grep -l '^state:   retired'   2>/dev/null | wc -l | tr -d ' ')
    fi

    # Influence: learnings this resource authored that ANOTHER adopted. The
    # depth-to-breadth flow -- a junior teaching the architect -- made countable.
    adopted=$(grep -l "^resource: $r\$" ledger/learnings/*.md 2>/dev/null \
              | xargs grep -h '^shared_to:' 2>/dev/null | grep -cv '\[\]' || true)
    adopted=${adopted:-0}
  fi
  conv='no data'; (( proposed > 0 )) && conv="$(( active * 100 / proposed ))%"

  # With no corpus these are unmeasured, and the table must say so rather than
  # print a column of zeroes that reads like a record.
  l_proposed="$proposed"; l_active="$active"; l_contested="$contested"
  l_retired="$retired";   l_adopted="$adopted"; learning_note=''
  if (( corpus == 0 )); then
    l_proposed='no data'; l_active='no data'; l_contested='no data'
    l_retired='no data';  l_adopted='no data'
    learning_note='**Not measured.** `ledger/learnings/` holds no artifacts, so
nothing above was read. These cells are absent input, not a score of zero.'
  fi

  # --- run outcomes -----------------------------------------------------------
  # The guard was already here; its false branch was silent, which left the
  # table printing five zeroes for "the run graph does not exist". Say so.
  dispatched='no data'; complete='no data'; handed_back='no data'
  escalated='no data';  dropped='no data';  work_note=''
  if compgen -G "ledger/runs/*.jsonl" >/dev/null; then
    dispatched=0; complete=0; handed_back=0; escalated=0; dropped=0
    for st in dispatched complete handed-back escalated dropped; do
      c=$(cat ledger/runs/*.jsonl 2>/dev/null \
          | jq -r --arg r "$r" --arg s "$st" \
              'select(.responsible == $r and .state == $s) | .node' 2>/dev/null \
          | sort -u | wc -l | tr -d ' ')
      case "$st" in
        dispatched)  dispatched=$c ;;
        complete)    complete=$c ;;
        handed-back) handed_back=$c ;;
        escalated)   escalated=$c ;;
        dropped)     dropped=$c ;;
      esac
    done
  else
    work_note='**Not measured.** No `ledger/runs/*.jsonl` exists, so no run
outcome was read. These cells are absent input, not a clean sheet.'
  fi

  # --- escapes attributed to this resource -----------------------------------
  # `resource-error` only. A no-gate-coverage escape is not this resource's
  # record -- attributing system failures to a worker is the mistake that makes
  # most performance management useless.
  #
  # This is the number a promotion is argued from, so it is the one absence
  # must never be allowed to flatter. An empty or absent `ledger/escapes/`
  # would render "0 escape(s) attributed" -- a spotless record manufactured
  # out of nothing having been read.
  if compgen -G "ledger/escapes/*.md" >/dev/null; then
    own_errors=$(grep -l "^attribution: resource-error" ledger/escapes/*.md 2>/dev/null \
                 | xargs grep -l "^resource: $r\$" 2>/dev/null | wc -l | tr -d ' ')
    errors_line="**$own_errors** escape(s) attributed to \`resource-error\`."
  else
    errors_line='**Not measured.** `ledger/escapes/` holds no artifacts. This is
not a clean record, it is an unread one — do not argue a promotion from it.'
  fi

  altitude="$(vt_field "$r" altitude)"; autonomy="$(vt_field "$r" autonomy | sed 's/ *#.*//')"
  beat_age=$(vt_stamp_age_hours "beat-$r")
  last_beat="never"; (( beat_age < 99999 )) && last_beat="${beat_age}h ago"

  body=$(cat <<EOF
---
title: Record — $cs
type: reference
tags: [v-team, record, derived]
---

# Record — $cs (\`$r\`)

Generated $(date -u '+%Y-%m-%d'). **Derived from ledger artifacts. Nothing here
is self-reported**, and this page is overwritten on every recompute — do not
edit it by hand.

Altitude **$altitude** · autonomy **$autonomy** · last beat **$last_beat**

## Learning

| | |
|---|---|
| proposed | $l_proposed |
| reached \`active\` | $l_active |
| **conversion** | **$conv** |
| contested | $l_contested |
| retired | $l_retired |
| adopted by another resource | $l_adopted |

$learning_note

Conversion is the signal. Volume is context only — a resource measured on
volume produces volume, and \`active\` requires validation against the repo,
which no resource can grant itself.

## Work

| | |
|---|---|
| dispatched | $dispatched |
| complete | $complete |
| handed back | $handed_back |
| escalated | $escalated |
| **dropped** | **$dropped** |

$work_note

\`dropped\` means dispatched and never returned. It is the failure mode a run
graph exists to catch, and any non-zero value is a finding rather than a
statistic.

Hand-backs are **not** a negative. A resource handing back work above its tier
is the escalation rule working; a resource that never hands back is either
lucky or pushing through.

## Attributed errors

$errors_line

Escapes attributed to *no-gate-coverage*, *ambiguous-brief* or
*impossible-task* are deliberately excluded. Charging a worker for a system
failure is what makes most performance management useless.

## Reading this

With no history the honest answer is "no data", not a flattering zero. A month
is the shortest window in which any of this means anything; the weekly report
does not read this page.
EOF
)

  if [[ -n "$PRINT" ]]; then
    printf '%s\n\n' "$body"
  else
    printf '%s' "$body" | vt_brain_put "$cs" record \
      && echo "$cs — record written (conversion $conv, dispatched $dispatched)" \
      || echo "$cs — spooled (brain locked)"
  fi
done
