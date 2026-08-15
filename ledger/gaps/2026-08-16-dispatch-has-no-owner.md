---
date: 2026-08-16
requested_by: CTO
capability: dispatch.decompose, dispatch.brief, dispatch.run-graph
product: v-team (this repo)
status: not-hired
verdict: guard-and-document, no hire
decided_by: roster-steward (Anubis)
---

## Requested

Verbatim, from the CTO: *"I don't have to handle the delegation of all
resource, who is at the top level?"* — raised alongside the earlier *"figure out
who reports to who and structure the delegation flow."*

The honest reading of the current state: **nobody** is at the top level below
the CTO, and every dispatch decision routes back through the CTO's own chat
window.

## VERDICT — **no hire.** The deliverable is `docs/delegation.md`.

## The four /hire checks

### 1. Recurrence — **NOT MET. Zero dated artifacts.**

`ledger/gaps/` holds four entries before this one; **none names dispatch,
delegation, routing or run-graph ownership as an uncovered capability.**
`ledger/runs/` holds two run files, both of which record dispatches that
happened — evidence the router *works*, not evidence it is unowned. There is no
second occurrence because there is no first recorded one.

This is a **first, unrecorded occurrence** — the same shape as the
`deployment-engineer` hire and my own. Recording that the bar failed is
mandatory (`resources/roster-steward.md`: *never — hires on an uncited
recurrence without recording that the bar failed*). Here the bar failing and
the verdict agree, which is the first time tonight that has happened.

### 2. Gap, or bad decomposition? — **A bad decomposition. This is the finding.**

The split was attempted, part by part:

| Part of "delegation" | Owner today |
|---|---|
| name the capability a request needs | `skills/assign` §1 + `registry.yaml` |
| decide whether anyone covers it | `skills/assign` §2 |
| rate difficulty, pick effort | `skills/assign` §3 + `docs/difficulty.md` |
| dependency edges, file conflicts, shared-resource locks | `skills/assign` §4 |
| write the self-contained brief, done-condition, budget | `skills/assign` §5 |
| record the run graph | `skills/assign` §7 + `ledger/runs/` |
| integrate outputs and report up | the CTO's session |
| **approve anything** | the CTO, undelegatable |

**Every part already has a written owner.** The role is not missing; it is
fully specified in `skills/assign/SKILL.md`. What the CTO is feeling is not an
unowned role — it is that the specified role is being executed **one task at a
time** instead of **once per intent**. A router run as a lookup table costs one
CTO turn per task. Run as a decomposer it costs one CTO turn per *run*.

That is a usage fix, it is free, and it is written up in `docs/delegation.md`
under "What actually reduces the CTO's load".

### 3. Could a guard or a document close it instead? — **YES. Both. This is why there is no hire.**

**The document** is `docs/delegation.md`: the two graphs stated separately, the
one-hop dispatch rule, the up-only escalation rule with *sideways* defined, what
never travels, and where the CTO sits. A written delegation protocol the CTO's
window follows is cheaper than a resource and cannot drift out of context.

**The guards written or specified in this PR:**

| Guard | Closes |
|---|---|
| `docs/protocol.md` §3 now defines *sideways* as same-altitude | the false-defect report that triggered this audit |
| §3 now requires the escalation target to be **declared in the brief** | a resource privately choosing its own receiver — a dispatch decision the run graph never sees |
| `validate.sh`: every registered resource has a brain source | the memory-isolation escape, logged separately |
| `validate.sh`: callsigns present and unique | half the naming rule; the other half is judgement |

**Why a guard is not sufficient on its own, and why that still does not make it
a hire:** no check can decompose intent or write a brief. But the thing that
*does* decompose intent already exists and is a skill, so the residue after the
guards is not resource-shaped either. It is skill-shaped, and the skill is
already written.

### 4. Duplicate? — **Moot, but it would have been close to `architect`.**

Recorded because the check is mandatory even when the verdict is no-hire.

| Test | Result |
|---|---|
| **Subset** | No. Dispatch capabilities are not contained in `product.impact` / `product.should-this-exist`. |
| **Overlap** | Zero shared ids. |
| **Refusals** | Sharply opposed, which is the problem, not the diversity: `architect` is *defined* to decide nothing and merge nothing. Dispatch **is** a decision — who does this, at what effort, now or blocked. Giving dispatch to `architect` contradicts its definition, and the CTO's brief already said so. |
| **Routing** | *"Who should take this?"* → the router. *"Should this change exist?"* → `architect`. *"Should this role exist?"* → `roster-steward`. Unambiguous — which is exactly why a fourth thing in that list would blur it. |

## The structural argument, stated once

If the router became a resource, the CTO's window would dispatch **it**, and it
would dispatch the workers: a **two-level spawn chain**. `skills/assign` §6 and
`docs/charter.md` both say resources never spawn. So the rule either breaks or
becomes a per-resource privilege — and a privilege is what every future hire
will argue for.

