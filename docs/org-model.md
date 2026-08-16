# The org model — roles, people, levels

Written 2026-08-17 by `roster-steward` (Anubis), in answer to the CTO:

> *"we want a team which replicates the actual org structure in an organization.
> L1 resources can be many, L2 can be many, and L3 can be many. Chief of Staff is
> one for now, but other roles and titles can be many. Hiring can be done based
> on the need, but the same agent or person should not be invoked twice because,
> in the real world, one person can take only one task. He can take multiple
> tasks at a time, but he cannot be cloned multiple times. That's what I mean,
> and it is necessary to have a persona for each one."*

This **overturns** the framing of
`ledger/gaps/2026-08-16-capacity-is-instances-not-roles.md`, which held that the
registry describes roles and that cloning one is correct staffing. Cloning is
now forbidden. The checks are re-run and recorded in
`ledger/gaps/2026-08-17-registry-models-roles-not-people.md`.

**Nothing is hired and nobody is renamed in this PR.** This is the model and the
migration; the first migration PR is named at the end.

## The ruling, in one sentence

**`registry.yaml` gains a second axis: `resources:` stays the catalog of *roles*
and keeps capability, altitude and refusals, while a new `people:` block holds
the things that belong to a person — callsign, persona, autonomy, brain source
and track record — so that a role may have many people, each with one live
agent, and `validate.sh` 4b keeps doing its correct job of refusing two *roles*
that do one job.**

## The two axes, and which field sits on which

| Field | Axis | Why |
|---|---|---|
| capability id | **role** | the routing key `/assign` matches on. Unique across roles — this is 4b, unchanged |
| altitude | **role** | which question you may answer is a property of the job, not of seniority |
| surfaces | **role** | what the job is allowed to touch |
| `never:` | **role** | the hard refusals are the job description |
| escalation target | **role** | resolved by altitude, declared per brief |
| `autonomy_ceiling` | **role** | the most anyone in this job may ever hold |
| `effort` | **role default, resolved per task** | how much thinking the *work* needs — never a property of the worker |
| **callsign** | **person** | the unit of address and of attribution |
| **persona** | **person** | the CTO's requirement, and it is a real change — see below |
| **autonomy / level** | **person** | one implementer merging while another only branches |
| **brain source** | **person** | `--source <callsign>`, one store per person |
| **track record** | **person** | `record.sh` projects per callsign; per-person falls out for free |
| **probation state** | **person** | derived from autonomy, not stored separately |

### `validate.sh` 4b stands, unweakened

4b makes capability ids unique across resources. Two **roles** declaring
`code.implement` is duplication wearing a different name and 4b is right to
refuse it. **A person declares no capabilities** — the role does — so two people
in one role never trip it. The rule is untouched by this design and must stay
that way.

What actually has to change is the callsign↔role **bijection**, which lives in
`validate.sh` 4f, `validate.sh` 4h, `record.sh` `callsign_of()`, and
`docs/memory.md`'s source-id rule. None of those is 4b.

## Level is `autonomy`, renamed for humans — no new field

L1/L2/L3 is seniority. Altitude is *what questions you answer*. **They are
different axes and must not be conflated**: a senior and a junior implementer
both answer implementation-altitude questions, and differ only in what they may
do unapproved.

This repo already stores seniority. It is called `autonomy`, it is already an
ordering, and probation is already its lowest state:

| Level | `autonomy` | Means |
|---|---|---|
| **L1** | `recommend` | on probation. Proposes; the CTO or a higher level acts |
| **L2** | `branch` | opens PRs on its own judgement; does not merge |
| **L3** | `merge-on-green` | merges its own green work, inside its role's ceiling |

**Only `autonomy` is stored.** `L1/L2/L3` is the display name used in the README
and in briefs. A separate `level:` field would be a second name for the same
ordering, and two fields that must agree are one field plus a drift bug. This is
the field I already own; I am not inventing one beside it.

