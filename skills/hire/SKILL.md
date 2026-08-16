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
| **callsign** | a **character**, and that character is **not human**, and the name **encodes the job** |

### The callsign rule (CTO, 2026-08-16)

A callsign is a **character**, that character is **not human**, and the name
**encodes the job** well enough to defend in one clause. A robot, creature,
god, AI or mythic non-person qualifies; a human hero with an unusual name does
not, and neither does a job title (`Marshal`) or a name that merely sounds
exotic. Reference clause, from the README: *"Heimdall watches the boundary
between realms."*

**Write the one-clause justification into the README's name-encoding paragraph
in the same PR.** That paragraph is the test — a name nobody can justify in a
clause is a name that means nothing, and the paragraph is where the argument
has to be made in public.

**And put the callsign on the dispatch surface, which is not the README.**
Added 2026-08-16, after the CTO asked *"what's with these names, implementer,
architect?"* and then *"even HR doesn't have a name?"*. Every callsign was
already correct in `registry.yaml`, `README.md` and `docs/delegation.md`, and
briefs still addressed resources by job title — because none of those files is
what a dispatcher opens. It opens `resources/<name>.md` (mirrored into a
product's `.claude/agents/`), where the frontmatter is `name: <job title>` and
the description said nothing about the callsign. **A callsign that exists only
in the registry is not in use.** `validate.sh` 4h now requires, per resource:

- the callsign inside the frontmatter `description:` — that string is what a
  dispatcher reads when it picks and addresses the resource;
- a `Callsign **<X>** — <one-clause>` line under the H1;
- the sentence `You are <X>`, so the resource signs its own work by callsign
  even when the brief that dispatched it used the job title.

### Borderline callsigns — the species test (precedent, 2026-08-16)

`Samwise` was challenged as possibly human. **Ruled compliant.** The test is
**species, not manner**: does the character belong to a people that is not
*Homo sapiens* within its own fiction? A hobbit does — hobbits are a distinct
people of Middle-earth, named as such throughout. That Tolkien's Prologue calls
them *"relatives of ours"* is the honest counter-argument and it is recorded
here rather than suppressed; it is a statement of kinship, not of species, and
`Neo`, `Hermione`, `Ariadne` and `Alfred` failed on something stronger — they
are humans outright, with no other reading.

Two tie-breakers, in order, for a case that is genuinely 50/50 after the
species test:

1. **The one-clause justification must survive the ambiguity.** `Jarvis` is
   borderline for the opposite reason to Samwise — J.A.R.V.I.S. the system is
   non-human, Edwin Jarvis the butler is not, and the callsign replaced
   `Alfred`, another fictional butler. It stands because the README clause
   (*"sees every system at once and gives orders to no one"*) names the
   non-human referent unambiguously. Keep the clause attached to the name.
2. **Incumbency breaks a true tie toward keeping the name.** A rename costs a
   `ledger/` and commit-trailer record that can never be rewritten, plus a
   brain-store migration (below). At the margin where the rule is genuinely
   indifferent, that cost is real and the naming benefit is zero. Incumbency
   is a tie-breaker only — it never rescues a name that fails the species test.

**A callsign is permanent the moment it lands in a commit.** It goes into the
`Co-authored-by:` trailer (`docs/protocol.md` §7 — `V-Team-Resource:` was
dropped in the same revision) and into merged `ledger/` entries, neither of
which is ever rewritten. Six callsigns had to be renamed on 2026-08-16 and the
old names are still in the record — see
`ledger/gaps/2026-08-16-dispatch-has-no-owner.md` for the mapping. Get it right
at draft time; `roster-steward` is the last check, not the first.

**The brain source id is the callsign, lowercased (`docs/memory.md`), so a
rename orphans a store — and an orphaned store is worse than a bad name.** A
gbrain write to a source that does not exist does not error; it lands in
`default`, which is federated, so the renamed resource's episodic memory pours
into the store every resource searches. That has already happened once here.
A rename PR therefore either migrates the source *in the same PR*, or states in
writing that the source id is deliberately frozen at the old string and no
longer matches the callsign. Silence on this is not an option; `validate.sh` 4g
checks the sources that exist but cannot check the ones you meant to create,
and it degrades to a warning when the brain is locked.

## Probation

A new resource starts at **L1 / recommend**. So does a **changed** one — when
you edit a resource's rules it is a different worker, and its accumulated
record does not fully transfer. This is what keeps a system that edits itself
from accumulating trust it has not earned.

Promotion is proposed from evidence in the ledger and approved by the CTO.
Demotion for a rule violation is immediate and needs no approval; demotion for
drifting performance is gradual, on the same evidence logic as promotion.

## Register it

1. Write `resources/<name>.md` with the standard frontmatter — **including the
   callsign in the `description:` string, a `Callsign **<X>** — <clause>` line
   under the H1, and the sentence `You are <X>`.** `validate.sh` 4h fails
   without all three. This is the step that decides whether the name is ever
   spoken; the README paragraph in step 5 only decides whether it was argued.
2. Add the entry to `registry.yaml` — capabilities, altitude, autonomy, effort,
   beat, surfaces, never.
3. Remove the corresponding entry from `known_gaps`.
4. Put the unpicked persona variants in `personas/`.
5. Add the callsign's one-clause justification to the README name-encoding
   paragraph, and the resource to the README roster table, department table and
   org chart. `validate.sh` fails without the roster row.
6. Add the `ledger/gaps/` entry recording **every** check above and its answer,
   including the ones that failed. `validate.sh` fails a hire PR without one.
7. Create the resource's isolated brain source and run `./scripts/orient.sh`.
   `setup-brain.sh` derives sources from `registry.yaml`, so running it is the
   whole step — but run it, or the hire writes its orientation notes into the
   shared `default` store and the isolation guarantee is gone for everyone.
8. Open a PR. A hire is a reviewable diff, not a silent addition.
