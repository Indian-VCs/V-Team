# Delegation — who is at the top, and what travels where

Written 2026-08-16 by `roster-steward` (Anubis) in answer to two CTO questions:
*"figure out who reports to who and structure the delegation flow"* and *"I
don't have to handle the delegation of all resource, who is at the top level?"*

The verdict on the second one is **no hire** — the reasoning is in
`ledger/gaps/2026-08-16-dispatch-has-no-owner.md`. This file is what was
delivered instead.

## The short answer

**The CTO is at the top level, and that is the design, not the defect.**

There is exactly one approver. Nothing merges a hire, a retirement, a promotion
or a production deploy without them. Putting a resource above that would not
remove a decision from the CTO's window; it would remove *visibility* of the
decision from the CTO's window while leaving the accountability there.

**What sits below the CTO is not a person. It is the router, and the router is
infrastructure.** `/assign` is a skill the CTO's session runs, not a resource
that can be dispatched. The reason it is a skill is mechanical and is the whole
argument against making it a resource:

- A resource is a subagent. Its context dies when it hands back.
- The router's one job is to **hold the run graph for the whole run**.
- A graph holder whose memory ends at the first hand-back is strictly worse
  than the CTO's session, which is the longest-lived context in the system.

Making the router a resource would move the run graph from the most durable
context available to the least durable one. That is the opposite of the fix.

## Does a dispatcher resource satisfy the one-dispatcher rule or conflict with it?

**It conflicts, and the conflict is not cosmetic.** Stated precisely:

If the router becomes a resource, the CTO's window dispatches *it*, and it then
dispatches the workers. That is a **two-level spawn chain**. `skills/assign` §6
and `docs/charter.md` both say resources decompose but **never spawn**. So one
of two things has to happen, and both are bad:

1. The dispatcher spawns, and the never-spawn rule is simply broken; or
2. The dispatcher is exempted, and the rule stops being *"nobody spawns"* — a
   mechanical invariant — and becomes *"one privileged resource may spawn"* — a
   per-resource permission that every future hire will argue for.

There is no third reading. **The router is not the CTO's delegate; it is the
CTO's tool.** "Only the router dispatches" and "the CTO holds the router" are
the same sentence, and the honest phrasing of the current state is: *the CTO is
the top level, and the router is how the top level speaks.*

## Altitude: the router is outside the ladder

The ladder answers **which question you may answer**:

```
implementation  ->  behavior  ->  product  ->  CTO
   which module     how it        should it      approves
                    behaves       exist
```

A dispatcher answers a different question entirely — **who** — and it answers
it at every altitude at once. Placing it on the ladder is incoherent in both
directions:

- At **product**, it outranks the behavior resources it dispatches, so
  escalation *to* it would be upward, creating a fourth product-altitude stop
  and a second thing that looks like a terminal.
- At **behavior**, it dispatches product-altitude resources (`architect`,
  `roster-steward`) — a lower altitude handing work down to a higher one, which
  the ladder has no grammar for.

So: **the router sits outside the ladder, as infrastructure.** It is not a rung
and it is not a stop. This is already true; it was just never written down.

### The two-terminal-stop question, resolved

The last hire flagged it and nobody closed it. Closing it now:

- `registry.yaml` declared `escalation.terminal` on `architect` **only**.
- `README.md` says *"Jarvis and Anubis are both product altitude and both
  terminal."*

Both statements are defensible and they contradict each other, because
`escalation.terminal` is a **badly shaped capability id**. Terminal is not a
property of a resource; it is a property of a *(resource, object)* pair.
`architect` is terminal on **product shape**. `roster-steward` is terminal on
**team shape**. Neither is terminal on the other's object, and neither
outranks the other.