**The role keeps a ceiling.** `autonomy_ceiling` on the role is the highest any
person in that job may ever reach. It is what lets the registry keep saying
things it currently says truthfully — `architect` decides nothing,
`roster-steward` is recommend-only and may never merge its own hires — while
people below it vary. Two rules then hold together instead of fighting:

- **every new person starts at `recommend` (L1).** No exceptions, no first-day
  exemptions. Mechanically checkable against the base ref, exactly like the
  existing check 6 for changed resources.
- **no person exceeds their role's ceiling.** Mechanically checkable outright.

Trusting one implementer currently trusts all of them, because autonomy is
stapled to the role. This is the fix, and it is the strongest single argument
for the second axis.

## Persona moves to the person — and this is the real work

**A finding first: persona is not currently in the `persona:` field.** That
field is a label pointing at `personas/variants.md`. The actual voice lives in
the prose and the `never:` list of `resources/<name>.md` — Bagheera returning a
measurement or nothing, Cerberus refusing to ship what it cannot roll back,
Jarvis stating a verdict and stopping, Mimir returning `CANNOT VERIFY` rather
than something plausible. Those voices are the part of this system that is
working, and nothing here rewrites them.

The consequence for the org model is exact: **as long as one file holds both the
job and the voice, every person in a role has the same voice.** "A persona for
each one" therefore requires splitting the file — not adding a field.

```
resources/<role>.md     the JOB    — mission, capabilities, surfaces, never,
                                     escalation, the embedded protocol copy
people/<callsign>.md    the PERSON — persona (what it looks at first, what it
                                     refuses), level, brain source, "You are X"
```

**Neither is the dispatch surface.** Claude Code loads one self-contained file
per agent and has no include mechanism, so `sync.sh` **composes** them:

```
resources/<role>.md  +  people/<callsign>.md  ->  <product>/.claude/agents/<callsign>.md
```

One generated file per person, named by callsign — which is also what makes a
*person* dispatchable at all, instead of a role that the router silently
instantiates N times. The sources stay de-duplicated, so the role's rules exist
once and cannot drift between the people who hold them. Forking the whole file
per person is what 4b's judgement half exists to refuse, and composition is the
way to have per-person voice without it.

**The cost, honestly:** two files per person instead of one, a generated
artifact in `.claude/agents/` that must never be hand-edited (already true), and
`sync.sh --check` becomes the only thing standing between a stale mirror and a
resource running yesterday's rules — which today is a habit, not a guard
(`ledger/gaps/2026-08-16-callsign-not-on-the-dispatch-surface.md`).

### The callsign rule, amended

I own `team.callsign`. The rule is: a callsign is a **character**, that
character is **not human**, and the name **encodes the job**, defensible in one
clause.

The third clause breaks under many-people-per-role: no clause distinguishes two
implementers on anything except *"also an implementer"*. The amendment, and it
is mine to make:

> **The name encodes the job for a role with one person, and the persona for a
> role with several.** Species and one-clause-defensibility are unchanged.

That is not a loosening. It restores the test's purpose — a name has to mean
something — in the case where the job alone can no longer carry it. Two
implementers whose personas genuinely differ (conventions-first; a refactor
hawk) have two names that each encode a real difference. **Two people whose
personas do not differ have no defensible names, which is the naming rule doing
exactly the work the routing test would otherwise have to do.**

## Effort stays on the role — level governs authority, never capability

The CTO's L1/L2/L3 question and *"do you dispatch different models by level"*
look like one question. **They are not, and collapsing them is the one place
this org model could do real damage.**

`effort` is currently declared per role and, as of 2026-08-17, **never read by
the dispatcher** — every agent ran on the session model with no override. That
is the same defect as the callsign one: the registry states a field, the router
never consults it, and nothing notices. See below for why no guard closes it.

**Ruling: `effort` stays on the role, as a default, and does not become a person
property.**

Three reasons, in order of weight:

1. **It is already a property of the work, not the worker**, and the repo has
   said so from the start. `registry.yaml`'s own header: *"Effort = selected by
   TASK DIFFICULTY, not by identity. The value here is the resource's default;
   the router overrides it per task."* `docs/difficulty.md` defines difficulty as
   **inverse gate coverage**. The escalation clauses already in the file —
   *"escalates with task difficulty"*, *"→ high on low-gate-coverage surfaces"* —
   are per-task by construction. A field that is resolved per task cannot be
   owned by a person.

2. **A deliberately weaker person is pure loss.** The README says it plainly:
   *"There is no 'junior' that is deliberately worse."* My own definition makes
   it an anti-signal — personas vary on what they look at first and what they
   refuse, **never on competence**. In a human org seniority buys better
   thinking because you cannot issue a junior more of it. Here you can, so
   withholding it is a choice with no upside: the same task, done worse, by
   someone whose record then shows it.

3. **Per-person effort builds a trap with a mechanism.** A junior given a smaller
   model produces worse work, earns a worse record, and never promotes — a
   self-fulfilling seniority that the ledger would faithfully certify. Autonomy
   has no such feedback loop, because it constrains *what happens to the output*,
   not *how good the output is*.

**So the split is clean and it is the whole point of separating the axes:**

| Axis | Owned by | Answers |
|---|---|---|
| `autonomy` (L1/L2/L3) | **person** | what you may do **unapproved** |
| `effort` | **role default, task override** | how much thinking **this task** gets |

A new L1 implementer on a hard task gets **high** effort — because the task is
hard — and then **recommends** instead of merging. That is what probation is
for. An org that staffs by trust is ordinary; an org that thinks less on a hard
problem because a junior drew it is not.

**Who resolves it, and against what.** The router, at dispatch, from
`docs/difficulty.md` — the role's declared value is the prior, the task's gate
coverage is the evidence, and the resolved effort goes in the brief beside the
done-condition and the budget. `skills/assign` §3 already says exactly this.

**And nothing can check it — the instruction already exists and was not
executed.** This is the sharpest finding in this document, so it is stated
without softening: `skills/assign` step 3 is literally titled *"Rate difficulty,
and pick effort from it"*, and it was not honoured. **The defect is not a missing
rule; it is an unexecuted one**, and adding a sixth sentence to a skill that
already contains the right one is "try harder" with extra tokens — an
anti-signal in my own definition.

What was actually missing is that **no artifact records what a dispatch chose**,
so nobody could notice. That is the same absence that makes the one-live-agent
rule uncheckable and the same absence that makes per-run decisions invisible:

| Rule | Why it cannot be checked today |
|---|---|
| one person, one live agent | nothing records which people are live |
| effort resolved from difficulty | nothing records what effort a dispatch used |
| the brief named an escalation target | nothing records the brief |

**Three rules, one missing substrate.** `ledger/runs/*.jsonl` was that substrate
and was deleted on 2026-08-16; `pending.sh` was built to read it and is dormant.
That is why restoring it is stage 4 of the migration rather than an optional
improvement — it is the single change that makes three hand-held rules
mechanically real. I am not shipping a guard for any of the three before it
exists.

**A registry-honesty finding, flagged and deliberately not acted on.**
`implementer` declares `effort: low`, and today it produced the two longest runs
observed (33 and 26 minutes) at maximum model. A declared default contradicted
by observation is exactly what `team.registry-honesty` is for. I am **not**
changing the value here: effort is difficulty-derived, one day of two runs is
evidence of a mismatch rather than a re-derivation, and the correct fix is the
router resolving per task — which is the ruling above. Logged so the next
reader has the datum.

## One person, one live agent

The CTO's constraint: *"the same agent or person should not be invoked twice…
He can take multiple tasks at a time, but he cannot be cloned multiple times."*

- **One live agent per person.** Not one task — a person may hold several tasks
  concurrently, as one context.
- **More work for a busy person is more work in the same context**, never a
  second copy.
- **More work than the people can hold is a hiring signal**, which is what
  *"hiring can be done based on the need"* means. It is the first legitimate
  capacity argument this repo has had, and it replaces cloning as the answer to
  load.

