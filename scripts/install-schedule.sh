#!/usr/bin/env bash
# Install (or remove) the V-Team launchd routines.
#
#   ./scripts/install-schedule.sh            # install + load
#   ./scripts/install-schedule.sh --uninstall
#   ./scripts/install-schedule.sh --status
#
# launchd rather than crontab on purpose: StartCalendarInterval runs a MISSED
# job once on wake, so closing the laptop delays the run instead of skipping
# it. Plain cron just loses it — which is exactly the gap the backfill mode
# then has to cover.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS="$HOME/Library/LaunchAgents"
LABELS=(so.indianvcs.vteam.beat so.indianvcs.vteam.weekly)

case "${1:-install}" in
  --status)
    for l in "${LABELS[@]}"; do
      printf '%-32s ' "$l"
      launchctl list | grep -q "$l" && echo loaded || echo 'not loaded'
    done
    echo; echo "stamps:"; ls -la "${VT_STATE:-$HOME/.v-team}/stamps" 2>/dev/null || echo '  none yet'
    exit 0 ;;
  --uninstall)
    for l in "${LABELS[@]}"; do
      launchctl bootout "gui/$(id -u)/$l" 2>/dev/null || true
      rm -f "$AGENTS/$l.plist"
      echo "removed $l"
    done
    exit 0 ;;
esac

mkdir -p "$AGENTS" "$HOME/.v-team/logs"

for l in "${LABELS[@]}"; do
  # Substitute the absolute repo path — launchd does not expand $HOME or ~.
  sed "s|__VT_ROOT__|$ROOT|g" "$ROOT/launchd/$l.plist" > "$AGENTS/$l.plist"
  launchctl bootout "gui/$(id -u)/$l" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$AGENTS/$l.plist"
  echo "installed $l"
done

echo
echo "beat:   every 6 hours (00:00 06:00 12:00 18:00), catch-up/backfill on a gap"
echo "weekly: Mondays 08:00"
echo
echo "logs:   ~/.v-team/logs/  ·  status: $0 --status"
echo "run once now:  $ROOT/scripts/beat.sh   (VT_DRY=1 to preview the prompts)"
