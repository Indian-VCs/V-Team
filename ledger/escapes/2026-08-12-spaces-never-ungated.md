---
date: 2026-08-12
found_by: an agent, mid-task
should_have_caught: brief
attribution: ambiguous-brief
---
## What failed
`spaces` had never actually been ungated. The brief assumed it had, and the work
would have failed its own verification.

## Why the prior stage missed it
The brief asserted a state nobody had checked. Caught only because the agent
understood the INTENT and noticed the premise was false — which is the argument for
briefs that state the goal and the why, not just the diff.

## Strongest available prevention
4. **prompt rule** — every brief states the goal and the why, and every resource
   reports **what contradicted the brief**. Nothing deterministic catches a false
   premise in prose.

## Rule proposed
`briefs-state-intent-and-report-contradictions` — state: active (heuristic)
