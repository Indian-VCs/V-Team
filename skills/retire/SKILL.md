---
name: retire
description: Remove a resource from the V-Team. Use when a resource has had no work for weeks, its capability was absorbed by a deterministic guard, or it duplicates another. Team size has a measured cost — retiring is maintenance, not failure.
---

# /retire — remove a resource

Microsoft's v-teams are **temporary** by construction: people are plucked out
of the org tree for a purpose and returned when it's served. Ours is permanent
by default, which is the wrong default — **multi-agent performance degrades as
team size grows**, so every resource that isn't earning its place is costing
something.

Retiring is routine maintenance. It is not a judgement about the resource.

## When to retire

| Trigger | Check |
|---|---|
| **No work** | zero dispatches in 4+ weeks — **currently unmeasurable, see below** |
| **Absorbed** | a lint rule, type or CI check now covers what it caught — the best possible outcome |
| **Duplicate** | its capabilities are a subset of another resource's |
| **Wrong split** | it keeps handing back because the role was mis-scoped, not because it performs badly |

That last one matters. **When a resource keeps failing, the answer is usually
to narrow or retire the role, not to add rules to it.** Most performance plans
fail because the problem was role fit; piling on instructions is the
prompt-engineering version of "try harder."

## When NOT to retire

- **It's a guard that hasn't fired.** For a guard, silence is success — not
  firing is evidence it is working. Check `docs/learning.md` before reading
  quiet as idle.
- **It's seasonal.** A migration reviewer with nothing to do between migrations
  is not idle, it's waiting.
- **It's the only cover for a capability.** Retiring re-opens the gap — that
  may be correct, but it must be deliberate. Move the capability to
  `known_gaps` in the same PR so `/assign` reports it honestly.

## Procedure

1. **The "no work" trigger is suspended. Do not retire on it.**

   It read `ledger/runs/`, which was deleted on 2026-08-16 when the track
   record became a projection over commit trailers
   (`ledger/gaps/2026-08-16-trailer-projection-has-no-substrate.md`). A read
   against the absent directory returns zero dispatches **for every resource**,
   so the trigger does not merely stop working — it fires *maximally and
   uniformly*, and every resource on the roster looks retirable. That is the
   silent-zero defect the same entry condemned in `record.sh:47`, landing in
   the one path whose output is deleting a resource.

   **`./scripts/record.sh <callsign>` is the nearest replacement and it is not
   a substitute.** It counts commits that landed, so it can show that a
   resource *did* work. It cannot show that a resource was *never dispatched*:
   hand-backs, escalations and dropped dispatches leave no commit, and
   `ledger/runs/` was the only thing that recorded them. Absence of commits is
   now consistent with "never asked" and with "asked repeatedly and handed back
   every time", which are opposite facts about whether to retire.

   So: retire on **Absorbed**, **Duplicate** or **Wrong split**, each of which
   is judged from artifacts that still exist. Retiring for idleness needs a
   dispatch record that currently has no substrate. If you believe a resource
   is idle, that is a `ledger/gaps/` entry, not a retirement.

2. Confirm no other resource depends on it as a `monitoring` party for
   in-flight work.
3. Delete `resources/<name>.md` and its `registry.yaml` entry.
4. **Move any capability it uniquely covered into `known_gaps`**, with a note
   saying it was retired rather than never staffed.
5. Keep its persona in `personas/` — retiring a resource should not lose the
   design work.
6. Open a PR. Retirement is a reviewable diff, like a hire.

## Re-hiring

A retired resource can be re-hired from its persona at any time. It returns at
**recommend-only** — its old record does not transfer, for the same reason a
changed resource re-enters probation. The file is not the worker; the evidence
is, and the evidence is stale.
