---
date: 2026-08-12
found_by: review
should_have_caught: dispatch
attribution: no-gate-coverage
---
## What failed
An agent branched off a shared dirty tree and swept another agent's commits into
its PR.

## Why the prior stage missed it
Concurrent writers in one checkout with no lock. Nothing recorded who held the
commit lock, because nothing recorded the run graph at all.

## Strongest available prevention
1. **deterministic guard** — only one resource commits at a time, enforced by a lock
   at the dispatch layer and made visible via `blocked_on` in `ledger/runs/`.
   This is a shared-exclusive-resource collision: ordering cannot solve it.

## Rule proposed
`one-committer-at-a-time` — state: active (guard; silence is success)
