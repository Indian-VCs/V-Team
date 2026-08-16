---
date: 2026-08-17
requested_by: CTO — "we want a team which replicates the actual org structure in an organization"
capability: team.registry-honesty, team.callsign, team.probation
product: v-team (registry shape)
status: design-ruling
verdict: adopt the person axis — roles keep capability/altitude/refusals, people get callsign, persona, autonomy, memory and record. No hire, no rename, one field refused.
decided_by: roster-steward (Anubis)
overturns: ledger/gaps/2026-08-16-capacity-is-instances-not-roles.md (its framing, not its no-hire)
---

## Requested

The CTO, verbatim:

> *"we want a team which replicates the actual org structure in an organization.
> L1 resources can be many, L2 can be many, and L3 can be many. Chief of Staff is
> one for now, but other roles and titles can be many. Hiring can be done based
> on the need, but the same agent or person should not be invoked twice because,
> in the real world, one person can take only one task. He can take multiple
> tasks at a time, but he cannot be cloned multiple times. That's what I mean,
> and it is necessary to have a persona for each one."*

And on memory, the same day:

> *"It is okay to have access when isolation is search-scoped and access is not
> controlled. As long as that is disciplined and accessing a specific source, it
> is okay."*

**Trigger.** On 2026-08-16 four `implementer` instances ran concurrently on four
disjoint units of work. One callsign, one gbrain source (`samwise`), one
projected track record. Only the `V-Team-Run:` trailer distinguished them.

## VERDICT — **adopt the person axis.** Deliverable: `docs/org-model.md`.

Full design and the four-stage migration are in `docs/org-model.md`. Recorded
here: every check and its answer, including the ones that failed, and the two
places I was corrected mid-task.

**This overturns the framing of `2026-08-16-capacity-is-instances-not-roles.md`,
and I am saying so rather than letting the two entries sit and contradict each
other.** That entry held that *"the registry describes roles, not headcount"*
and that cloning one is correct staffing. Its no-hire was right on its own
terms; its premise is now false by CTO ruling. Cloning is forbidden. The ledger
is append-only, so this entry is the correction — the earlier one is not
rewritten.

## Two corrections I was handed mid-task, both of which changed the output

1. **`validate.sh` 4b was named as *"the thing standing in the way."* It is
   not.** 4b is the mechanical half of the `/hire` overlap test: it stops a
   `code-writer` being hired beside `implementer` — the same job under a new
   label. A person declares no capabilities; the role does. **4b never sees a
   second implementer person, is untouched by this design, and must not be
   weakened.** The real bijection lives in `validate.sh` 4f, `validate.sh` 4h,
   `record.sh` `callsign_of()` and `docs/memory.md`'s source-id rule. Had I not
   been corrected I would have aimed at the wrong rule.

2. **Memory was named as the hard part. It is not.** The indistinguishability I
   was asked to solve was a symptom of *cloning*: four instances shared `samwise`
   because they were one person invoked four times. The org model dissolves it —
   each person is a row, so each person gets a source, and gbrain already does
   per-source isolation. My earlier draft argued that splitting a shared store
   was a performance regression; **that argument was aimed at cloning and does
   not survive the ruling.** Recorded because it was wrong, not quietly dropped.

## The checks

### 1. Recurrence — **MET, with two dated artifacts.**

Not a hire, so the bar is not the operative test — but I ran it rather than
skipping it, because skipping it is how the bar dies.

1. `ledger/gaps/2026-08-16-capacity-is-instances-not-roles.md` — three
   concurrent instances of one role, one name, one store.
2. Four concurrent instances on 2026-08-17, plus the CTO's own question
   *"Samwise is one person, how does multiple Samwise spawned up?"*

Two dated occurrences of one underlying observation: **the file cannot count
people.** That is a genuine recurrence and it is why this got a design ruling
rather than a one-line answer.

**Still not met, and recorded again:** a *capability* gap. `known_gaps` lists
`infra.ci`, `infra.cloudflare-workers`, `security.review` and `data.migration`,
and **zero** dated artifacts in `ledger/gaps/` or `ledger/escapes/` name any of
them. Nothing here is an argument to hire for coverage.

### 2. Gap, or bad decomposition? — **The request separates into four things,
and only two of them need the registry to change.**

| Asked for | Where it lives now | What this design does |
|---|---|---|
| **persona per person** | the prose and `never:` list of `resources/*.md` — **not** the `persona:` field | splits the file: role = job, person = voice, `sync.sh` composes the agent file |
| **title** | `callsign`, on the role | moves to the person |
| **L1/L2/L3** | `autonomy`, on the role | moves to the person; the role keeps a ceiling |
| **memory** | one source per callsign | unchanged in design — one source per person falls out of person rows |

The finding is the first row. **As long as one file holds both the job and the
voice, every person in a role has the same voice.** "A persona for each one" is
therefore a file split, not a new field, and it is the largest piece of work in
the migration.

