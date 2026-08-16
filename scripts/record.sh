#!/usr/bin/env bash
# Track record — derived, never claimed.
#
#   ./scripts/record.sh            # recompute every resource's `record` page
#   ./scripts/record.sh heimdall   # one
#   ./scripts/record.sh --print    # to stdout, write nothing
#
# Every number here comes from artifacts a resource CANNOT write about itself.
# No metric reads a resource's own account of how it did — that is the same
# rule the whole system runs on, applied to the resource's own file.
#
# This is what the MONTHLY report reads to propose autonomy changes. A week is
# noise for a trust decision; a month is roughly the right evidence window.
#
# ─── What this proves, and what it does not ──────────────────────────────────
#
# The work numbers are read from `Co-authored-by:` and `V-Team-Run:` trailers
# on commits reachable from the default branch of each repo (protocol §7). That
# makes them derived rather than self-reported, which is the property a
# promotion argument needs. It does NOT make them tamper-evident, and this
# script will not pretend otherwise.
#
# Neither branch is protected. Checked 2026-08-16: `Indian-VCs/V-Team@main`
# has `protected: false` and no rulesets; `Indian-VCs/prism-platform@master`
# CANNOT be protected today at all — it is a private repo under a personal
# account on a free plan, where GitHub offers neither protection nor rulesets.
# Six of eight resources hold `Bash`. Any one of them can rewrite this history
# with a single force-push, and nothing on the rendered page would look
# different afterwards.
#
# So, plainly:
#
#   PROVES      that a commit reachable from the default branch RIGHT NOW
#               carries this callsign and this run id, and that prism CI
#               (`attribution.yml`, enforcing since #82) rejected the
#               malformed ones. The resource did not write this sentence
#               about itself — it wrote a commit, and someone merged it.
#
#   DOES NOT    that the history was not rewritten to put a commit there, or
#   PROVE       to take one out. There is no append-only property in play.
#               A resource can, today, author its own track record.
#
# The guarantee is therefore TRUST-BASED. It is an honest shared account of
# what happened, not evidence you could hold up against a resource that
# disputes it. Do not cite this page as proof in a contested case.
#
# The exact condition that would make it one: branch protection enabled on
# `main` with force-push denied, and the same on `master` once that repo is
# public or on a plan that offers rulesets. Until BOTH are true, this caveat
# stays and this paragraph is the reason it is here.
# ─────────────────────────────────────────────────────────────────────────────

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ONLY="${1:-}"; PRINT=""
[[ "$ONLY" == "--print" ]] && { PRINT=1; ONLY=""; }

callsign_of() { vt_field "$1" callsign | tr '[:upper:]' '[:lower:]'; }

# --- trailer corpus ----------------------------------------------------------
# Read once, for every repo the team ships into: this one, plus each product
# named in registry.yaml resolved as a sibling checkout. A product that is not
# checked out here is NAMED as unread, never silently counted as zero — the
# same rule as every other absent input on this page.
TRAILERS="$(mktemp -t vt-trailers)"; trap 'rm -f "$TRAILERS"' EXIT
REPOS_READ=(); REPOS_UNREAD=()

_parent="$(dirname "$VT_ROOT")"
_products="$(grep -m1 '^  products: ' "$VT_ROOT/registry.yaml" \
             | sed 's/.*\[//; s/\].*//' | tr ',' ' ')"
for _dir in "$VT_ROOT" $(for _p in $_products; do echo "$_parent/$_p"; done); do
  _name="$(basename "$_dir")"
  # The default branch, from the remote's own HEAD — never assumed to be
  # `main`. It is `master` on prism-platform, and hardcoding either one would
  # silently read nothing.
  _ref="$(git -C "$_dir" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)"
  if [[ -z "$_ref" ]]; then REPOS_UNREAD+=("$_name"); continue; fi
  REPOS_READ+=("$_name")
  # --no-merges: a merge commit inherits nothing and would double-count.
  git -C "$_dir" log "$_ref" --no-merges \
    --format="$_name%x09%h%x09%cs%x09%(trailers:key=Co-authored-by,valueonly,separator=%x2C)%x09%(trailers:key=V-Team-Run,valueonly,separator=%x2C)" \
    >> "$TRAILERS" 2>/dev/null