This constrains the **router**, not the resource. A resource cannot know how
many copies of itself exist; the roster cannot enforce what the dispatcher does.
So it lives in `protocol.md` §6 and `skills/assign` §6, and it reverses what
both of them said as of yesterday.

### Nothing can check this today, and I am not shipping a check that cannot fire

This project has already found four guards that were green because they never
ran (4g on a locked brain, 4h before it existed, `check-attribution.sh` on a
retired callsign, `sync.sh --check` which nothing invokes). I am not shipping a
fifth.

A check for *"is this person already live"* needs an artifact that records live
dispatches. That artifact was `ledger/runs/*.jsonl`, **deleted on 2026-08-16**
when the track record became a projection over commit trailers
(`ledger/gaps/2026-08-16-trailer-projection-has-no-substrate.md`). `pending.sh`
was built to read exactly that and is dormant for exactly that reason.

So, plainly: **the one-live-agent rule is written down and honoured by hand,
and it cannot be checked until the router records what it dispatched.** That
substrate is the precondition, it is the router's surface rather than mine, and
it is named as the next piece of work rather than smuggled in here.

## Memory — the org model dissolves the problem it was blamed for

I argued in an earlier draft that splitting a shared store was a performance
regression. That argument was aimed at *cloning*, and cloning is now gone. With
one person per row:

- **gbrain already does per-person isolation.** `--source <callsign>` is the
  boundary and every resource already has its own store. Each person is a row,
  so each person gets a source. No new concept is needed — only more sources,
  created by `setup-brain.sh`, which already derives them from the registry.
- **Cross-person learning has a home already.** `default` is the federated team
  store; a lesson that generalises goes there, deliberately. A lesson about *me*
  stays in mine. That distinction is the one `docs/memory.md` already draws.

So the memory design needs no change to support the org model. Two things about
it are worth stating, and only one of them is open.

**Search-scoped isolation is sufficient — decided, not tolerated.** CTO ruling,
2026-08-17:

> *"It is okay to have access when isolation is search-scoped and access is not
> controlled. As long as that is disciplined and accessing a specific source, it
> is okay."*

Nothing prevents a person passing another person's `--source`, and nothing needs
to. **Discipline is the mechanism**: each person passes their own, and protocol
§4's independence rule rests on that exactly as it does today. This is recorded
as a decision so a future reader does not re-open it as a defect and start
designing access control.

Its implication for this design is direct and it cuts in favour of the second
axis: **giving every person their own store costs nothing in enforcement.** A
person is a registry row and a source id, and there is no permission model to
build behind either.

**Single-writer contention is the one open item.** N people writing concurrently
need the server to serialise. The V-Team brain is PGLite and single-writer —
verified again today, verbatim:

   ```
   GBrain's local database is already open through `gbrain serve` (MCP, PID 93398).
   This brain uses PGLite, so a separate CLI process cannot open it at the same time.
   ```

   **This design assumes the in-flight HTTP MCP migration lands.** Stated rather
   than assumed silently: until it does, per-person stores can be declared but
   not reliably written.

## Chief of Staff — it does not exist, and here is what it is

The eight roles are `content-auditor`, `tenant-visibility-tester`,
`adversarial-reviewer`, `implementer`, `design-reviewer`, `deployment-engineer`,
`roster-steward`, `architect`. **There is no Chief of Staff**, in the registry,
the README, `docs/delegation.md` or any ledger entry.

It is not me under another name. `roster-steward` (Anubis) owns *who is on the
team and whether they earned it*; a chief of staff runs the principal's office
and **allocates work**, which is a different accountability and one I explicitly
do not hold — my own definition forbids me from dispatching anyone.

The function it names is the **router's**. `/assign` is a skill held by the
CTO's session, not a person, and I refused to make it a resource this morning
(`ledger/gaps/2026-08-16-dispatch-has-no-owner.md`) on a mechanical ground that
the org model does not touch: a resource is a subagent whose context dies at
hand-back, so a router-as-resource moves the run graph from the longest-lived
context in the system to the shortest, and forces a two-level spawn chain that
either breaks the never-spawn invariant or turns it into a per-resource
permission.