### 3. Guard before resource — **three new checks are real, one rule cannot be
checked at all, and I am saying which is which.**

Mechanically checkable, and specified in `docs/org-model.md`:

- every **newly added** person row starts at `recommend` (L1) — same shape as
  the existing check 6, scoped to the base ref;
- no person's `autonomy` exceeds their role's `autonomy_ceiling`;
- callsign uniqueness across `people:` **and** `retired_callsigns:`, and every
  role has at least one person.

**Not checkable, and I am not shipping a check that cannot fire.** *"One person,
one live agent"* constrains the router. Detecting a second live copy needs an
artifact recording live dispatches; that artifact was `ledger/runs/*.jsonl`,
deleted on 2026-08-16
(`2026-08-16-trailer-projection-has-no-substrate.md`), and `pending.sh` was
built to read it and is dormant for exactly that reason. **This project has
already found four guards that were green because they never ran** — 4g on a
locked brain, 4h before it existed, `check-attribution.sh` on a retired
callsign, and `sync.sh --check` which nothing invokes. A fifth would be worse
than nothing. So the rule is written into `protocol.md` §6 and
`skills/assign` §6 and **honoured by hand**, and restoring the dispatch record
is named as stage 4 of the migration.

### 4. Duplicate / overlap — **the tests now separate a person from a role,
which is the point.**

| Test | Result |
|---|---|
| **Subset** | A person declares no capabilities, so there is nothing to be a subset of. A *role* whose capabilities are a subset of another is still a scope note, not a hire — unchanged. |
| **Overlap** | None. `retired_callsigns:` and `.v-team-callsigns` already map N callsigns → 1 resource id, and PR #102's roster guard already resolves that shape. **The alias structure this needs exists and is proven in production.** |
| **Routing** | `/assign` still matches a capability to a **role**. Choosing *which person* is a dispatch decision, made from availability under the one-live-agent rule — not a routing ambiguity, because capability never distinguished them anyway. |
| **Naming** | The one-clause test cannot separate two holders of one job. **Amended** — see below. |

### 5. Callsign — **the rule is amended, by me, and the amendment is the tighter
reading.**

A callsign is a character, that character is not human, and the name encodes the
job — defensible in one clause. The third clause breaks under
many-people-per-role. The amendment:

> **The name encodes the job for a role with one person, and the persona for a
> role with several.** Species and one-clause-defensibility are unchanged.

This is not a loosening. Two people whose personas cannot be told apart in one
clause **have no defensible names** — and that is the same fact as *this is one
person with two names*, which is the cloning the model exists to forbid,
re-entering through the roster. The naming rule ends up doing the work the
routing test can no longer do.

### 6. Effort — **stays on the role. Refused as a person property.**

Raised mid-task: `effort` is declared per resource and **never read by the
dispatcher** — every agent on 2026-08-17 ran on the session model with no
override. The question put to me was whether levels should govern it.

**No.** Three reasons, weight order: the repo already defines effort as a
property of the *work* (`registry.yaml` header, `docs/difficulty.md`, and the
per-task escalation clauses already in the file); a deliberately weaker person
is pure loss and is an anti-signal in my own definition; and per-person effort
builds a **self-certifying seniority trap** — a junior given a smaller model
produces worse work, earns a worse record, and never promotes.

`autonomy` governs what you may do **unapproved**. `effort` governs how much
thinking **this task** gets. A new L1 on a hard task gets high effort and
recommends rather than merges. That is what probation is for.

**And the guard question, answered honestly: nothing can check it, and the
instruction already exists.** `skills/assign` step 3 is titled *"Rate
difficulty, and pick effort from it"* and was not honoured. **The defect is an
unexecuted rule, not a missing one** — adding a sixth sentence to a skill that
already contains the right one is the anti-signal my definition calls "try
harder with extra tokens".

What is actually missing is that **no artifact records what a dispatch chose**.
That absence is shared by three rules — one-live-agent, effort-from-difficulty,
and the brief's declared escalation target — and it is why restoring the
dispatch record is stage 4 of the migration rather than an optional improvement.
I am not shipping a guard for any of the three before that substrate exists.

**Registry-honesty finding, logged and deliberately not acted on.**
`implementer` declares `effort: low` and produced the two longest observed runs
of the day (33 and 26 minutes) at maximum model. A declared default contradicted
by observation is exactly what `team.registry-honesty` covers. I am not changing
the value: effort is difficulty-derived, two runs on one day is evidence of a
mismatch rather than a re-derivation, and the fix is the router resolving per
task. Recorded so the next reader has the datum and the date.

## Chief of Staff — established, not hired

It does not exist. The eight roles are `content-auditor`,
`tenant-visibility-tester`, `adversarial-reviewer`, `implementer`,
`design-reviewer`, `deployment-engineer`, `roster-steward`, `architect`. Nothing
in the registry, README, `docs/delegation.md` or any ledger entry names a Chief
of Staff.

