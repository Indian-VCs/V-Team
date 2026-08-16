#!/usr/bin/env bash
# Operational-state store — is a person running right now, and what did they
# produce. Jarvis's ruling, 2026-08-17: a lease plus a JSONL log, OUTSIDE git.
#
#   ./scripts/runs.sh start  <callsign> <run> <node> [flags...]  # claim + log 'dispatched'
#   ./scripts/runs.sh busy   <callsign>                          # exit 0 busy / 1 free
#   ./scripts/runs.sh finish <callsign> --state <S> [--result T] [--artifact T]
#   ./scripts/runs.sh reap   [<callsign> | --all]                # force-close stale leases
#   ./scripts/runs.sh status [--callsign C | --run R]            # read back
#
# start flags: --parent P --title T --responsible R --accountable A
#              --monitoring M --difficulty D --effort E --budget-unit U
#              --budget-limit N --surfaces a,b,c --blocked-on X --pid N
#
# ─── Why this exists ──────────────────────────────────────────────────────────
# `ledger/runs/*.jsonl` was deleted in #9 — CTO-ruled, and not undone here. What
# was never replaced: a record of work IN FLIGHT. Commit trailers (protocol §7)
# only see work that landed, so there has been no way to answer "is this person
# running right now", "what was dispatched and never came back", or "what did
# this dispatch produce". Four rules depend on this existing: one-live-agent,
# effort-from-difficulty, the brief's escalation target, and any Chief of Staff
# hire (ledger/gaps/2026-08-16-runs-deleted-guards-left-pointing.md and
# ledger/gaps/2026-08-17-second-implementer-blocked-on-migration.md, which cites
# the missing "surfaces"/dispatch-time data by name as the thing that would have
# settled its own open question).
#
# ─── Why OUTSIDE git ──────────────────────────────────────────────────────────
# The CTO ruled project-specific dispatch state does not belong in the repo —
# that is what #9 already established when it deleted ledger/runs/. The CODE
# lives here; the DATA lives under $HOME/.v-team/runs, a path this repo's
# working tree never contains, so nothing this script writes can be `git add`ed
# by accident.
#
# ─── Why a lease, separate from the log ───────────────────────────────────────
# The JSONL log is append-only history — "what happened", replayed end to end.
# The lease is the current-state pointer — "is CALLSIGN holding a run right
# now", answerable by reading ONE small file instead of replaying every log
# ever written for that callsign. `busy` never touches the log.
#
# ─── Why PID liveness, not a heartbeat ────────────────────────────────────────
# A dead PID is unambiguous and needs no cooperation from the dying process —
# it covers every death mode observed without requiring the dying process to
# check in on its way out (three "Connection closed mid-response", one 600s
# stall-watchdog kill — none of which get a chance to call `finish`).
#
# gbrain's own PGLite lock independently confirms the trade, the hard way: it
# refuses to reap a lock whose holder PID is alive, because reaping one
# previously let a second process open the same data directory and corrupt the
# catalog + pgvector state — "recoverable only by wipe+restore." FALSELY
# REAPING A LIVE HOLDER IS WORSE THAN TOLERATING A STALE ONE. That is also why
# the TTL below is generous rather than tight — do not tighten it because it
# looks slack; that slack is the point.
#
# ─── Why the TTL is 90 minutes against a 33-minute observed ceiling ──────────
# It is a backstop for the one thing PID-liveness alone cannot cover: a PID
# number reused by an unrelated process after the true holder exited without
# this script ever closing its lease. `reap` only fires on TTL when the PID
# check ALSO cannot vouch for the lease (see `stale_reason` below) — a
# genuinely long-running dispatch is never force-closed while its PID is
# provably alive, TTL or no TTL. ~2.7x the longest run seen is the margin
# Jarvis specified; it is not tuned per-callsign.
#
# ─── Why no daemon ─────────────────────────────────────────────────────────────
# Reaping is LAZY — it runs inline on every `start`/`busy`/`status` call, plus
# on demand via `reap`. Nothing here requires a background process. The
# alternative (cron/launchd sweeping this directory) is the exact failure mode
# already lived with on `gbrain serve`: a manually-started background process
# nobody remembers is running. `start` reaping ITS OWN callsign's stale lease
# before checking busy/free is what keeps a crashed dispatch from freezing the
# next one — self-healing on next use, not parked "busy" forever the way
# gbrain's own `waiting` jobs sat idle for nine days with nothing to reap them.
#
# Schema mirrors docs/dashboard.md's run-graph fields (run, node, parent,
# title, responsible, accountable, monitoring, difficulty, effort, state, at,
# budget, surfaces, blocked_on) plus pid/host, which that schema never needed
# because it was never used to answer "is this still running".

set -uo pipefail
VT_STATE="${VT_STATE:-$HOME/.v-team}"
VT_RUNS="$VT_STATE/runs"
VT_LEASES="$VT_RUNS/leases"
VT_LOG="$VT_RUNS/log"
VT_RUN_TTL_MINUTES="${VT_RUN_TTL_MINUTES:-90}"
mkdir -p "$VT_LEASES" "$VT_LOG"

