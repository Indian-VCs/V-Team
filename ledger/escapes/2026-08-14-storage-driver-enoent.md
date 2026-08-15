---
date: 2026-08-14
found_by: production
should_have_caught: gate
attribution: no-gate-coverage
---
## What failed
`STORAGE_DRIVER=local` wrote to the filesystem; `/var/task` is read-only on Vercel.
Every upload in the page editor failed with `ENOENT ... mkdir '/var/task/.storage'`.

## Why the prior stage missed it
Nothing asserts that env configuration is *valid for the target runtime*. The
Supabase driver had already landed — it had simply never been switched on in
production. LAUNCH.md predicted this in prose; prose is not a gate.

## Strongest available prevention
1. **deterministic guard** — boot-time assertion: `STORAGE_DRIVER=local` must fail
   fast when the runtime filesystem is read-only.

## Rule proposed
`env-config-must-be-runtime-valid` — state: observed