**It is not me under another name.** I own *who is on the team and whether they
earned it*; a chief of staff runs the principal's office and **allocates work** —
an accountability my own definition explicitly forbids me.

**The function it names is the router's.** `/assign` is a skill held by the
CTO's session. I refused to make it a resource this morning
(`2026-08-16-dispatch-has-no-owner.md`) on a mechanical ground the org model does
not touch: a subagent's context dies at hand-back, so a router-as-resource moves
the run graph from the longest-lived context to the shortest, and forces a
two-level spawn chain. **The org framing genuinely re-opens the question** —
*"Chief of Staff is one for now"* describes a person — but it is its own hire,
with its own recurrence record, and the mechanical objection is what it has to
answer. **Not hired here.**

## Memory — closed, and it strengthens the case

**Search-scoped isolation is decided sufficient**, per the CTO ruling quoted
above. Discipline is the mechanism; each person passes their own `--source`, and
§4's independence rule rests on that exactly as it does today. **Recorded as
decided rather than tolerated**, so the next reader does not re-open it as a
defect and start designing access control. Its implication cuts *for* the second
axis: a person costs a row and a source id, with no permission model behind
either.

**One item stays open, and the design assumes it lands.** The V-Team brain is
PGLite and single-writer; N people writing concurrently need the server to
serialise. Verified again today, verbatim:

```
GBrain's local database is already open through `gbrain serve` (MCP, PID 93398).
This brain uses PGLite, so a separate CLI process cannot open it at the same time.
```

A parallel run is moving resources to HTTP MCP. **This design assumes that
lands**; until it does, per-person stores are declarable but not reliably
writable.

## What is refused — two things

1. **A `level:` field.** L1/L2/L3 is `autonomy` with a friendlier name —
   `recommend` / `branch` / `merge-on-green` is already the ordering, and
   probation is already its lowest state. Storing both is a drift bug waiting
   for its first disagreement, and my brief told me not to invent a field that
   duplicates one I own. Level is a **display name**, derived from the field
   that already exists.
2. **Per-person `effort`.** Check 6 above. Level governs authority, never
   capability.

Everything else the CTO specified is adopted.

## Headcount

Unchanged at **8 roles / 8 people**. Stage 1 of the migration seeds one person
per existing role carrying that role's current callsign, persona and autonomy —
zero new names, zero behaviour change. `/retire` still has never been used, and
my own scorecard still says a period with no retirement is a finding about me;
the org model does not discharge that, and the `skills/retire` "no work" trigger
remains suspended (`2026-08-16-runs-deleted-guards-left-pointing.md`).

## What contradicted the brief

- **"`validate.sh` 4b is the thing standing in the way."** Withdrawn by the
  coordinator mid-task, and the withdrawal was correct. Recorded above.
- **"Memory is the hard part, and it is the reason this matters."** Also
  withdrawn, also correct. Memory is the part the org model makes *easier*: stop
  cloning and the shared-store problem disappears, because the sharing was the
  cloning.
- **"Isolation is search-scoped, not access-controlled"** — I had it listed as a
  standing risk. It is now a decision. Removed from the risk list and recorded
  as decided.
- **"An org usually also has a level."** True, and this repo already has it. The
  defect was that it was attached to the role rather than to the person. No new
  field.
- **My own 2026-08-16 entry**, which said cloning *"is correct staffing, and
  nothing prohibited it."* Something prohibits it now. The sentence was true when
  written and is false today; both facts are in the ledger.

## What I did NOT verify

- **That four instances actually ran concurrently, and on disjoint surfaces.** I
  took the coordinator's account. `ledger/runs/` is deleted, so the `surfaces`
  field that would settle it no longer exists. This premise was unverified on
  2026-08-16 and is still unverified; it underpins both rulings.
- **The V-Team brain, at all.** Unreachable — PGLite lock held by `gbrain serve`
  (PID 93398). I did not read `anubis` or `default`, so anything either store
  holds about prior org rulings is absent from this reasoning.
- **`record.sh` output.** I read the projection code and reasoned from it; I did
  not run it, so I did not observe four instances landing in one bucket. It is
  derived from `callsign_of()`, which returns one callsign per resource.
- **That `sync.sh` can compose two files into a valid agent file.** The design
  depends on it. I did not prototype the composition, and I did not test whether
  a composed file still passes `validate.sh` 4h's three assertions.
- **PR #102 and `.v-team-callsigns` against the live guard.** I stayed out of the
  product repo entirely. The claim that the roster file needs no format change is
  read off `sync.sh`, not tested against `check-attribution.sh`.
- **Whether any resource file's embedded protocol copy needs the new §6
  sentence.** I judged not, to avoid re-probating eight resources under
  `validate.sh` 6; I did not test what a resource does when a brief names a
  constraint its own file does not carry.
