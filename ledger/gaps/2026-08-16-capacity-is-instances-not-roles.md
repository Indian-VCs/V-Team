---
date: 2026-08-16
requested_by: CTO — "if there is more work, team should expand"
capability: code.implement (second seat), gate.merge-decision
product: prism-platform
status: not-hired
verdict: no hire — cloning is correct staffing; the real defect is a §6 collapse, fixed by a rule
decided_by: roster-steward (Anubis)
---

## Requested

The CTO, verbatim: *"if there is more work, team should expand."*

Evidence handed over by the router, all of it from today:

1. **Three concurrent `implementer` instances** — landing-page build, Clerk
   satellite build, PR gate — all called "implementer" in the dispatch layer.
   Capacity met by cloning one resource rather than staffing.
2. **Samwise both builds and merges.** It holds `merge-on-green` and today
   gated a queue containing work produced by other `implementer` runs.
3. **Serial gating is the bottleneck** — five PRs across two repos through one
   resource, one at a time.
4. **All three instances wrote `Co-authored-by: Neo`**, each taking the trailer
   from the router's brief rather than the registry.

## VERDICT — **no hire.** Deliverable: `protocol.md` §6 and `skills/assign` §6.

Third refusal today, and the reasoning is different each time. This one turns on
a distinction the brief did not make: **the registry describes roles, not
headcount.**

## The four /hire checks

### 1. Recurrence — **MET for the §6 collapse. NOT MET for a capacity gap.**

Two different requests are bundled here and they have different evidence.

**The §6 collapse — met.** Item 2 above, plus
`ledger/runs/2026-08-16-org-and-hiring.jsonl` L0.3, which refused Cerberus's
promotion partly on the ground that *"structurally the `workflow_dispatch`
button IS the gate"* — the same question of who is allowed to be their own
gate, raised before today.

**A capacity gap — not met, and I checked rather than assumed.** `known_gaps`
lists `infra.ci`, `infra.cloudflare-workers`, `security.review` and
`data.migration`. **Zero dated artifacts in `ledger/gaps/` or
`ledger/escapes/` name any of them.** The only mention anywhere is
`ledger/reports/monthly/BASELINE.md`, which is the day-zero snapshot, not an
occurrence. Recording that the bar failed is mandatory and it failed.

`security.review` is the strongest latent candidate — nobody owns
`SUPABASE_SERVICE_ROLE_KEY` blast radius, public bucket exposure, or the
vendor-portal auth surface, and **today's Clerk satellite work is exactly that
surface.** It still has no recorded occurrence. Hiring on a hunch about it would
be the anti-signal in my own definition: *recurrence asserted rather than
cited.*

### 2. Gap, or bad decomposition? — **A bad decomposition, and it is the finding.**

**Cloning is not a defect. It is correct staffing, and nothing prohibited it.**
§6 requires one accountable per *unit of work*. Three `implementer` instances on
three disjoint units have exactly one accountable each. The registry describes
**roles**; it has never described headcount, and no rule anywhere says a role may
have one live instance.

Hiring `implementer-2` would be **pure loss**: an identical definition, identical
capabilities, permanent context cost for every reader of the registry, and
`/assign` could not tell it apart from `implementer` — capability ids are unique
by `validate.sh` 4b, so a second implementer could not even declare
`code.implement`. The thing that separates instances already exists and is the
`V-Team-Run` id.

**The real defect is item 2, and it is not a capacity problem at all.** "Decide
whether this merges" is a different unit of work from "build it". When one
instance holds both, its single accountable is also its only reviewer. Cloning
did not cause that — it *hid* it, because both units log under one name.

**More implementers do not fix it.** A fourth clone gating the third clone's work
is fine, but so is the third gating the second; the fix is a rule about *which
run may gate which*, not a headcount.

### 3. Guard before resource — **a rule plus a check that has its data already.**

`protocol.md` §6 now says: a resource may run as many instances as there is work
for, and **may not gate a PR whose commits carry its own callsign and its own
run id.** Per-run, not per-role — cross-instance gating is the intended use.

This is mechanically checkable and **the data is already parsed**:
`check-attribution.sh` reads `Co-authored-by` and `V-Team-Run` off every commit
in a PR, and `.v-team-callsigns` now resolves a callsign to a resource. Comparing
"who is merging" against "who authored" needs no new input.

**Why a guard is enough here, when it often is not.** The judgement half of
gating — *is this diff correct* — is already owned: `adversarial-reviewer`
refutes, `tenant-visibility-tester` verifies against the running app,
`design-reviewer` measures. What was missing was not judgement; it was a
**constraint on who may exercise it**. Constraints are what scripts are for.

### 4. Duplicate / overlap — **a gate owner collides with three resources.**

| Test | Result |
|---|---|
| **Subset** | "Review a diff and decide" is `adversarial-reviewer` plus an approval it is *defined* never to give. |
| **Overlap** | `merge-on-green` is `implementer`'s. Moving it creates two merge owners unless taken away in the same PR. |
| **Cerberus** | A gate owner that also deploys is a second `deployment-engineer`; one that does not adds a third party to the merge→deploy boundary for no gain. |
| **Routing** | *Who builds it* → Samwise. *Is the diff wrong* → Heimdall. *Does it ship* → Cerberus. A gate owner sits between three answered questions. |

