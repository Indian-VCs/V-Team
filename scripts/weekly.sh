#!/usr/bin/env bash
# Weekly calibration + CTO report. Fires Monday 08:00 via launchd.
#
# Metrics are gathered deterministically from git and GitHub Actions — no model
# is involved in producing a number. The model is optional and only writes the
# narrative "Improve" section; if it is unavailable the report still lands,
# metrics intact.
#
#   ./scripts/weekly.sh [product-repo]   # default ../prism-platform

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

PRODUCT="${1:-$VT_ROOT/../prism-platform}"
SINCE="$(date -u -v-7d '+%Y-%m-%d')"
WEEK="$(date -u '+%Y-W%V')"
OUT="$VT_ROOT/ledger/reports/$WEEK.md"

vt_lock weekly || exit 0
vt_log "weekly: window $SINCE -> $(date -u '+%Y-%m-%d'), product=$PRODUCT"

# --- delivery ----------------------------------------------------------------
cd "$PRODUCT" 2>/dev/null || { vt_log "weekly: $PRODUCT not found"; exit 1; }
commits=$(git log --since="$SINCE" --oneline 2>/dev/null | wc -l | tr -d ' ')
feats=$(  git log --since="$SINCE" --oneline --grep='^feat' -i 2>/dev/null | wc -l | tr -d ' ')
fixes=$(  git log --since="$SINCE" --oneline --grep='^fix'  -i 2>/dev/null | wc -l | tr -d ' ')
reverts=$(git log --since="$SINCE" --oneline --grep='^Revert "' 2>/dev/null | wc -l | tr -d ' ')
merged=$( gh pr list --state merged --limit 200 --json mergedAt \
          --jq "[.[] | select(.mergedAt > \"$SINCE\")] | length" 2>/dev/null || echo '?')

ci=$(gh run list --workflow=ci.yml --limit 200 --json conclusion,createdAt \
     --jq "[.[] | select(.createdAt > \"$SINCE\")] | group_by(.conclusion)
           | map({(.[0].conclusion // \"null\"): length}) | add" 2>/dev/null || echo '{}')
e2e=$(gh run list --workflow=e2e.yml --limit 100 --json conclusion,createdAt \
     --jq "[.[] | select(.createdAt > \"$SINCE\")] | group_by(.conclusion)
           | map({(.[0].conclusion // \"null\"): length}) | add" 2>/dev/null || echo '{}')

# --- V-Team ------------------------------------------------------------------
cd "$VT_ROOT"
gaps=$(   ls ledger/gaps/*.md 2>/dev/null | wc -l | tr -d ' ')
escapes=$(find ledger/escapes -name '*.md' -newermt "$SINCE" 2>/dev/null | wc -l | tr -d ' ')

# `proposed` is the corpus, so it doubles as the input check. With no corpus
# these globs matched nothing and every count is `0` for the same reason the
# report exists to avoid: nothing was read. Three states, kept distinct —
# `no data` (nothing to read), `none` (read, no events this week, per the
# standing "never render this week: 0" rule), or the number.
proposed=$(ls ledger/learnings/*.md 2>/dev/null | wc -l | tr -d ' ')
if (( proposed > 0 )); then
  learned=$(find ledger/learnings -name '*.md' -newermt "$SINCE" 2>/dev/null | wc -l | tr -d ' ')
  active=$( grep -l '^state:   active'  ledger/learnings/*.md 2>/dev/null | wc -l | tr -d ' ')
  shares=$( grep -h '^shared_to:' ledger/learnings/*.md 2>/dev/null | grep -v '\[\]' | wc -l | tr -d ' ')
  conv="$(( active * 100 / proposed ))%"
  (( learned == 0 )) && learned='none'
  (( shares  == 0 )) && shares='none'
  learning_line="- learned this week: $learned · total proposed: $proposed · reached active: $active"
  shares_line="- cross-resource shares: $shares · open gaps: $gaps"
else
  conv='no data'
  learning_line='- **no data** — `ledger/learnings/` holds no artifacts; learning was not measured this week, which is not the same as nothing being learned'
  shares_line="- cross-resource shares: no data · open gaps: $gaps"
fi

# --- liveness: the reason this section exists is the gbrain sync that had
#     never once succeeded while appearing healthy ------------------------------
liveness=""
for r in $(vt_resources); do
  [[ -z "$(vt_field "$r" beat)" ]] && continue
  h=$(vt_stamp_age_hours "beat-$r")
  if   (( h >= 99999 )); then liveness+="  - **$r — NEVER RUN**, no beat has ever succeeded"$'\n'
  elif (( h > 144 )); then liveness+="  - **$r — NOT MEASURED**, no successful beat in $(( h / 24 ))d"$'\n'
  elif (( h > 48  )); then liveness+="  - $r — last beat ${h}h ago"$'\n'
  fi
done
[[ -z "$liveness" ]] && liveness="  - all beats current"$'\n'

# --- dormant vs not measured -------------------------------------------------
dormant=""; unmeasured=""
for repo in vc-stack VC-Hub rating-vcs prism HotTakes; do
  p="$VT_ROOT/../$repo"; [[ -d "$p/.git" ]] || continue
  c=$(git -C "$p" log --since="$SINCE" --oneline 2>/dev/null | wc -l | tr -d ' ')
  if (( c == 0 )); then dormant+="$repo "; else unmeasured+="$repo ($c commits) "; fi
done

{
  echo "# IndianVCs V-Team · week $WEEK"
  echo
  echo "Window $SINCE → $(date -u '+%Y-%m-%d'). Baseline: \`ledger/reports/monthly/BASELINE.md\`."
  echo
  echo '## Went well'
  echo "- $merged PRs merged, $commits commits ($feats feat / $fixes fix)"
  echo "- CI: \`$ci\` _(gh run list caps at 200; treat as a floor when activity is high)_"
  echo
  echo '## Went wrong'
  echo "- reverts: $reverts · escapes recorded: $escapes"
  echo "- e2e: \`$e2e\`"
  echo '- _attribution required per escape: resource-error | ambiguous-brief | no-gate-coverage | impossible-task_'
  echo
  echo '## Not measured'
  [[ -n "$unmeasured" ]] && echo "- **active, no gate:** $unmeasured" || echo '- none active without a gate'
  [[ -n "$dormant" ]]    && echo "- dormant (0 commits, no alarm): $dormant"
  echo '- e2e — manual dispatch only, not in the green bar'
  echo
  echo '## Learning'
  echo "$learning_line"
  echo "- **conversion: $conv** — the signal. Volume is context only."
  echo "$shares_line"
  echo
  echo '## Liveness'
  printf '%s' "$liveness"
  echo
  echo '## Waiting on you'
  echo '- _autonomy changes belong to the monthly report, not here_'
} > "$OUT"

# --- optional narrative ------------------------------------------------------
if [[ -z "${VT_NO_MODEL:-}" ]]; then
  narrative=$(printf 'Read %s and docs/weekly-report.md. Write ONLY the "Improve" section: at most 4 bullets, each naming a concrete obstacle or rule-state change with its evidence. No praise, no summary, no restating numbers already in the report. If there is nothing worth raising, output exactly: - nothing this week\n' "$OUT" | vt_model) \
    && { printf '\n## Improve\n\n%s\n' "$narrative" >> "$OUT"; } \
    || vt_log 'weekly: narrative skipped (model unavailable) — metrics intact'
fi

vt_journal "weekly report written: $OUT"
vt_stamp_touch weekly
vt_log "weekly: wrote $OUT"
echo "$OUT"