**Applied 2026-08-16 on CTO instruction** (*"escalation.terminal - do two
split"*): `escalation.terminal` is now `escalation.terminal.product`
(`architect`) and `escalation.terminal.team` (`roster-steward`).

**These are not two ranks.** There is no ordering between the ids. Each
resource is terminal on its own object and an **ordinary product-altitude
resource with no special standing** on the other's. Neither routes through the
other. A team-shape question does not become a product-shape one by being
escalated, and `architect` cannot receive one on its way up.

The sequence matters more than the capability: it was **proposed** by
`roster-steward` and **deliberately not self-applied**, because granting
yourself a capability in a registry you own is self-dealing regardless of
whether the change is correct. It was applied only once the CTO instructed it,
which makes it granted rather than taken. That is the property that makes the
registry worth reading.

**Either way the count does not grow.** A dispatcher would add a *fourth*
product-altitude stop only if it were on the ladder, and it is not. There are
two terminal stops, on two different objects, and that is the correct number.

## The two graphs

The README blurred these. They are different graphs with different rules.

### Graph 1 — dispatch (solid). Work going out.

```
CTO ──▶ /assign (router, held by the CTO's session) ──▶ every resource
```

- **One hop. Always.** The router is the only node with out-edges.
- **No resource has an out-edge in this graph.** Not one, not conditionally.
- A resource that concludes more work is needed **decomposes and hands back a
  plan**. The plan is data. The router turns it into dispatches, or does not.
- Every dispatch appends to `ledger/runs/<run-id>.jsonl` with exactly one
  `accountable`, its `surfaces`, and its `blocked_on`. That file, not a
  session, is the run graph of record.

### Graph 2 — escalation (dotted). Questions going up.

```
implementation ──▶ behavior ──▶ product ──▶ CTO
   Samwise          Heimdall     Jarvis      approves
                    Argus        Anubis
                    Mimir
                    Bagheera
                    Cerberus
```

- **Up only.** Never down, never sideways — and *sideways means same altitude*
  (`docs/protocol.md` §3). Heimdall → Argus is sideways. Samwise → Heimdall is
  up, and is allowed.
- **The target is declared in the brief**, by the router, before dispatch. A
  resource choosing its own receiver is a dispatch decision the run graph never
  sees. No declared target ⇒ it goes to the router as new work.
- An escalation is a **handoff with a verdict**. The receiver decides alone.
  There is no reply leg, in either graph. A reviewer answering an implementer
  is the ping-pong loop both documents forbid.
- Product altitude terminates at the CTO **as a recommendation**, never as an
  open question.

### What never travels at all

| Never | Why |
|---|---|
| Resource → resource **dispatch** | recursive fan-out with nobody holding a global count |
| Higher altitude → lower altitude **reply** | ping-pong; the fix is new work via the router |
| Same-altitude escalation | there is no decision authority to hand to |
| One resource's **output** to another reviewing the same artifact | anchoring; independence is the condition under which multi-agent wins at all |
| A **transcript** | briefs are self-contained by construction; a pointer to "what was said" decays |
| Anything into another resource's **brain store** | isolation is mechanical (`docs/memory.md`) |

## What actually reduces the CTO's load — no headcount required

The CTO's complaint is real: every dispatch decision routes through their chat
window. But the cost is not *that* the router lives there. It is that the
router is being run **one task at a time**, as a lookup table, when it is
designed to be run **once per intent**, as a decomposer.

The load is meant to be **per run, not per task**:

1. The CTO states intent once — the goal and the why, not a task list.
2. `/assign` decomposes it into the whole run graph: nodes, dependency edges,
   file surfaces, shared-resource locks, effort per node.
3. It writes the self-contained briefs and **dispatches the entire wave**,
   preferring a split that yields parallel nodes over sequential ones
   (`skills/assign` §4).
4. It reports back **once**, integrated, with what contradicted each brief and
   what was not verified.

One CTO turn in, one integrated report out, N resources in between. That is a
usage change, it is free, and it addresses the actual complaint. If it is still
too much after that, the next lever is **fewer resources**, not more — see the
retirement finding in `ledger/gaps/2026-08-16-dispatch-has-no-owner.md`.

## Does the org model change any of this? — No, and it strengthens two of them

Added 2026-08-17, when the CTO specified that the roster should model an
organisation with many people per role (`docs/org-model.md`). Re-checked against
that goal rather than the one this file was written against:

**Reporting lines: unchanged, and the org framing makes the argument stronger.**
A real org has managers because authority and information must be distributed
across people who cannot all be in the room. **Here the CTO's window *is* the
room** — every dispatch already passes through it. A management layer inserted
into a one-room org does not remove decisions from the room; it removes
*visibility* of them while leaving the accountability in place. The mechanical
objection above is independent of framing and also unchanged: a subagent's
context dies at hand-back, so a router-as-resource moves the run graph from the
longest-lived context in the system to the shortest.

**Dispatch, graph 1: one hop still, but the target is now a *person*.** The
router matches a request to a **role** on its capability id, then picks a person
who holds that role and is not already live — **one person, one live agent**
(`protocol.md` §6). Running out of people is a hiring signal, not a spawning
one. Nothing about the graph's shape changes; what changes is that its leaves
have names that mean one worker each.

**Escalation, graph 2: unchanged.** Altitude is a property of the *role*, so
two people in one role escalate to the same place. Seniority does not shorten
the ladder — an L3 implementer still escalates to behavior, because the ladder
is about which question you may answer, not about how trusted you are.

**Chief of Staff.** The CTO referred to one on 2026-08-17. **It does not exist**
in this repo — not in `registry.yaml`, this file, the README, or any ledger
entry. It is not `roster-steward` under another name: Anubis owns *who is on the
team and whether they earned it*, and is explicitly forbidden from dispatching
anyone. The function it names — running the principal's office and allocating
work — is the **router's**, and the router is a skill rather than a person for
the reasons above. The org framing genuinely re-opens whether that should
change; it is a hire, with its own recurrence record, and
`ledger/gaps/2026-08-17-registry-models-roles-not-people.md` names it as the
first open question the org model creates. Not hired.

## Where each resource sits

| Resource | Callsign | Altitude | Dispatched by | Escalates to | Terminal on |
|---|---|---|---|---|---|
| `implementer` | Samwise | implementation | router | behavior, target named in brief | — |
| `adversarial-reviewer` | Heimdall | behavior | router | `architect` | — |
| `tenant-visibility-tester` | Argus | behavior | router | `architect` | — |
| `content-auditor` | Mimir | behavior | router | `architect` | — |
| `design-reviewer` | Bagheera | behavior | router | `architect` | — |
| `deployment-engineer` | Cerberus | behavior | router | `architect` | — |
| `architect` | Jarvis | product | router | CTO | product shape |
| `roster-steward` | Anubis | product | router | CTO | team shape |

Nobody reports *to* another resource. Everyone is dispatched by the router and
accountable to the CTO. "Who reports to who" has a one-line answer: **everyone
reports to the CTO through the router, and no resource manages another.**
