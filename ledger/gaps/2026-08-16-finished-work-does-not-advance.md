---
date: 2026-08-16
requested_by: CTO (via router)
capability: dispatch.advance, dispatch.queue, work.scheduling
product: v-team (this repo)
status: not-hired
verdict: guard-only — `scripts/pending.sh` + a done-condition on the router's run
decided_by: roster-steward (Anubis)
---

## Requested

A hire. The router named the gap and handed over the evidence:

> "why was it not completed till I asked?"

> "what are you waiting for, run ci locally, raise pr and merge, why do I have
> to babysit?"

The mechanism, from the router's own account: Bagheera delivered a build-ready
design for the public workspace page; it sat undispatched. Jarvis was dispatched
instead on a go-live question that did not gate the build. Both results were
reported and the run stopped. The build did not start until the CTO asked.
Separately, four PRs sat open — two green — until he told the router to merge.

The structural claim attached to it: `docs/protocol.md` §3 sends work "back to
the **router** as new work"; the protocol names a router and the roster does not
contain one; so in practice the CTO's window is the router, which is what his
standing *everything must be delegated* rule exists to prevent.

## VERDICT — **NO HIRE.** Deliverable: `scripts/pending.sh` and `skills/assign` §8.

This is the **second** time this question has been asked and refused. The first
is `ledger/gaps/2026-08-16-dispatch-has-no-owner.md`. I re-ran every check
rather than citing myself, because new evidence had arrived and a prior verdict
is not an argument. **The new evidence changed the remedy and did not change the
verdict.**

## The four /hire checks

### 1. Recurrence — **MET. Three dated artifacts, all 2026-08-16.**

The bar has never been met before on this team; it is met here, and the honest
consequence is that a remedy is owed — not that a person is.

1. `ledger/gaps/2026-08-16-dispatch-has-no-owner.md` — the CTO: *"I don't have
   to handle the delegation of all resource, who is at the top level?"*
