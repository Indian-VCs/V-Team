---
date: 2026-08-11
found_by: CI
should_have_caught: gate
attribution: no-gate-coverage
---
## What failed
A Turbopack/font interaction took e2e down; the fallback was to webpack.

## Why the prior stage missed it
e2e is outside the green bar, so a break there blocks nothing and is found late.
The bundler path used by e2e differs from the one the gate exercises.

## Strongest available prevention
3. **test case** — a smoke check that the dev server renders a styled page under the
   same bundler e2e uses. Cheap, and it moves this class into the fast gate.

## Rule proposed
`e2e-bundler-parity-smoke` — state: observed