## The probation tension, resolved rather than dodged

This is what makes a gate-owner hire not merely unnecessary but **incoherent**:

- New hires start at `recommend`. No exceptions — my definition calls a
  first-day exemption an anti-signal that *invalidates the output entirely*.
- A gate owner at `recommend` **cannot merge**. On day one it cannot do the one
  thing it exists for.
- Give it merge authority instead, and it is a probation exemption for the
  resource whose entire purpose is being trusted with the last gate.
- Leave it at `recommend` and it reviews-and-recommends — which is
  `adversarial-reviewer`, already hired, already better scoped because it is
  forbidden to approve.
- And critically: **a `recommend`-only gate owner cannot stop Samwise merging
  its own work.** Only an autonomy change or branch protection can. So the hire
  does not solve the stated problem even if you make it.

Both branches are unacceptable. A question with no acceptable answer either way
is usually mis-shaped, and this one is: the problem is a missing *constraint*,
not a missing *person*.

## On item 4 — three clones, one wrong trailer

The router offered this as possibly arguing for more resources: *"cloning a
resource clones whatever the dispatcher got wrong, with no second reader."*

**It argues the opposite, and this is the cleanest evidence in the brief.**
Three *different* resources dispatched from the same brief would have written
`Neo` too — they would have read the same brief. §5 makes a brief self-contained
and authoritative by construction, and §4's independence rule prevents reviewers
anchoring **on each other**, not a bad input reaching all of them.

Diversity of resources is no defence against a shared upstream error. **Only a
check against the source of truth is**, which is what
`ledger/escapes/2026-08-16-retired-callsign-passed-the-guard.md` built. This
datum is an argument for the guard and *against* the hire.

## The bottleneck is not headcount

Named by the router itself: the **billing block gates every prism merge**, and
branch protection **cannot be enabled on `prism-platform` at all** — private repo
under a personal account on a free plan, established in
`ledger/gaps/2026-08-16-trailer-projection-has-no-substrate.md`. Neither moves
with staffing.

Serial gating through one resource is a *symptom*: the merge decision still
needs a judging party precisely because branch protection cannot automate it.
Fixing the plan fixes more throughput than any hire, and it is a CTO decision,
not mine.

## Headcount

Stays at **8**. `/retire` still has never been used across 5 → 6 → 7 → 8, and my
own scorecard says a period with no retirement is a finding about me. Note the
`skills/retire` "no work" trigger is **suspended** as of today
(`2026-08-16-runs-deleted-guards-left-pointing.md`), so the idleness route to a
retirement is currently unavailable — which makes that standing finding harder
to discharge, not easier, and I am not pretending otherwise.

## What would change my answer

Stated concretely, because "not yet" is worthless without it:

1. **Two dated artifacts naming one uncovered capability.** `security.review` is
   the likeliest. Log it the next time an auth or secrets question has no owner
   — that is one artifact, and the second makes the case.
2. **Evidence that instances actually collide.** Three concurrent
   `implementer` runs on *overlapping surfaces* — the `2026-08-12` sweep escape
   is what that looks like — would show the surfaces cannot be partitioned, and
   partitioning is the premise of the no-hire.
3. **A measured queue.** "Serial gating is the bottleneck" is currently an
   impression. `pending.sh` was built to measure exactly this and is dormant
   because `ledger/runs/` was deleted. Restore a dispatch record and the claim
   becomes checkable either way.

## What contradicted the brief

- **"Capacity is being met by cloning, not by staffing"**, framed as a defect.
  Cloning *is* staffing for a role-based registry; the framing assumes registry
  entries are seats. They are not, and nothing in the repo ever said they were.
- **"Whether the split is by surface or by function."** Neither. No split is
  needed, and the question presupposes the hire. The problem I am solving is
  the **§6 collapse**, and a split does not solve it: two implementers divided
  by surface still each gate their own work.
- **"Where `merge-on-green` lives afterwards."** It stays with `implementer`,
  unchanged, because the constraint is per-run rather than per-role. No autonomy
  changes, so no second merge owner is created.
- **The three-clones-one-error datum** points at the guard, not the hire.

## What I did NOT verify

- **That the surfaces of the three concurrent runs were actually disjoint.** The
  no-hire rests on it. I checked the branch names and the trailer scope, not the
  file sets, and `ledger/runs/` is deleted so the `surfaces` field that would
  have answered it no longer exists. **If they overlapped, the sweep escape of
  2026-08-12 is the precedent and this verdict deserves re-opening.**
- **The claim that serial gating is the bottleneck.** Unmeasurable today, for
  the reason above.
- **Whether `implementer` gating `implementer` actually happened on a specific
  PR**, versus Samwise gating a queue that merely contained such work. I took
  the router's account; the run record that would settle it is gone.
- I did not run `record.sh`, and I did not inspect prism CI timings.