2. `ledger/runs/2026-08-16-org-and-hiring.jsonl` L0.3, verbatim: Cerberus's
   promotion was refused partly because its record was *"absent from ledger
   (**ROUTER's failure to close the graph**)"*. A dated artifact naming the
   router failing to advance work, written before today's complaint.
3. Today's two quotes.

### 2. Gap, or bad decomposition? — **Neither, and this is the finding.**

It is a **missing done-condition**, which is the single largest measured failure
category (specification and design, 41.8% — `docs/protocol.md` provenance).

`skills/assign` already owns every part of the job: name the capability, check
coverage, rate difficulty, order dependencies, write the brief, dispatch,
record the graph. The router did not fail to *know* any of that. It failed to
*stop correctly*: it reported two results and ended its run while a build-ready
deliverable had nowhere to go. **Nothing in the skill said its run was not over.**

That is precisely the shape `docs/protocol.md` §1 exists for. Every *resource*
declares a done-condition. **The router declared none** — the one participant
whose termination decides whether anyone else's output ever moves.

### 3. Guard before resource — **YES, and this time it fires.**

**Why the previous remedy failed, stated plainly.** Last time I wrote
`docs/delegation.md` and called it sufficient. It was prose, prose does not
fire, and the behaviour recurred within a day. My own definition names this
anti-signal — *"solving a performance problem by adding rules… is 'try harder'
with extra tokens"* — and I committed it. Writing the same document again, or
writing it into a new resource's file, would be the same mistake with a
headcount attached.

**`scripts/pending.sh`** derives from `ledger/runs/*.jsonl` — artifacts the
router writes about the work, not about itself — and fails on exactly two
things:

| Bucket | Rule | Fails? |
|---|---|---|
| **DROPPED HANDOFF** | terminal `escalated` or `handed-back`, no child node | **yes** |
| **DISPATCHED, NEVER CLOSED** | `dispatched`, no later record | **yes** |
| COMPLETE, NOTHING AFTER | terminal `complete`, no child, not the run's last node | no — reported |
| BLOCKED | `blocked_on` set | no — waiting correctly |

The rule needs no heuristic about which deliverables "look important", because
**the terminal state already carries it**: §1 defines `complete` as nothing
outstanding, `handed-back` as partial *"with what remains"*, and `escalated` as
a question for someone else. The last two are unfinished by definition.

A first cut flagged every childless terminal node and returned 14 — mostly runs
that had legitimately ended. Sharpening to those two states cut it to **4 real
findings on today's data**, every one of them genuine:

```
DROPPED HANDOFF (3)
  admin-sidebar-affordance  L0.1  design-reviewer  [escalated]
  attribution-guard         L1.2  deployment-engineer  [handed-back]
  resources-panel           L0.4  tenant-visibility-tester  [handed-back]
DISPATCHED, NEVER CLOSED (1)
  admin-sidebar-affordance  L0.5  implementer
```

**Wired to fire without anyone remembering:** `beat.sh` runs every 6 hours via
launchd and already writes the journal, so the check runs there and journals a
line when anything waits. A thing on a timer is the literal answer to *"why do I
have to babysit?"*; a person who remembers is not.

**Paired with a done-condition** (`skills/assign` §8): the router does not
report to the CTO while `pending.sh` exits non-zero. Each item is advanced, or
explicitly deferred **with a reason in the report**. Silence is what made the
CTO the scheduler, so silence is the thing removed.

**Why the guard is sufficient here, when it usually is not.** Normally I have to
argue why a check cannot replace judgement. Here the judgement half — *who takes
this, at what effort, in what order* — is `skills/assign`, and it is already
written and already owned. The only thing missing was **noticing**, and noticing
is exactly what a script is better at than a person. The residue after this
guard is not resource-shaped.

### 4. Duplicate / overlap — **would have collided with two resources.**

| Test | Result |
|---|---|
| **Subset** | Dispatch is not contained in any existing capability set. |
| **Overlap** | A router that "merges the PRs" collides head-on with `implementer` (`merge-on-green`) and `deployment-engineer` (green branch → production). §6 requires exactly **one** accountable; this would have created a second merge owner on the same artifacts. |
| **Routing** | *"Who takes this?"* → the router skill. *"Should this change exist?"* → Jarvis. *"Should this role exist?"* → Anubis. A fourth entry blurs a list that is currently unambiguous. |
| **Chief of staff** | The CTO previously asked for one to handle v-team merges; refused in `dispatch-has-no-owner` on the same structural grounds, unchanged today. |

## The structural argument, unchanged and still decisive

Both objections from the first refusal survive today's evidence intact:

1. **A resource router is a two-level spawn chain.** `skills/assign` §6 and
   `docs/charter.md` both say resources never spawn. The CTO's window would
   dispatch the router, which would dispatch the workers. The rule either breaks
   or becomes a per-resource privilege — and a privilege is what every future
   hire will cite.
2. **It would move the run graph from the most durable context to the least.** A
   resource's context dies at hand-back; the CTO's session persists across the
   whole run. The router's one job is to hold the graph *for the duration*.
   Making it a resource makes it forget — and "forgot what was outstanding" is
   the exact defect being reported.

Today's evidence says the router **executed** badly. It does not say the router
is in the wrong place. Moving a badly-executed function into a subagent that
forgets between runs makes it worse, not better.

**Altitude, for completeness:** a dispatcher answers *who*, at every altitude at
once. It is not a rung on `implementation → behavior → product`. It sits outside
the ladder as infrastructure — which is what a skill is.

## Answering the four questions I was asked not to dodge

1. **The autonomy tension.** Dissolved rather than resolved: there is no
   resource, so there is no autonomy grant. This matters because the tension as
   posed had no good answer — a `recommend`-only router is the defect wearing a
   new hat, and a router with dispatch authority is a first-day exemption from
   probation, which my definition calls an anti-signal that *invalidates the
   output entirely*. **A question with no acceptable answer on either branch is
   usually a sign the question is mis-shaped.** It was.
2. **What it must never do.** Also dissolved. The named failure — a router that
   becomes a second CTO, re-deciding scope and re-opening settled rulings — is
   unreachable by a script that reports what is waiting and never says who takes
   it. `pending.sh` deliberately does **not** suggest an owner. That line is the
   whole reason it is safe.
3. **The done-condition.** `./scripts/pending.sh` exits 0. Observable, checkable
   against `ledger/runs/`, and it belongs to the router's run rather than to a
   new resource — which is the correct home, because the router is the thing
   that was terminating early.
4. **Is this a hire at all?** No. The routing rule belongs in `skills/assign`
   and the noticing belongs in a script. A resource created to compensate for a
   missing done-condition would be a permanent context cost paid by every reader
   of the registry, in exchange for a `[[ -z ... ]]`.

## Headcount

Stays at **8**. `/retire` still has never been used while headcount went 5 → 6 →
7 → 8, and my scorecard says a period with no retirement is a finding about me.
Refusing this hire is not a retirement and does not discharge that.

## Brain sources

**No resource was created, so no gbrain source was created, and none was
needed.** Recorded explicitly because the hire brief instructed me to create and
verify one — that instruction is void along with the hire, and a source created
for a resource that does not exist would be exactly the orphan-store defect
(`ledger/escapes/2026-08-16-hire-path-no-brain-source.md`) arrived at from the
opposite direction. Nothing was written to any brain during this run.

## What contradicted the brief

- **"The protocol names a router and the roster does not contain one."** True,
  and it is not a defect. `skills/assign` is the router; it is a skill on
  purpose, argued in `dispatch-has-no-owner` and unchanged. A protocol naming a
  skill is not a protocol naming a vacancy.
- **The proposed done-condition would have been vacuously green on the very
  incident that prompted it.** The brief suggested checking that "no `complete`
  deliverable with a build-ready done-condition remains undispatched" against
  `ledger/runs/`. **There is no run file for the Bagheera public-workspace-page
  dispatch.** The router did not record it. So the check as proposed would have
  passed while the incident was happening, and the deeper defect is one layer
  down: *the run graph is not being written*. That is already on the record —
  `2026-08-16-org-and-hiring.jsonl` L0.3 refused Cerberus's promotion partly
  because the ROUTER had not closed the graph. `pending.sh` says this limitation
  in its own header rather than letting a green run imply proof.
- **"Six of eight resources cannot advance their own work by design."** Correct,
  and it is the design working. Recommend-only is how trust is earned. The
  problem was never that they cannot self-advance; it is that nothing noticed
  when the thing that advances them stopped.
- **"You design the role… do not ask me to specify it."** I did not design one.
  The brief granted refusal authority explicitly and this is the refusal.

## What I did NOT verify

- **That the router will honour the new done-condition.** No guard can force it:
  `skills/assign` §8 is read by the CTO's own session, and nothing lints a
  session. `pending.sh` makes the state *visible and non-zero*; acting on it
  remains a habit, which is the same class of thing that just failed. I am
  saying so rather than claiming the loop is closed. If it recurs a third time,
  the honest next move is not a hire either — it is `record.sh` reconciling run
  files against landed commits, which protocol §7 already names as the unbuilt
  piece.
- **The four open PRs.** I did not inspect their CI state or merge them. Merging
  is `implementer`'s (`merge-on-green`) and `deployment-engineer`'s; me doing it
  would create the second-accountable defect I just refused to hire.
- **`beat.sh` end-to-end under launchd.** I verified `pending.sh` directly and
  syntax-checked `beat.sh`; I did not wait out a 6-hour launchd window or run
  the full beat, which calls a model per resource.
- **The live gbrain source list**, still — PGLite lock held by a running
  `gbrain serve` for this whole session.
