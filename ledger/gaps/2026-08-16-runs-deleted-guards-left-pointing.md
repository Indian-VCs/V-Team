---
date: 2026-08-16
requested_by: router
capability: record.dispatch-substrate
product: v-team (this repo)
status: open
verdict: reconciled where possible, recorded where not — no hire, no undo
decided_by: roster-steward (Anubis)
---

## What happened

PR #9 deleted `ledger/runs/*.jsonl` and replaced the track record with a
projection over `Co-authored-by:` / `V-Team-Run:` trailers. **That was correct,
CTO-ruled, and is not undone here.** It states its own cost plainly and the
files survive in git at `8f2fe26`.

Three things that read `ledger/runs/` were left pointing at a directory with no
contents. Two of them fail *silently and flatteringly*, which is the specific
defect PR #9's own entry condemned in `record.sh:47`.

## 1. `docs/protocol.md` §7 — pointed at the fix it can no longer have

§7's closing paragraph is the honest one: *"What this cannot enforce, stated so
nobody mistakes green for proof."* It named the closure — `record.sh`
reconciling `ledger/runs/`, written by the router, against the commits a
dispatch landed.

**That reconciliation is no longer possible, and the hole got wider, not
narrower.**

- **Before:** two independent records of one dispatch — run files the worker
  could not author, and commits the worker wrote. A commit missing its trailer
  had something to be missing *from*.
- **After:** one record, the commits, which is the thing being checked. The
  projection derives the record *from* the trailers, so an untrailered commit
  is not merely unattributed — it is **absent from the record entirely**, and
  nothing remains that could notice the absence.

§7 now says this. It was not laundered into a pointer swap, because the
paragraph's whole value is that it admits what it cannot do. A protocol that
quietly stops admitting its own hole is worse than one with a hole.

Also fixed: the earlier line describing `V-Team-Run` as joining a commit to *"a
`ledger/runs/` file the worker does not write"*. It is now a grouping key with
nothing on the other side of the join.

## 2. `skills/retire` — a silent zero that deletes resources

The **No work** trigger read `ledger/runs/` for *"zero dispatches in 4+ weeks."*
Against the absent directory that is true **for every resource simultaneously**,
so the trigger does not stop working — it **fires maximally and uniformly, and
the entire roster looks retirable.**

This is the `record.sh:47` defect landing in the one path whose output is
deleting a resource. **Trigger suspended**, with the reason written where a
future reader will hit it.

`record.sh <callsign>` is the nearest thing and is explicitly *not* a
substitute: it counts commits that landed, so it can show a resource *did*
work. It cannot show a resource was *never dispatched*, because hand-backs,
escalations and dropped dispatches leave no commit. Absence of commits is now
consistent with *"never asked"* and with *"asked repeatedly and handed back
every time"* — opposite facts about whether to retire.

Retirement still works on **Absorbed**, **Duplicate** and **Wrong split**, all
judged from artifacts that still exist.

## 3. `scripts/pending.sh` — my own defect, shipped the same day

PR #12 introduced `pending.sh`, whose entire job is noticing work that went
unnoticed. It globs `ledger/runs/*.jsonl`. Verified against an empty tree:

```
pending: 0 run file(s), 0 run(s), 0 node(s)
  nothing waiting on the router.
exit=0
```

**A flattering number manufactured from missing input** — the exact defect PR #9
condemned, shipped by me, on the same day, in a check built to catch this class
of thing. Recorded plainly because I am the resource that is supposed to catch
it, and my own definition forbids treating my output as exempt.

Fixed: absent substrate now exits **3**, distinct from 0 (clean) and 1 (work
waiting), and prints what it cannot see. `skills/assign` §8 requires the router
to report the unmeasurability in place of the check.

**The trailers cannot repair this input.** `pending.sh` fails on dropped
handoffs and unclosed dispatches; both are defined by the *absence* of a
completed artifact, so a projection over landed commits has nothing to see. This
check is dormant until dispatches are recorded again.

## Compounding, stated once

`pending.sh` already disclosed one limitation in PR #12: the incident that
prompted it left no run file, so it would have been vacuously green on it. That
was about **one unrecorded run**. This is about **every run**. The two are the
same defect at different scales, and the second subsumes the first.

## Verdict

**No hire, no undo.** The deletion was ruled and is correct. What was owed was
reconciliation of everything that pointed at the deleted substrate, and an
honest statement where reconciliation is impossible. Both are done.

**Still open, and above my altitude to resolve alone:** the team now has *no
record of work that produces no commit*. Hand-backs, escalations, dropped
dispatches and blocked nodes are invisible, permanently, unless something is
built to record them. That is a real loss of evidence for exactly the decisions
I am supposed to make from evidence — promotion, demotion and retirement all
read dispatch history. I am not proposing a resource for it; I am recording that
the input is gone so the next promotion argument cannot quietly pretend
otherwise.

## What I did NOT verify

- **The projection's output.** I did not run `record.sh` against either repo or
  check the numbers it produces; PR #9 reports `implementer`: 3 commits, 2 runs,
  1 untraceable, and I took that as given.
- **`docs/dashboard.md`**, which documents the JSONL schema, and `README.md`
  line 212 and `docs/delegation.md` line 126, which still describe
  `ledger/runs/` as live. They are descriptions of a dispatch practice rather
  than guards that fire, so they are stale prose and not silent failures. Left
  for whoever owns the dashboard; named here so it is not lost.