# The PID tracked by default is whoever invoked this script (this shell's
# parent) — override with --pid when the process to track is not the caller
# itself (e.g. a spawned worker, or a demo simulating a dead holder).
VT_CALLER_PID="$PPID"

exec python3 - "$VT_LEASES" "$VT_LOG" "$VT_RUN_TTL_MINUTES" "$VT_CALLER_PID" "$@" <<'PY'
import sys, os, json, socket, time, glob
from datetime import datetime, timezone

LEASES, LOG, TTL_MIN, CALLER_PID = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
argv = sys.argv[5:]

def now_iso():
    return datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

def parse_iso(s):
    try:
        return datetime.strptime(s, '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=timezone.utc).timestamp()
    except Exception:
        return None

def lease_dir(callsign):
    return os.path.join(LEASES, callsign)

def lease_path(callsign):
    return os.path.join(lease_dir(callsign), 'lease.json')

def log_path(run):
    return os.path.join(LOG, f'{run}.jsonl')

def append_log(run, rec):
    with open(log_path(run), 'a') as fh:
        fh.write(json.dumps(rec, sort_keys=True) + '\n')

def pid_alive(pid):
    try:
        pid = int(pid)
    except (TypeError, ValueError):
        return False
    if pid <= 0:
        return False
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True  # exists, owned by someone else — treat as alive
    return True

def stale_reason(lease):
    """None if the lease is still good. Otherwise why it is being reaped.
    PID liveness is checked FIRST and is sufficient on its own — TTL is a
    backstop that only matters once the PID signal cannot vouch for the
    lease (dead, or too malformed to check)."""
    pid = lease.get('pid')
    if not pid_alive(pid):
        return 'dead-pid'
    started = parse_iso(lease.get('started_at', ''))
    if started is not None:
        age_s = time.time() - started
        if age_s > TTL_MIN * 60:
            return 'ttl-exceeded'
    return None

def reap_callsign(callsign, quiet=False):
    """Idempotent: safe to call on every access. Returns the reason reaped,
    or None if there was nothing to reap (no lease, or lease still good)."""
    p = lease_path(callsign)
    if not os.path.exists(p):
        return None
    try:
        with open(p) as fh:
            lease = json.load(fh)
    except (json.JSONDecodeError, OSError):
        lease = {}
    reason = stale_reason(lease) if lease else 'unreadable-lease'
    if reason is None:
        return None
    run = lease.get('run')
    if run:
        append_log(run, {
            'run': run, 'node': lease.get('node'), 'state': 'reaped',
            'at': now_iso(), 'reason': reason, 'pid': lease.get('pid'),
            'callsign': callsign, 'started_at': lease.get('started_at'),
        })
    try:
        os.remove(p)
        os.rmdir(lease_dir(callsign))
    except OSError:
        pass
    if not quiet:
        print(f"reap: {callsign} — closed stale lease (run={run} node={lease.get('node')} "
              f"pid={lease.get('pid')} reason={reason})", file=sys.stderr)
    return reason

def read_lease(callsign):
    reap_callsign(callsign, quiet=True)
    p = lease_path(callsign)
    if not os.path.exists(p):
        return None
    with open(p) as fh:
        return json.load(fh)

def flags(args):
    """--key value pairs -> dict; bare leading positionals returned separately."""
    out, pos, i = {}, [], 0
    while i < len(args):
        a = args[i]
        if a.startswith('--'):
            key = a[2:]
            val = args[i + 1] if i + 1 < len(args) else ''
            out[key] = val
            i += 2
        else:
            pos.append(a)
            i += 1
    return out, pos

def cmd_start(args):
    opts, pos = flags(args)
    if len(pos) < 3:
        print("usage: runs.sh start <callsign> <run> <node> [flags...]", file=sys.stderr)
        return 2
    callsign, run, node = pos[0], pos[1], pos[2]
    # Self-heal first: a crashed prior dispatch under this callsign must not
    # freeze the next one.
    reap_callsign(callsign, quiet=True)

    d = lease_dir(callsign)
    try:
        os.makedirs(d)  # atomic claim — fails if another live lease exists
    except FileExistsError:
        held = read_lease(callsign)  # re-check under lock; reap() above already ran once
        if held is not None:
            print(f"busy: {callsign} is already holding run={held.get('run')} "
                  f"node={held.get('node')} pid={held.get('pid')} "
                  f"since={held.get('started_at')}", file=sys.stderr)
            print(json.dumps(held))
            return 1
        # Lease vanished between the reap and the mkdir (raced with itself) —
        # one retry is enough; this is not a contended multi-writer path.
        try:
            os.makedirs(d)
        except FileExistsError:
            print(f"busy: {callsign} — lease contended, try again", file=sys.stderr)
            return 1

    pid = opts.get('pid', CALLER_PID)
    budget = None
    if 'budget-unit' in opts or 'budget-limit' in opts:
        budget = {'unit': opts.get('budget-unit'), 'limit': opts.get('budget-limit'), 'spent': 0}
    surfaces = [s for s in opts.get('surfaces', '').split(',') if s] or None
    lease = {
        'callsign': callsign, 'run': run, 'node': node,
        'pid': int(pid) if str(pid).isdigit() else pid,
        'host': socket.gethostname(),
        'started_at': now_iso(),
        'title': opts.get('title'),
        'parent': opts.get('parent'),
        'responsible': opts.get('responsible', callsign),
        'accountable': opts.get('accountable'),
        'monitoring': opts.get('monitoring'),
        'difficulty': opts.get('difficulty'),
        'effort': opts.get('effort'),
        'budget': budget,
        'surfaces': surfaces,
        'blocked_on': opts.get('blocked-on'),
    }
    with open(lease_path(callsign), 'w') as fh:
        json.dump(lease, fh, indent=2, sort_keys=True)
    append_log(run, {**lease, 'state': 'dispatched', 'at': lease['started_at']})
    print(json.dumps(lease))
    return 0

def cmd_busy(args):
    _, pos = flags(args)
    if not pos:
        print("usage: runs.sh busy <callsign>", file=sys.stderr)
        return 2
    lease = read_lease(pos[0])
    if lease is None:
        print(f"free: {pos[0]}")
        return 1
    print(json.dumps(lease))
    return 0

def cmd_finish(args):
    opts, pos = flags(args)
    if not pos or 'state' not in opts:
        print("usage: runs.sh finish <callsign> --state <S> [--result T] [--artifact T]", file=sys.stderr)
        return 2
    callsign = pos[0]
    lease = read_lease(callsign)
    if lease is None:
        print(f"finish: {callsign} holds no active lease — nothing to finish "
              f"(already reaped, or never started)", file=sys.stderr)
        return 1
    rec = {
        'run': lease.get('run'), 'node': lease.get('node'),
        'parent': lease.get('parent'), 'title': lease.get('title'),
        'responsible': lease.get('responsible'), 'accountable': lease.get('accountable'),
        'monitoring': lease.get('monitoring'), 'difficulty': lease.get('difficulty'),
        'effort': lease.get('effort'), 'budget': lease.get('budget'),
        'surfaces': lease.get('surfaces'),
        'state': opts['state'], 'terminal': opts['state'],
        'at': now_iso(), 'pid': lease.get('pid'), 'host': lease.get('host'),
        'result': opts.get('result'), 'artifact': opts.get('artifact'),
        'blocked_on': opts.get('blocked-on', lease.get('blocked_on') if opts['state'] == 'blocked' else None),
    }
    append_log(lease['run'], rec)
    try:
        os.remove(lease_path(callsign))
        os.rmdir(lease_dir(callsign))
    except OSError:
        pass
    print(json.dumps(rec))
    return 0

def cmd_reap(args):
    _, pos = flags(args)
    target = pos[0] if pos else '--all'
    if target == '--all':
        callsigns = sorted(os.path.basename(p) for p in glob.glob(os.path.join(LEASES, '*')) if os.path.isdir(p))
    else:
        callsigns = [target]
    reaped = 0
    for cs in callsigns:
        if reap_callsign(cs, quiet=False) is not None:
            reaped += 1
    if reaped == 0:
        print("reap: nothing to reap", file=sys.stderr)
    return 0

def cmd_status(args):
    opts, _ = flags(args)
    if 'run' in opts:
        p = log_path(opts['run'])
        if not os.path.exists(p):
            print(f"status: no log for run={opts['run']}", file=sys.stderr)
            return 1
        latest = {}
        with open(p) as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                rec = json.loads(line)
                latest[rec.get('node')] = rec
        for node, rec in latest.items():
            print(json.dumps(rec))
        return 0
    if 'callsign' in opts:
        lease = read_lease(opts['callsign'])
        print(json.dumps(lease) if lease else f"free: {opts['callsign']}")
        return 0 if lease else 1
    callsigns = sorted(os.path.basename(p) for p in glob.glob(os.path.join(LEASES, '*')) if os.path.isdir(p))
    live = []
    for cs in callsigns:
        lease = read_lease(cs)
        if lease:
            live.append(lease)
    if not live:
        print("status: nobody holding a lease right now")
        return 0
    for lease in live:
        print(json.dumps(lease))
    return 0

COMMANDS = {'start': cmd_start, 'busy': cmd_busy, 'finish': cmd_finish, 'reap': cmd_reap, 'status': cmd_status}

if not argv or argv[0] not in COMMANDS:
    print("usage: runs.sh <start|busy|finish|reap|status> ... — see the header "
          "comment in scripts/runs.sh for flags", file=sys.stderr)
    sys.exit(2)

sys.exit(COMMANDS[argv[0]](argv[1:]))
PY
