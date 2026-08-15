#!/usr/bin/env bash
# The beat runner. Fires every 6 hours via launchd.
#
# Reads each resource's beat, writes at most `cap` learnings per resource per
# day into ledger/learnings/, and NEVER touches a rule file. Web findings enter
# at state `observed` — outside evidence and inside evidence are not the same
# currency, and only inside evidence promotes. See docs/learning.md.
#
#   ./scripts/beat.sh              # all resources
#   ./scripts/beat.sh architect    # one
#   VT_DRY=1 ./scripts/beat.sh     # print the prompt, call nothing

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

CAP="${VT_CAP:-5}"
TODAY="$(date -u '+%Y-%m-%d')"
ONLY="${1:-}"

vt_lock beat || exit 0
vt_brain_drain          # retry anything a locked brain refused last window

wrote_any=0
for r in $(vt_resources); do
  [[ -n "$ONLY" && "$ONLY" != "$r" ]] && continue

  beat="$(vt_field "$r" beat)"
  [[ -z "$beat" || "$beat" == "null" ]] && continue

  # Budget is per DAY and shared across the day's four windows. Once spent,
  # the remaining windows are genuine no-ops — that is what makes a 6-hour
  # cadence affordable rather than 4x the cost.
  today_count=$(find "$VT_ROOT/ledger/learnings" -name "$TODAY-*" 2>/dev/null \
                | xargs grep -l "^resource: $r\$" 2>/dev/null | wc -l | tr -d ' ')
  remaining=$(( CAP - today_count ))
  if (( remaining <= 0 )); then
    vt_log "$r: cap reached for $TODAY — no-op"
    continue
  fi

  age=$(vt_stamp_age_hours "beat-$r")
  mode=$(vt_mode "$age")
  case "$mode" in
    normal)     window="the last 24 hours" ;;
    catch-up)   window="the last $(( age / 24 + 1 )) days" ;;
    backfill)   d=$(( age / 24 )); (( d > VT_BACKFILL_MAX_DAYS )) && d=$VT_BACKFILL_MAX_DAYS
                window="the last $d days" ;;
    cold-start) window="the last $VT_BACKFILL_MAX_DAYS days — this is your FIRST run, so
establish a starting picture of your beat rather than chasing news" ;;
  esac

  prompt=$(cat <<EOF
You are the '$r' resource on the IndianVCs V-Team, doing your scheduled
learning run. Read docs/learning.md and resources/$r.md in $VT_ROOT first.

YOUR BEAT: $beat
MODE: $mode — cover $window.
BUDGET: at most $remaining item(s). Fewer is better. ZERO IS A VALID ANSWER
and is the correct answer when nothing meaningful was published.

Rules that bind you:
- Never invent an item to fill the budget. A manufactured finding becomes
  permanent context tax on a false premise.
- In catch-up or backfill mode the budget is for the WHOLE window, not per
  missed day. Rank across the entire period and return only the best.
- Only report something that would plausibly change how work is done on
  prism-platform. Novelty alone is not relevance.
- Every item needs a real, resolvable source URL. No source, no item.

Return ONLY minified JSON, no prose, no code fence:
{"learnings":[{"slug":"kebab-case-3-5-words","topic":"...","domain":"...",
"source_title":"...","source_url":"https://...","source_kind":"paper|release-notes|vendor-doc|incident|repo",
"summary":"One paragraph: what was learned, and what it would change here."}]}

Return {"learnings":[]} if there is nothing worth recording.
EOF
)

  if [[ -n "${VT_DRY:-}" ]]; then
    printf '\n===== %s (%s, budget %s) =====\n%s\n' "$r" "$mode" "$remaining" "$prompt"
    continue
  fi

  vt_log "$r: mode=$mode age=${age}h budget=$remaining"
  out="$(printf '%s' "$prompt" | vt_model)" || { vt_log "$r: model call failed"; continue; }

  json="$(printf '%s' "$out" | tr -d '\000' | grep -o '{.*}' | head -1)"
  if ! printf '%s' "$json" | jq -e '.learnings' >/dev/null 2>&1; then
    vt_log "$r: unparseable output — skipped, stamp NOT advanced"
    continue
  fi

  n=$(printf '%s' "$json" | jq '.learnings | length')
  for i in $(seq 0 $(( n - 1 )) ); do
    [[ "$n" -eq 0 ]] && break
    item=$(printf '%s' "$json" | jq -c ".learnings[$i]")
    slug=$(printf '%s' "$item" | jq -r '.slug' | tr -cd 'a-z0-9-')
    f="$VT_ROOT/ledger/learnings/$TODAY-$slug.md"
    [[ -e "$f" ]] && { vt_log "$r: $slug already recorded — skipped"; continue; }
    {
      echo '---'
      echo "id:       $TODAY-$slug"
      echo "date:     $TODAY"
      echo "resource: $r"
      printf 'topic:    %s\n'  "$(printf '%s' "$item" | jq -r '.topic')"
      printf 'domain:   %s\n'  "$(printf '%s' "$item" | jq -r '.domain')"
      echo 'source:'
      printf '  title: "%s"\n' "$(printf '%s' "$item" | jq -r '.source_title')"
      printf '  url:   %s\n'   "$(printf '%s' "$item" | jq -r '.source_url')"
      printf '  kind:  %s\n'   "$(printf '%s' "$item" | jq -r '.source_kind')"
      echo 'state:   observed'
      echo 'validated_against: null'
      echo 'shared_to: []'
      echo '---'
      echo
      printf '%s\n' "$(printf '%s' "$item" | jq -r '.summary')"
    } > "$f"
    vt_journal "$r learned \`$slug\` ($(printf '%s' "$item" | jq -r '.domain')) — state: observed"
    wrote_any=1
  done

  vt_log "$r: wrote $n item(s)"
  vt_stamp_touch "beat-$r"        # only on a clean run — failures retry next window
done

(( wrote_any == 0 )) && vt_journal "beat ran, nothing new (a valid day)"
vt_stamp_touch beat-any
exit 0
