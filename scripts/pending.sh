#!/usr/bin/env bash
# What is waiting on the router. Derived from ledger/runs/, never claimed.
#
#   ./scripts/pending.sh           # human-readable; exits 1 if anything waits
#   ./scripts/pending.sh --quiet   # exit status only
#
# The CTO, 2026-08-16: "why was it not completed till I asked?" and "what are
# you waiting for, run ci locally, raise pr and merge, why do I have to
# babysit?"
#
# Six of eight resources are recommend-only. They end `complete` and their
# output goes nowhere unless something picks it up. Until now the only thing
# that noticed an unadvanced deliverable was the CTO reading a report and
# asking. That is the babysitting. This script is the thing that notices.
#
# It answers exactly one question — WHAT IS WAITING — and it never answers WHO
# SHOULD TAKE IT. That second question is `skills/assign`, it is judgement, and
# a script that guessed at it would be a router with no accountability. See
# ledger/gaps/2026-08-16-finished-work-does-not-advance.md for why this is a
# guard and not a hire.
#
# THE TERMINAL STATE ALREADY SAYS WHETHER ANYTHING IS OWED. protocol §1:
# `complete` means the done-condition was met and nothing is outstanding;
# `handed-back` means partial work "with what remains"; `escalated` means a
# question someone else must answer. So the first two terminal states are
# unfinished BY DEFINITION, and a leaf in those states is a dropped handoff.
# That is the whole rule, and it is why this does not need a heuristic about
# what "looks" important. A first cut flagged every childless terminal node and
# reported 14 — most of them runs that had legitimately ended. Sharpening it to
# the two states that mean "someone else must act" cut it to the real ones.
#
#   DROPPED HANDOFF           terminal `escalated` or `handed-back`, no child.
#                             Someone owes an answer and nobody was asked. FAILS.
#   DISPATCHED, NEVER CLOSED  dispatched with no later record. Still running or
#                             silently dropped, and the ledger cannot tell you
#                             which — which is itself the finding. FAILS.
#   COMPLETE, NOTHING AFTER   terminal `complete`, no child, and not the last
#                             node of its run. Usually fine — a finished branch.
#                             Reported so a human can glance, never failed on.
#   BLOCKED                   blocked_on set. Waiting correctly. Never fails.
#
# THE "no child" PROXY IS IMPERFECT AND HERE IS HOW. It asks whether any node
# names this one as its `parent`. When the router records a follow-up as a
# SIBLING (parent = the run root) instead of a child, a real handoff looks
# dropped. That is exactly what `2026-08-16-admin-sidebar-affordance` L0.1 does:
# it escalated to architect, architect's answer is L0.2, and L0.2's parent is
# L0. The edge happened; the graph does not record it. Reporting that as a
# finding is correct — an unrecorded edge cannot be audited later, which is the
# entire reason protocol §7 requires the run file.
#
# WHAT THIS CANNOT SEE, stated so nobody mistakes green for proof: work that
# was never written to ledger/runs/ at all. On 2026-08-16 the router dispatched
# Bagheera, received a build-ready design, and wrote no run file — so this
# check would have been VACUOUSLY GREEN on the very incident that prompted it.
# The run file is written by the router about itself, which is the one
# attribution shape protocol §7 says cannot be trusted. Closing that needs
# `record.sh` reconciling run files against commits that actually landed. Until
# then: this is reliable about work that was recorded, and silent about work
# that was not.

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUIET=""; [[ "${1:-}" == "--quiet" ]] && QUIET=1

python3 - "$ROOT" "${QUIET:-}" <<'PY'
import json, os, sys, glob

root, quiet = sys.argv[1], bool(sys.argv[2])
files = sorted(glob.glob(os.path.join(root, "ledger", "runs", "*.jsonl")))

latest, order, children, runs = {}, [], set(), set()
for path in files:
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                print(f"::error::{os.path.basename(path)}: unparseable line — the run graph is the only record the worker cannot author, so a broken line is a lost edge")
                continue
            run, node = rec.get("run"), rec.get("node")
            if not run or not node:
                continue
            key = (run, node)
            # Append-only: the last record for a node is its current state.
            if key not in latest:
                order.append(key)
            latest[key] = rec
            runs.add(run)
            if rec.get("parent"):
                children.add((run, rec["parent"]))

# The last node recorded in a run: a `complete` leaf there is a run that ended,
# not a deliverable that was dropped.
last_of_run = {}
for run, node in order:
    last_of_run[run] = (run, node)

dropped, dispatched, finished, blocked = [], [], [], []
for key in order:
    rec = latest[key]
    run, node = key
    state = rec.get("state")
    # Run roots are the CTO's own framing of the work, not dispatched units.
    if rec.get("parent") is None and state == "open":
        continue
    if rec.get("blocked_on"):
        blocked.append((run, node, rec))
        continue
    if state == "dispatched":
        dispatched.append((run, node, rec))
        continue
    if state not in ("returned", "handed-back") or key in children:
        continue
    # Terminal state carries the verdict; fall back to `state` when the router
    # recorded no `terminal` field, which older run files do.
    term = rec.get("terminal") or (state if state == "handed-back" else None)
    if term in ("escalated", "handed-back"):
        dropped.append((run, node, rec))
    elif last_of_run.get(run) != key:
        finished.append((run, node, rec))

def show(title, rows, why):
    if not rows:
        return
    print(f"\n  {title}  ({len(rows)})")
    print(f"  {why}")
    for run, node, rec in rows:
        who = rec.get("responsible", "?")
        art = rec.get("artifact")
        term = rec.get("terminal")
        tail = "".join([
            f"  [{term}]" if term else "",
            f"  artifact: {art}" if art else "",
            f"  blocked_on: {rec['blocked_on']}" if rec.get("blocked_on") else "",
        ])
        print(f"    {run}  {node}  {who}{tail}")
        print(f"      {rec.get('title','')}")

if not quiet:
    print(f"pending: {len(files)} run file(s), {len(runs)} run(s), {len(latest)} node(s)")
    show("DROPPED HANDOFF", dropped,
         "ended `escalated` or `handed-back` with no child. Someone owes an answer and nobody was asked.")
    show("DISPATCHED, NEVER CLOSED", dispatched,
         "no later record. Still running, or silently dropped — the ledger cannot tell you which.")
    show("COMPLETE, NOTHING AFTER", finished,
         "finished branches with no successor. Usually correct; glance, do not act.")
    show("BLOCKED", blocked,
         "waiting on a named thing. Reported, not failed on.")
    if not (dropped or dispatched):
        print("\n  nothing waiting on the router.")
    print()

sys.exit(1 if (dropped or dispatched) else 0)
PY
