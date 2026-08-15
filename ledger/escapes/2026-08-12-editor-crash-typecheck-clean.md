---
date: 2026-08-12
found_by: production
should_have_caught: gate
attribution: no-gate-coverage
---
## What failed
An editor crash shipped with typecheck, lint and units all green.

## Why the prior stage missed it
A server page passing a function (`rowKey`, column `render`) to a client design-system
component fails at render, not at compile. CLAUDE.md states this explicitly:
"Typecheck does NOT catch this; it fails at render." A known blind spot with no guard.

## Strongest available prevention
1. **deterministic guard** — an ESLint rule forbidding function props crossing the
   RSC boundary into `.pr-*` client components. This class is enumerable, so it is
   lintable, and a lint rule would retire the prompt rule entirely.

## Rule proposed
`no-function-props-across-rsc-boundary` — state: observed