**But the org framing genuinely re-opens it**, because *"Chief of Staff is one
for now"* describes a person, and under this model roles are held by people. I
am not resolving it inside a design PR. It is the first open question the org
model creates, it needs its own recurrence record and its own `/hire` run, and
the mechanical objection above is what any such hire has to answer. **Not hired
here.**

## Migration — staged, and no rename or hire in any stage

Every stage is additive or mechanical. **No callsign changes, ever** — trailers
are permanent, five commits naming the retired `Neo` are on prism `master`, and
`retired_callsigns` plus `misattributed_runs` keep resolving them untouched.
`.v-team-callsigns` needs **no format change**: it is already
`<state>\t<callsign>\t<resource-id>`, which is exactly many-callsigns-to-one-role.
PR #102 lands the roster guard in the product repo, and every person emitted by
`sync.sh` resolves through it as `active`.

**Stage 1 — seed `people:` losslessly.** For each of the eight roles, emit one
person row carrying that role's *existing* callsign, persona and autonomy:

```yaml
people:
  - callsign: Samwise
    role: implementer
    persona: conventions-first
    autonomy: merge-on-green      # L3 — carried over, not granted
    since: 2026-08-15
```

Zero new names, zero behaviour change, headcount unchanged at 8/8. This is the
only stage where a person may start above `recommend`, because none of them is
new — and that exemption must be written into the check rather than left to
judgement.

**Stage 2 — move the fields.** Role rows lose `callsign:` and `persona:`;
`autonomy:` becomes `autonomy_ceiling:`. Update in the same PR:

| File | Change |
|---|---|
| `validate.sh` 4f | callsign uniqueness across `people:` **and** `retired_callsigns:`; every role has ≥1 person |
| `validate.sh` 4h | the three dispatch-surface assertions apply per **person** file — stronger than today, not weaker |
| `validate.sh` 4e | `Headcount:` becomes two numbers (roles, people); the README line must state both |
| `validate.sh` 5/6 | autonomy values read from `people:`; a **newly added** person row must be `recommend` |
| **new** 4k | person `autonomy` ≤ role `autonomy_ceiling` |
| `record.sh` | `callsign_of()` → iterate `people:`; the projection groups per person. Trailers already carry the callsign, so this is small |
| `sync.sh` | compose person files; emit one `active` roster row per person |
| `setup-brain.sh` | one source per person (already derives from the registry) |
| `docs/memory.md` | the source table is per person |
| `README.md` | roster table and org chart are per person, grouped by role |

**Stage 3 — split the files.** `resources/<role>.md` keeps the job;
`people/<callsign>.md` gets the persona and `You are <X>`; `sync.sh` composes.
This is the stage that delivers *"a persona for each one"* and it is the
largest. It is last because stages 1–2 are useful on their own.

**Stage 4 — the dispatch record.** Restore an artifact the router writes at
dispatch and clears at hand-back, so *"is this person already live"* becomes
checkable and `pending.sh` wakes up. Router surface, not mine. **Until this
lands, one-person-one-agent is honoured, not enforced.**

## What is refused, and it is two things

1. **A `level:` field.** L1/L2/L3 is `autonomy` with a friendlier name, and
   storing both is a drift bug waiting for its first disagreement.
2. **Per-person `effort`.** Level governs what you may do unapproved, never how
   well you may think. Reasons above; the third one — that it builds a
   self-certifying seniority trap — is the one I would not trade away.

Everything else the CTO specified is adopted.

## What would still change this design

1. **A role whose people genuinely need different capabilities.** That is not a
   person, it is a second role, and 4b will say so.
2. **Two people in one role whose personas cannot be told apart in one clause.**
   By the amended callsign rule, that is one person with two names — and it is
   the cloning this model exists to forbid, re-entering through the roster.
3. **The HTTP MCP migration failing.** Per-person stores are declarable but not
   reliably writable while the brain is single-writer.
