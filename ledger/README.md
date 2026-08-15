# Ledger

Evidence. Everything the V-Team learns and every judgement about how it is
performing traces back to a file here.

Nothing in this directory is written by a resource about itself. Self-assessment
is not evidence — a resource that grades its own performance optimises the
assessment.

## Layout

```
ledger/
  escapes/     YYYY-MM-DD-<slug>.md   defects that got past a stage
  gaps/        YYYY-MM-DD-<slug>.md   requests nobody could cover
  rules/       <rule-id>.md           a rule and its state history
  reports/     YYYY-Www.md            the weekly report, archived
```

## Escape entry

An escape is a defect found **downstream** of the stage that should have caught
it. A bug the gate caught is not an escape — that is the gate working.

```markdown
---
date: YYYY-MM-DD
found_by: production | reviewer | tester | auditor | CTO
should_have_caught: <stage or resource>
attribution: resource-error | ambiguous-brief | no-gate-coverage | impossible-task
---

## What failed
## Why the prior stage missed it
## Strongest available prevention
  1. deterministic guard  2. shared helper  3. test  4. prompt rule  5. runbook
## Rule proposed (if any) — starts at `observed`
```

**Attribution is the field that makes the ledger actionable.** "3 escapes this
week" is not a number anyone can act on. "1 resource error, 1 ambiguous brief,
1 no gate coverage" is three different decisions.

Blameless: the question is what about the system let this through, not which
resource failed.

## Gap entry

Logged by `/assign` whenever it reports no coverage. A repeated gap is the
hiring signal; a single one is an anecdote.

## Rule entry

One file per rule, carrying its state (`observed` → `candidate` → `active` →
`contested` → `superseded` / `retired`), its confirmations across **distinct
contexts**, its contradictions, and whether it is a **guard** or a
**heuristic** — because those retire on opposite signals. See
`docs/learning.md`.

Rules are **superseded, never deleted.** A failure that returns in eighteen
months should be recognised as a recurrence.

## Seeding

The first entries are retrospective — real escapes already recorded in gbrain:
the storage driver ENOENT in production, the editor crash that shipped
typecheck-clean, the e2e font outage, the Clerk cast desyncs. The loop starts
with data rather than waiting a month for it.