done

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

  # --- work: what actually landed ---------------------------------------------
  # Projected from commit trailers, not from run files. A resource cannot write
  # a merged commit about itself without someone merging it, and prism CI has
  # rejected malformed attribution since #82.
  #
  # Absence rules exactly as elsewhere: a resource with no trailered commit
  # renders `no data`, never `0`. A clean sheet and an unread one are opposite
  # facts and must never render the same.
  landed='no data'; runs='no data'; untraceable='no data'
  first_seen='no data'; last_seen='no data'; repo_split=''; work_note=''

  _rows="$(awk -F'\t' -v cs="$cs" '
    {
      split($4, names, ",")
      for (i in names) {
        n = tolower(names[i]); gsub(/^[ \t]+|[ \t]+$/, "", n)
        if (index(n, cs " <") == 1) { print; next }
      }
    }' "$TRAILERS")"

  if [[ -n "$_rows" ]]; then
    landed=$(printf '%s\n' "$_rows" | wc -l | tr -d ' ')
    runs=$(printf '%s\n' "$_rows" | awk -F'\t' '$5 != "" {print $5}' | tr ',' '\n' \
           | sed 's/^ *//; s/ *$//' | grep . | sort -u | wc -l | tr -d ' ')
    untraceable=$(printf '%s\n' "$_rows" | awk -F'\t' '$5 == "" || $5 ~ /^[ \t]*$/' \
                  | wc -l | tr -d ' ')
    first_seen=$(printf '%s\n' "$_rows" | cut -f3 | sort | head -1)
    last_seen=$( printf '%s\n' "$_rows" | cut -f3 | sort | tail -1)
    # `bt` because a literal backtick inside $( ) opens a nested substitution.
    repo_split=$(printf '%s\n' "$_rows" | cut -f1 | sort | uniq -c \
                 | awk -v bt='`' '{printf "%s%s%s%s %s", (NR>1 ? " · " : ""), bt, $2, bt, $1}')
  else
    work_note='**Not measured.** No commit on any read default branch carries a
`Co-authored-by:` trailer for this callsign. This is absent input, not a record
of zero work — an unattributed commit is indistinguishable from a hand commit
by construction (protocol §7), so silence here means nothing was read.'
  fi

  repos_note="Read: $(printf '%s' "${REPOS_READ[*]:-none}" | tr ' ' ',' | sed 's/,/, /g')."
  if (( ${#REPOS_UNREAD[@]} > 0 )); then
    repos_note="$repos_note **Not read: $(printf '%s' "${REPOS_UNREAD[*]}" | tr ' ' ',' | sed 's/,/, /g')** —
no checkout found, so any work landed there is missing from these counts."
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

Generated $(date -u '+%Y-%m-%d'). **Derived from ledger artifacts and merged
commit trailers. Nothing here is self-reported**, and this page is overwritten
on every recompute — do not edit it by hand.

⚠ **Trusted, not verified.** Neither default branch denies force-push, so this
is an honest account, not tamper-evidence. Read the bottom of this page before
citing it.

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

Projected from \`Co-authored-by:\` / \`V-Team-Run:\` trailers on non-merge
commits reachable from the default branch of each repo (protocol §7).

| | |
|---|---|
| commits landed | $landed |
| distinct runs | $runs |
| **untraceable** (no \`V-Team-Run:\`) | **$untraceable** |
| first landed | $first_seen |
| most recent | $last_seen |
| by repo | ${repo_split:-no data} |

$repos_note

$work_note

\`untraceable\` is the finding, not the volume. A commit carrying a callsign
but no run id cannot be joined back to the dispatch that asked for it, so it
credits a resource for work nobody can trace to a brief. Any non-zero value is
a defect in the commit, not a compliment to the resource.

**What this projection cannot see, and does not count against anyone:**

- **Hand-backs.** A run handed back correctly often lands no commit at all, so
  it is invisible here. That is not a gap being papered over — hand-backs are
  **not** a negative. A resource handing back work above its tier is the
  escalation rule working; one that never hands back is either lucky or
  pushing through. Nothing in this table should be read as rewarding a
  resource for pushing through.
- **Dropped runs** — dispatched and never returned. Git cannot show the
  absence of a commit that was never asked for versus one that was. This was
  the one thing the run-file graph could catch that trailers cannot, and it is
  a real loss; see \`docs/memory.md\`.
- **Work by a resource that omitted its trailer.** Indistinguishable from a
  CTO hand commit by construction (protocol §7). Silence is never evidence.

## Attributed errors

$errors_line

Escapes attributed to *no-gate-coverage*, *ambiguous-brief* or
*impossible-task* are deliberately excluded. Charging a worker for a system
failure is what makes most performance management useless.

## Reading this

With no history the honest answer is "no data", not a flattering zero. A month
is the shortest window in which any of this means anything; the weekly report
does not read this page.

**This record is trusted, not verified.** The Work numbers come from commit
trailers on branches that are **not protected** — \`main\` is unprotected and
\`master\` cannot be protected while prism-platform is a private repo on a free
personal plan. A force-push rewrites the inputs to this page and leaves no trace in
it. So: cite it as a shared account of what happened, never as proof
against a resource that disputes it. It becomes proof when force-push is
denied on both default branches, and not before.
EOF
)

  if [[ -n "$PRINT" ]]; then
    printf '%s\n\n' "$body"
  else
    printf '%s' "$body" | vt_brain_put "$cs" record \
      && echo "$cs — record written (conversion $conv, commits landed $landed)" \
      || echo "$cs — spooled (brain locked)"
  fi
done