Worse mechanically: **the run graph would move from the most durable context in
the system to the least.** A subagent's context dies at hand-back; the CTO's
session persists across the whole run. The router's one job is to hold the graph
for the duration. Making it a resource makes it forget.

**Altitude:** a dispatcher answers *who*, at every altitude at once. It is not a
rung. It sits outside the ladder as infrastructure — which is what a skill is.

## Headcount — the standing finding, still open

Eight resources for one product. `/retire` has never been used while headcount
went 5 → 6 → 7 → 8, and my own scorecard says a period in which nothing was
retired is a finding about me.

Refusing this hire keeps it at eight. That is the right outcome and it is **not
a retirement**. Ledger coverage per resource (files in `ledger/` naming it):
`implementer` 8 · `tenant-visibility-tester` 7 · `architect` 6 ·
`adversarial-reviewer` 6 · `content-auditor` 5 · `deployment-engineer` 4 ·
`design-reviewer` 2 · `roster-steward` 2. The two thinnest are the two hired
hours ago; judging them now would be judging their age, not their work.

**No retirement is proposed today, and that is itself provisional.** The first
real retirement case belongs with the queued audit of `deployment-engineer.md`
and `design-reviewer.md`, where there will be an untouched artifact to read.

## Callsign rename — old → new, 2026-08-16

CTO rule, verbatim: *"why are you using human names, I said character name which
is not a human, like hulk, groot"*, then *"rename the inherited ones too."*
A callsign is a **character**, that character is **not human**, and the name
**encodes the job** in one defensible clause.

**Commit trailers and merged ledger entries are never rewritten.** The old
callsigns are permanent in the record. This table is what makes them
resolvable, and it is worth more than the rename itself.

| Resource | Old callsign | New callsign | The one clause |
|---|---|---|---|
| `tenant-visibility-tester` | Neo | **Argus** | a hundred eyes; believes only what they actually see, never what the config claims |
| `content-auditor` | Hermione | **Mimir** | guards the well the truth comes from — drink at the source or not at all |
| `architect` | Alfred | **Jarvis** | sees every system at once and gives orders to no one |
| `deployment-engineer` | Marshal | **Cerberus** | stands at the gate; nothing ships past it unchecked, and nothing comes back except through it |
| `design-reviewer` | Ariadne | **Bagheera** | knows every path and shows you the one you can actually take |
| `roster-steward` | Janus | **Anubis** | weighs each one against the standard and hands the verdict to someone else to pass |
| `adversarial-reviewer` | Heimdall | *unchanged* | already compliant — Norse god, non-human |
| `implementer` | Samwise | *unchanged* | already compliant — a hobbit |

Commits authored before this entry carry `Marshal`, `Ariadne`, `Janus`,
`Alfred`, `Neo`, `Hermione` in their `V-Team-Resource` and `Co-authored-by`
trailers. The functional id in the trailer is the stable key; the callsign in
parentheses resolves through this table.

**Brain source ids follow the callsign** (`docs/memory.md`), so this rename
orphaned the `alfred`, `hermione` and `neo` stores. That is handled with the
memory-isolation escape logged the same day — see
`ledger/escapes/2026-08-16-hire-path-no-brain-source.md`.

## Open, handed to the CTO

1. **`escalation.terminal` was a badly shaped capability id — RESOLVED, and
   the sequence is the point.** Terminal is a property of *(resource, object)*,
   not of a resource. `registry.yaml` gave it to `architect` alone; `README.md`
   called both product-altitude resources terminal. Both statements were
   defensible and they contradicted each other.

   | Step | What happened |
   |---|---|
   | **Proposed** | `roster-steward` recommended splitting into `escalation.terminal.product` (`architect`) and `escalation.terminal.team` (`roster-steward`) |
   | **Refused self-application** | Declined to apply it, on the grounds that granting yourself a capability in a registry you own is self-dealing **regardless of whether the change is correct**. Handed it to the CTO instead. |
   | **Applied on instruction** | CTO, verbatim: *"escalation.terminal - do two split"*. Applied 2026-08-16. |

   Recorded in that order deliberately. The capability itself is minor; what is
   worth keeping is that the resource that owns the registry did **not** write
   itself a capability it believed in, and waited to be granted it. A registry
   is only worth reading if the thing maintaining it will refuse itself.

   **Not a rank.** The two ids are unordered. Each resource is terminal on its
   own object and an ordinary product-altitude resource with no special
   standing on the other's; neither routes through the other. Written that way
   in the `registry.yaml` header, `resources/architect.md`,
   `resources/roster-steward.md` and `docs/delegation.md`, because a single
   `escalation.terminal` id is exactly what read as a rank and produced the
   contradiction.
2. **The retirement case**, deferred to the queued audit above.
