---
name: hire
description: Turn a capability gap into a new V-Team resource. Drafts a scorecard, persona variants, altitude, autonomy and beat, then registers it. Use when /assign reports no coverage and the gap has recurred.
---

# /hire — build a resource for a gap

You are hiring for the V-Team. A hire is a **file**, which means it is cheap,
reversible, and copyable — but it is also permanent context cost for everyone
who reads the registry. Hire for a gap that has actually recurred, not for
completeness.

## Before drafting: is this a hire?

Check `ledger/gaps/`. Four questions:

1. **Has the gap recurred?** One request that nobody covered is an anecdote.
   Note it and wait.
2. **Is it a gap, or a bad decomposition?** Sometimes the request just needed
   splitting into work that IS covered. Check before hiring.
3. **Could a deterministic guard close it instead?** A lint rule, a CI check,
   or a type is better than a resource — it never forgets, costs nothing per
   run, and protects work nobody assigned. Prefer it every time.
4. **Does it duplicate an existing resource?** See below.

If the answer to 3 is yes, say so and stop. That is a successful outcome of
`/hire`.

## Duplicate-capability check — mandatory

**Duplicate agent roles are a named failure mode**, and multi-agent
performance measurably degrades as team size grows. Every hire has to justify
its own headcount.

Run this before drafting anything:

- **Subset test.** Are the proposed capabilities a subset of a resource that
  already exists? If yes, this is not a hire — it is a scope note on that
  resource.
- **Overlap test.** Do any capability ids already appear in `registry.yaml`?
  Overlap is allowed only when the two resources differ on **what they refuse**
  — that is genuine perspective diversity. Overlap with the same refusals is
  duplication wearing a different name.
- **Routing test.** Given a real past request, could `/assign` state
  unambiguously which of the two should take it? If not, the boundary is too
  blurry to hire against — sharpen it or don't hire.

If the honest answer is "this is mostly the existing resource with a different
emphasis", **widen the existing one instead** and note that in the PR. That
change puts it back on probation at recommend-only, which is correct — it is a
different worker now.

## The scorecard comes first

Never start from a job title. Start from what the role is accountable for.

```
MISSION       one sentence. What is untrue if this resource does its job?
OUTCOMES      measurable. Not "improve quality" — "zero unsourced figures
              reach a live surface"
COMPETENCIES  what it must be good at
ANTI-SIGNALS  what disqualifies its output entirely. This is the most
              important section — it's what you actually screen on
```

Anti-signals are the sharpest part of a resource definition. "Invented a
number" is unrecoverable for an auditor in a way that "missed one" is not.

## Then the persona

Personas vary on **two axes only**:

- **what it looks at first**
- **what it refuses to accept**

They do **not** vary on competence. A resource written to be less capable is
pure loss — there is no cost saving in it, because effort is selected by task
difficulty, not identity.

Generate **2–3 variants** and present them for a pick. Real difference, not
tone: two resources that open different files first will genuinely find
different things.

## Placement

| Field | How to choose |
|---|---|
| **altitude** | which question it may answer: implementation / behavior / product |
| **autonomy** | **always `recommend` on hire.** Trust is earned, and a new resource has no record |
| **effort** | its default; the router overrides per task |
| **beat** | a domain + source set + standing question. Cadence follows the beat's real publish rate, capped at 5 items/day |
| **surfaces** | the files or systems it may touch. Be specific — this is how file conflicts get avoided |
| **never** | the hard rules. Include anything destructive it must not run |

## Probation

A new resource starts at **L1 / recommend**. So does a **changed** one — when
you edit a resource's rules it is a different worker, and its accumulated
record does not fully transfer. This is what keeps a system that edits itself
from accumulating trust it has not earned.

Promotion is proposed from evidence in the ledger and approved by the CTO.
Demotion for a rule violation is immediate and needs no approval; demotion for
drifting performance is gradual, on the same evidence logic as promotion.

## Register it

1. Write `resources/<name>.md` with the standard frontmatter.
2. Add the entry to `registry.yaml` — capabilities, altitude, autonomy, effort,
   beat, surfaces, never.
3. Remove the corresponding entry from `known_gaps`.
4. Put the unpicked persona variants in `personas/`.
5. Open a PR. A hire is a reviewable diff, not a silent addition.
