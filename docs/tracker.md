# Tracker — provenance and rollups

Every learning carries where it came from. Every number rolls up daily →
weekly → monthly, so that after a month the question "did this team actually
get better" has an answer instead of an impression.

## Provenance — one entry per learning

`ledger/learnings/<YYYY-MM-DD>-<slug>.md`

```yaml
---
id:       2026-08-15-mast-termination
date:     2026-08-15
resource: architect              # who learned it
topic:    multi-agent termination conditions
domain:   agent-architecture     # the domain summary
source:
  title: "Why Do Multi-Agent LLM Systems Fail? (MAST)"
  url:   https://arxiv.org/pdf/2503.13657
  kind:  paper                   # paper | release-notes | vendor-doc | incident | repo
state:   observed                # see docs/learning.md
validated_against: null          # the repo evidence that promoted it
shared_to: []                    # resources that adopted it — cross-pollination
---

One paragraph. What was learned, and what it would change here.
```

Two fields do the heavy lifting: **`validated_against`** is what separates a
web finding from a rule, and **`shared_to`** is the only way the sharing
between resources becomes countable.

## The metric correction

**"How much each agent has learned" is a trap as a volume count.** A resource
producing five weak items a day would outrank one producing a single good one,
and a resource that discovers it's measured on volume will produce volume. The
cap limits the damage; it doesn't fix the incentive.

Track volume as context. Track **conversion** as the signal:

```
conversion = learnings that reached `active` / learnings proposed
```

`active` requires validation against this repo, which no resource can grant
itself. Same rule as everywhere else in this system: the number comes from
evidence the resource cannot write.

## Daily — `ledger/reports/daily/YYYY-MM-DD.md`

Raw journal. No conclusions, no state changes.

| Per resource | Team |
|---|---|
| proposed today (of 5 cap) | total proposed |
| sources touched | new gaps opened |
| run mode: normal / catch-up / backfill | dispatches, hand-backs, escalations |
| last successful run | **routines that did not run** |

That last row is the liveness check. A beat silent for six days is a
`not measured` row, never an implied zero.

## Weekly — `ledger/reports/YYYY-Www.md`

The calibrated view. This is where states move and the CTO report is emitted
(`weekly-report.md`).

- **conversion rate** per resource, and the trend
- **gaps**: opened, closed, still open — and any that recurred
- **shares**: learnings adopted by a second resource, with direction
  (`implementer → architect` is the depth-to-breadth flow working)
- **escapes by attribution**: resource-error / ambiguous-brief /
  no-gate-coverage / impossible-task
- **mis-triage rate** — router difficulty calls that produced hand-backs
- **cost**: tokens per landed outcome

## Monthly — `ledger/reports/monthly/YYYY-MM.md`

The only window where "is it improving" is answerable; weekly is too noisy.

| Question | Measured by |
|---|---|
| Where did it start? | **the baseline** — see below |
| Where is it now? | same metrics, this month |
| Is it handling tasks better? | escape rate ↓, first-pass green ↑, hand-back rate ↓ |
| Is it learning or just reading? | conversion rate ↑, share count ↑ |
| Is it getting cheaper? | tokens per landed outcome ↓ |
| Can it go to the next level? | autonomy proposals, with the evidence |

**Autonomy changes belong here, not in the weekly.** A month is roughly the
right evidence window for a trust decision; a week is noise.

## The baseline must be captured now

`ledger/reports/monthly/BASELINE.md`, written **before the first learning
run**. Without it, "where it started" is unrecoverable in a month — there is no
way to reconstruct it after the fact.

Record at day zero: current escape count, open gaps, resources and their
autonomy levels, repos with and without a gate, and the last four weeks of git
and CI history as the pre-V-Team control.

That control group is what makes the first monthly report mean anything: it
answers "better than *what*."

## Anti-gaming

Every number above is computed from artifacts a resource cannot write —
git history, CI results, and state transitions that require external
validation. No metric here reads a resource's own account of how it did.
