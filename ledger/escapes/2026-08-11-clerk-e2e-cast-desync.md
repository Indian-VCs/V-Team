---
date: 2026-08-11
found_by: CI
should_have_caught: gate
attribution: no-gate-coverage
---
## What failed
The Clerk e2e cast password desynced from `E2E_CLERK_PASSWORD`. Three separate
occurrences — this is a recurrence, not an incident.

## Why the prior stage missed it
Shared mutable external state with no reconciliation check. e2e is manual-dispatch,
so the desync is only discovered by a human choosing to run it.

## Strongest available prevention
1. **deterministic guard** — a preflight step in e2e that verifies one cast credential
   before the suite starts, failing in seconds instead of after a full run.

## Rule proposed
`e2e-preflight-verifies-cast` — state: candidate (3 distinct occurrences)
