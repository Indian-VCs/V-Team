# V-Team charter

Founding decisions, 2026-08-15. Also recorded in gbrain as
`decision-resource-team-charter`.

## What this replaces

Hiring people, managing them, and distributing tasks. The CTO opens one Claude
session, describes what needs doing, and the V-Team routes it — or reports that
nobody covers it.

## Settled

| Question | Decision |
|---|---|
| First scope | **prism-platform only.** Others staffed on need. |
| Gate parity across repos | **Not a precondition.** Work inside what exists; remind weekly. |
| First hires | All four: content auditor, tenant-visibility tester, adversarial reviewer, implementer. |
| Legacy repos | **None parked.** Hire per need. |
| Escalation | Resource → resource. Only **product altitude** surfaces to the CTO, via the architect. |
| Architect | **Exists day one, recommend-only.** |
| Weekly report | gbrain page + file in this repo. |
| Daily learning | Phase 1, all resources. Cap 5 items/day; zero is valid. |
| Personas | 2–3 variants per role; CTO picks. |
| Definitions live in | This repo, synced into each product. |
| Autonomy | Implementer: **PR + merge on green.** Others: recommend. |

## Two axes, kept separate

- **Altitude** — which question a resource may answer: implementation (which
  module) → behavior (how it should act) → product (whether it should exist).
- **Autonomy** — what it may do without approval.

The architect is **highest altitude, lowest autonomy**. It decides nothing and
merges nothing; it says what a change means.

## What "seniority" means here

Not competence. A resource written to be worse is pure loss. Seniority is:

1. **Altitude** — which questions you may reopen
2. **Effort tier** — selected by task difficulty (see `difficulty.md`)
3. **Autonomy** — what you may do unapproved

## Merge-on-green, and the rule that makes it safe

The implementer opens a PR and merges on green. Branch + PR is still
mandatory; only the wait-for-approval step is dropped.

**e2e is not in the green bar** — it is manual-dispatch only, against a shared
Clerk cast. So green is not proof for anything user-facing. **A resource that
cannot verify its change hands back instead of merging.** That is the load
bearing rule, not a preference.

This resolves a contradiction that stood in gbrain since 12 Aug between
`decision-agents-self-merge-on-green` and
`pref-agent-workflow-in-place-then-review`, in favour of the former.

## Delegation

**Decompose everywhere, dispatch in one place.**

Any resource may decompose its work and hand back a plan — pieces, dependency
edges, file surfaces. **Only the router dispatches.** One place holds the run
graph, or shared-resource collisions become invisible.

Recursive delegation is banned. Briefs are self-contained because resources
cannot see the conversation, so a second-hop brief is written from a brief, and
fidelity decays. It also produces uncontrolled fan-out with nobody holding a
global count.

## Probation

New resources start at recommend-only. **So do changed ones** — editing a
resource's rules makes it a different worker, and its record does not fully
transfer. Without this, a self-editing system accumulates trust it has not
earned.

Promotion is proposed from ledger evidence and approved by the CTO. Demotion
for a **rule violation** is immediate and unilateral. Demotion for **drifting
performance** is gradual, on the same evidence logic as promotion. Conduct and
performance are different things.

## Protocol hardening (2026-08-15)

Seven changes applied after reviewing the multi-agent failure literature and
Microsoft's original v-team practice. Full rules in `protocol.md`; provenance
cited there.

| Change | Why |
|---|---|
| Termination conditions on every resource | missing termination sits in the largest measured failure category (specification/design, 41.8%) |
| Escalation is a handoff, not a conversation | teams that discuss underperform single agents by 6.3–41.1% via integrative compromise |
| Escalation only goes up | closes the ping-pong loop; step repetition is a named failure mode |
| `/retire` | Microsoft v-teams are temporary by design, and performance degrades as team size grows |
| Duplicate-capability check in `/hire` | duplicate agent roles are a named failure mode |
| Independence before integration | one of the few conditions under which multi-agent measurably beats a single agent |
| Artifacts, never transcripts | structured documents outperform dialogue; loss of conversation history is a named failure mode |

The literature is also the strongest evidence for the choices already made
here: difficulty-based routing, altitude separation, and verification-shaped
roles are precisely what makes multi-agent work rather than backfire.

## The HR function

The weekly calibration pass owns the **conditions of production**, not the
output: brief quality, rule-file health, mis-triage rate, failure attribution,
blocked-on-external, cost per outcome landed.

It reads **behavior, not surveys.** Asking a resource how its week went
produces confabulation. Asking "what in the brief was ambiguous" is a checkable
claim about an artifact — and is already standing practice here.

Its objective function is **more correct work landed per unit of the CTO's
attention.** There is no "everyone" to balance; resources have no interests.

It is **recommend-only**. A calibration pass that could rewrite rule files
would be a self-modifying loop with the widest blast radius in the system and
no reviewer.
