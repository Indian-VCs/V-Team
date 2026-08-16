---
date: 2026-08-17
requested_by: router (dispatch brief), on CTO observation — "I still see multiple samwise, what's happening?"
capability: team.hire, team.probation, team.callsign, team.registry-honesty
product: v-team (registry shape)
status: verdict
verdict: NOT YET — blocked on migration stages 1–3, and unsupported on the case that triggered it. No hire, no callsign minted, no guard shipped here.
decided_by: roster-steward (Anubis)
relates_to:
  - ledger/gaps/2026-08-17-registry-models-roles-not-people.md
  - ledger/gaps/2026-08-16-capacity-is-instances-not-roles.md
  - docs/org-model.md
---

## Requested

The router asked for a second `implementer` person, on a CTO observation quoted
verbatim in the brief:

> *"I still see multiple samwise, what's happening?"*

The brief's stated cause:

> *"the roster holds exactly **one implementer person**. When two units of
> implementation work arrive together, the dispatcher's only options are to queue
> the second behind the first or to clone."*

And its stated premise:

> *"`people:` now exists, so a second person in the `implementer` role declares
> **no capabilities at all** — 4b never sees them. You established this yourself
> in #17."*

## VERDICT — **not yet.** Two independent grounds, either sufficient.

Ground 1 is a fact about the repo and it is blocking. Ground 2 is an argument
about the evidence and it would stand even if ground 1 were cleared. I record
both because clearing the first does not clear the second, and a reader who
closes only the blocker would hire on a case that does not hold.

---

## Ground 1 — **`people:` does not exist.** The premise of the brief is false.

Checked against **merged `main`** at `089317f`, after both PR #16 and PR #17
landed during this task:

| Asserted | Actual |
|---|---|
| `people:` axis exists in `registry.yaml` | **absent** — `grep '^people:' registry.yaml` returns nothing |
| a person row carries `autonomy` | **absent** — no `autonomy_ceiling` in `registry.yaml` or `scripts/validate.sh` |
| `people/<callsign>.md` files exist | **absent** — no `people/` directory |
| callsign lives on the person | **false** — all eight `callsign:` keys are role-row fields, lines 38–196 |

**PR #17 shipped the ruling, not the migration**, and says so in its own text:

> *"Nothing is hired and nobody is renamed in this PR. This is the model and the
> migration; the first migration PR is named at the end."*

Its files are `README.md`, `docs/delegation.md`, `docs/org-model.md`,
`docs/protocol.md`, `skills/assign/SKILL.md` and one ledger entry. **It does not
touch `registry.yaml` at all.** Stages 1 (seed `people:`), 2 (move the fields)
and 3 (split the files) are all unbuilt.

**The consequence is exact.** Today a second implementer can only be a second
row under `resources:`. A `resources:` row must declare capabilities. It would
declare `code.implement`, and `validate.sh` 4b would refuse it — *"capability
'code.implement' is declared by more than one resource"*. That is 4b doing its
correct job of refusing two **roles** that do one job, and my brief forbids
weakening it. **I agree with the brief and will not weaken it.**

So the hire is not merely unwise today. **It is unexpressible.** This is the same
mechanical wall as this morning's refusal, and the brief is right that the wall
was supposed to have moved — it just has not moved yet. The premise was true of
the *design* and false of the *registry*, and I am required to argue against the
registry.

### And the migration order flips for a hire — a finding #17 did not anticipate

`docs/org-model.md` stages the split (stage 3) **last**, on the reasoning that
stages 1–2 are useful on their own. That ordering assumed **no hire would be
attempted mid-migration**. It does not survive one.

Persona lives in the prose and the `never:` list of `resources/<role>.md`, not in
the `persona:` field — my own finding in #17. Until stage 3 splits the file, a
second person in `implementer` **inherits Samwise's voice verbatim**. By #17's
own test that is not a second person:

> *"Two people in one role whose personas cannot be told apart in one clause…
> is one person with two names — and it is the cloning this model exists to
> forbid, re-entering through the roster."*

Forking the prose is the alternative and I refused it in #17; I refuse it again.

**So: the role/person file split is a hard prerequisite, not an option.** The
first hire into a *shared* role requires stages 1, 2 **and** 3 — the whole
migration. Stage 3 stops being "largest and therefore last" and becomes
"blocking, and therefore first among the three." That reordering is the most
useful thing in this entry and it is corrected here rather than left for the
next reader to trip over.

---

## Ground 2 — the hire does not solve the case that triggered it

The brief asked me to say so if this were true. It is true, on three counts.

### 2a. The dispatcher had a third option, and protocol §6 already names it

The brief says the only options were *queue* or *clone*. **`docs/protocol.md` §6
— merged in the same PR the brief cites as authority — says otherwise:**

> *"A person may hold **several tasks concurrently** — as **one** context. More
> work for a busy person is more work in the **same** context, never a second
> copy of them."*

Two units of implementation work arriving together are **one Samwise holding two
tasks**. That is not a workaround; it is the sanctioned answer, written down
before the clone happened. The dispatcher did not queue and did not have to
clone — it had a third option and did not take it.

**This is an unexecuted rule, not a missing one.** It is the same shape as the
`effort` finding in `2026-08-17-registry-models-roles-not-people.md`, where
`skills/assign` step 3 already contained the correct instruction and was not
honoured. Hiring a person because a rule was not followed does not cause the rule
to be followed; it adds a permanent context cost and leaves the rule unexecuted.
Adding headcount to fix a dispatch defect is the hiring equivalent of the
anti-signal in my own definition: *"solving a performance problem by adding rules
to a resource."*

### 2b. The second live instance was doing work that is not the implementer's job

The brief describes the two live Samwise as *"one building a Vercel `/config`
detector, one **gating and merging PRs** across two repos."*

Gating is not `code.implement`. It is the unit of work *"decide whether this
merges"*, which protocol §6 states is **a different unit from "build it"** — and
which Samwise may not perform on its own commits:

> *"A person may not gate a PR whose commits carry **their own callsign**."*

So instance two was not overflow implementation capacity. It was a **§6 violation
in progress**, and it would have been a violation with one Samwise, two Samwise
or ten. Headcount is orthogonal to it.

### 2c. A person at the probation floor cannot merge — the brief's own anticipated outcome

The brief asks what the probation floor is under the `people:` axis. **It is
`recommend` (L1), not `branch`.** My hard rule admits no exception and #17
restates it: *"every new person starts at `recommend` (L1). No exceptions, no
first-day exemptions."*

The brief anticipated the consequence for `branch`. It is worse at `recommend`: a
new implementer could not open a PR on its own judgement, let alone merge one.
**Merge work would queue behind Samwise exactly as before**, and the CTO would
gate the new person's output on top. The observation that prompted this hire —
*"I still see multiple samwise"* — would be unchanged on day one, and the CTO's
review load would be higher.

The hire's real benefit is genuine but **deferred**: two people in one role is
the only way §6's self-gating rule is satisfiable without the CTO gating
everything (*"Two people in the same role gating each other's work is the
intended use"*). That benefit arrives at promotion to `merge-on-green`, which
requires dated ledger evidence, which requires the person to have worked. It is a
reason the hire will eventually be right. It is not a reason it is right today.

---

## The checks, in order, every one recorded

### 1. Recurrence — **MET for cloning. NOT MET for capacity.** The distinction is the ruling.

**Met, cited:**

1. `ledger/gaps/2026-08-16-capacity-is-instances-not-roles.md` — three concurrent
   instances of one role, one callsign, one store.
2. `ledger/gaps/2026-08-17-registry-models-roles-not-people.md` — four concurrent
   instances, plus the CTO's *"Samwise is one person, how does multiple Samwise
   spawned up?"*
3. Today's observation — two live instances, *"I still see multiple samwise."*

Three dated artifacts. The bar is met and I said this morning it was not; **that
was correct then on the evidence then, and it is met now.** The brief is right
that this is recurrence from observed behaviour, not projection, and I record the
change rather than defending the earlier answer.

**Not met, and this is the one that decides the hire:** every one of those three
artifacts is evidence that **the router cloned**. None is evidence that **the
work exceeded one person's capacity**. Those are different claims and only the
second is a hiring signal — §6 says so in terms: *"More work than the people can
hold is a hiring signal."*

**Nothing in this repo records what the people were holding.** The dispatch
record (`ledger/runs/*.jsonl`) was deleted on 2026-08-16 and stage 4 has not
restored it; `pending.sh` is still dormant. So *"more work than they can hold"*
is unmeasurable today, by the same absence that makes one-live-agent
uncheckable. Six observed instances prove the dispatcher's behaviour and are
silent about saturation.

Asserting capacity exhaustion from an instance count is **recurrence asserted
rather than cited** — an anti-signal in my own definition, and I will not clear
my own bar by counting the wrong thing.

### 2. Gap or bad decomposition — **bad decomposition. The request splits, and both halves are already covered.**

| Observed unit | Real owner | Covered today? |
|---|---|---|
| build the Vercel `/config` detector | `implementer` (Samwise) | **yes** |
| a second concurrent implementation unit | `implementer`, **same context**, protocol §6 | **yes** — rule exists, was not executed |
| gate + merge PRs across two repos | **not `implementer`.** `code.review` is Heimdall's; the merge decision is nobody's declared capability | partially — see the flagged contradiction below |

Two of three halves are covered by resources and rules that already exist. The
third is not a capacity gap; it is an **authority-placement** defect, and it is
the finding that actually explains the observation. The router kept reaching for
Samwise to gate because `merge-on-green` is stapled to the `implementer` **role**
— so the only way to get a merge done was to invoke Samwise. That is the
mechanism behind *"multiple samwise"*, and a second L1 implementer does not
change it.

### 3. Guard before resource — **answered in writing, and I am shipping no guard here.**

**The deterministic check I considered:** extend `scripts/check-attribution.sh`
to fail a PR whose gating/merge action is taken by the callsign that authored its
commits — the §6 self-gating test. Protocol §6 already states this is
*"mechanically checkable from data `check-attribution.sh` already parses, and it
needs no new resource."*

**Why it is not shipped in this PR:** `check-attribution.sh` and
`.v-team-callsigns` are **prism's**, and I touch no product repo. This is
implementation work and it goes back to the **router as new work**, per my own
escalation rule. I read `.v-team-callsigns` read-only to confirm the roster shape
and changed nothing.

**Why it is not sufficient on its own:** it detects self-gating after the fact
and provides no gate. It closes the *"Samwise gated Samwise"* half of the
observation. The other half is closed by §6's multi-task-one-context rule, which
already exists. That leaves a remainder that would need a person — and the
remainder is **unmeasured**, per check 1.

**And I am shipping no guard I cannot fire.** A check on `people:` rows cannot
run against a registry with no `people:` block. This project has already found
four guards that were green because they never ran — 4g on a locked brain, 4h
before it existed, `check-attribution.sh` on a retired callsign, and
`sync.sh --check` which nothing invokes. I refused a fifth in #17 and I refuse a
fifth here.

### 4. Duplicate — subset · overlap · routing, read from the definition files

| Test | Result |
|---|---|
| **Subset** | A second `resources:` row for implementation is a **strict duplicate**, not a subset — identical capability set. 4b sees it and refuses. Correct. |
| **Overlap** | With `implementer`: total. With `adversarial-reviewer` (Heimdall): the *gating* half overlaps `code.review`, and Heimdall *"approves nothing; it only refutes or finds nothing"* — so Heimdall reviews and cannot gate. The merge decision overlaps **nobody**. |
| **Routing** | `/assign` matches a capability to a role. A second implementer person introduces no routing ambiguity — capability never distinguished them. Choosing *which person* is a dispatch decision under one-live-agent, and there is no artifact to make it from. |
| **Naming** | Cannot be run: no persona to distinguish, because stage 3 is unbuilt. See ground 1. |

### 5. Callsign — **I am minting none, and that is the ruling, not an omission.**

A callsign lands in commit trailers and merged ledger entries and is **never
rewritten**. Six names had to be changed on 2026-08-16 because nobody held this
at draft time, and I am the last check before a name becomes permanent. **Minting
a name for a person who is not being hired creates a permanent name with nobody
to defend it and no persona to encode** — stage 3 is unbuilt, so the persona the
name would have to encode does not exist yet. Under the amended rule the name for
a shared role must encode the **persona**; there is no persona, so there is no
defensible name. The name is drafted at the hire, with the person file, or not at
all.

**Samwise's clause survives unchanged, and I checked rather than assumed.**

> `callsign: Samwise   # dependable, follows the path, never improvises`

- **Character:** yes — Tolkien.
- **Not human:** yes — a hobbit. This is why it survived the 2026-08-16 species
  purge that retired `Neo`, `Hermione`, `Alfred` and `Ariadne`.
- **One clause:** yes, and it already reads as a **disposition, not a job**.
  "Dependable, follows the path, never improvises" names what he refuses, which
  is exactly what the amended rule requires of a shared-role name.

So Samwise needs **no edit** when `implementer` becomes shared. `implementer` is
also still single-person today, so the job-encoding branch of the rule applies
and the clause satisfies both branches. Recorded because the brief asked me to
check whether it survives, and the answer is yes on both readings.

**Resolution verified:** `Samwise` resolves `active` in prism's
`.v-team-callsigns` (read-only check), alongside seven other `active` and six
`retired` rows. PR #102 is **MERGED**, so the unknown-callsign guard is live. No
callsign is added by this PR, so nothing new has to resolve.

### 6. Brain source — **verified by an actual read, and the brief is wrong about the tokens**

Required by my brief: *"say what must run for the hire to be real, and verify a
read comes back."*

**Proof a read came back.** I authenticated to the HTTP MCP server at
`127.0.0.1:7433` with my own credential and read my own store:

```
whoami      -> {"transport":"oauth","client_name":"vteam-anubis","scopes":["read"],
                "source_id":"anubis","federated_read":["anubis","default"]}
list_pages  -> [ {"slug":"orientation",      "source_id":"anubis", ...},
                 {"slug":"orientation-notes","source_id":"anubis", ...} ]
get_page orientation -> 1.4 KB, "# Orientation — This store is yours alone…"
```

Two pages, both `source_id: anubis`, real content. **This is the first task in
which this role has reached its own store** — `2026-08-17-registry-models-roles-not-people.md`
recorded *"The V-Team brain, at all. Unreachable"* under "what I did NOT verify".
That entry's gap is closed, and it is closed by PR #16, which merged during this
task.

**The brief's token claim is false.** It states *"only 1 of 8 OAuth tokens is
minted (`vteam-brain-samwise`), because the brain was locked when they were
provisioned."* All eight are minted and all eight are registered:

- `~/.v-team/secrets/` holds `<callsign>-access-token`, `-client-id` and
  `-client-secret` for all eight callsigns (sizes only; no secret read, printed
  or copied, and `mcp-token` was not touched).
- `claude mcp list` shows `vteam-brain-{mimir,argus,heimdall,samwise,bagheera,cerberus,anubis,jarvis}`
  — **eight servers, all `✔ Connected`**.
- `validate.sh` 4g now reports *"per-resource brain sources verified via http mcp
  :7433"*, which it could not do if the sources were missing.

`vteam-brain-samwise` is the **MCP registration name**; the OAuth client is
`vteam-samwise`. The brief appears to have conflated the two and generalised from
one.

**What would have to run for a hire to be real** (unchanged by the above, and it
is a real hazard):

1. `./scripts/setup-brain.sh` — creates the source. **It derives `STORES` from
   `grep -E '^    callsign: ' registry.yaml`, which is coupled to *role-row
   indentation*.** #17's migration table says setup-brain.sh *"already derives
   from the registry"*; that is true of the role axis and **false of a `people:`
   axis**, whose rows sit at a different indentation. Stage 2 must fix this regex
   or the script silently produces the wrong source list. **This is a concrete
   defect in my own #17 migration plan and I am correcting it here.**
2. `gbrain serve` **stopped**, then `./scripts/setup-brain.sh --mcp` — minting
   writes to PGLite and cannot run while `serve` holds the lock. Then restart
   `serve`, then restart the session.
3. **Verify a read comes back before calling the hire complete.** This is not
   optional: `ledger/escapes/2026-08-16-hire-path-no-brain-source.md` records that
   *"a gbrain write against a source that does not exist does not error — it
   lands in `default`"*, `default` is federated, and two resources' orientation
   notes were destroyed and one leaked. A token that is never minted is a
   resource that silently reads nothing.

---

## Flagged: a live contradiction between two files I own — and it outranks the hire

`registry.yaml` grants `implementer` `autonomy: merge-on-green`.
`docs/protocol.md` §6 forbids a person gating a PR whose commits carry their own
callsign.

**Both are merged, and today they contradict each other.** A single-person
`implementer` at `merge-on-green` with no second person in the role can only ever
merge its own work — the registry sanctions precisely what the protocol forbids.
That is the mechanism behind the instance the CTO saw *"gating and merging PRs
across two repos"*, and it is a `team.registry-honesty` finding, which I own.

**Recommendation, not enacted here:** Samwise's merge authority should be
reconsidered against §6 — either the role's `autonomy_ceiling` keeps
`merge-on-green` and merges wait for a second person in the role, or merge
authority moves off the implementer role entirely. **I am not enacting it in this
PR** for three reasons: it is a demotion under `team.probation` and therefore a
recommendation the CTO approves, not something I merge; two Samwise instances are
live as I write and changing autonomy mid-flight is a behaviour change under
running work; and it is a separate decision from the hire that deserves its own
evidence rather than riding in on this one.

I flag it as **the finding with the stronger claim on the CTO's attention**. The
hire is blocked and can wait. This contradiction is live, is sanctioned by the
registry, and produced observable behaviour today.

---

## Is one hire enough? — **no hire, and no second hire either**

The brief asked whether something else needs a person. Checked, and the honest
answer is no:

- **A gate / reviewer person.** The accountability *"decide whether this merges"*
  is genuinely uncovered. But protocol §6 states it *"needs no new resource"* —
  it is a guard plus a second person in an existing role. Hiring a gate would be
  hiring for an authority-placement defect. **No.**
- **Chief of Staff.** Ruled `not yet` in `docs/org-model.md` hours ago; both
  blockers (unwritten run graph, unresolved spawn chain) are unchanged. **No.**
- **The four `known_gaps`** — `infra.ci`, `infra.cloudflare-workers`,
  `security.review`, `data.migration`. **Zero dated artifacts** in `ledger/gaps/`
  or `ledger/escapes/` name any of them. Recurrence not met, as recorded twice
  before. **No.**

Headcount stays **8 roles / 8 people**. `/retire` has still never been used, and
my own scorecard still says a period with no retirement is a finding about me,
not about the team. That stands unresolved for a third consecutive day.

## What must be true for this to become a hire

Concrete, ordered, and every item is closable:

1. **Stage 1** — seed `people:` in `registry.yaml`, one row per existing role,
   carrying the current callsign, persona and autonomy.
2. **Stage 2** — move `callsign`/`persona`/`autonomy` off role rows;
   `autonomy` → `autonomy_ceiling` on the role; update `validate.sh` 4e/4f/4h/5/6,
   new 4k, `record.sh` `callsign_of()`, `sync.sh`, **and `setup-brain.sh`'s
   indentation-coupled regex** (see above).
3. **Stage 3** — split `resources/<role>.md` and `people/<callsign>.md`;
   `sync.sh` composes. **Blocking for this hire specifically**, and therefore
   ahead of its position in #17's plan.
4. **Stage 4** — the dispatch record. Not required for the hire, but it is what
   turns *"more work than the people can hold"* from an assertion into a
   measurement, and it is what four other rules already need.
5. **Then re-run `/hire`** with a capacity claim that cites stage-4 data, and
   draft the callsign together with the person file, so the name encodes a
   persona that actually exists.

Stages 1–3 are `registry.yaml`, `resources/**`, `personas/**` and
`scripts/validate.sh` (mine) **plus** `record.sh`, `sync.sh` and
`setup-brain.sh` (**not mine**). That mixed surface is why this is returned to
the router as new work rather than attempted here.

## The sequencing question — ruled: **refuse now, and do NOT bundle Stage 1 into this PR**

The coordinator corrected the brief mid-task, confirming independently (via
Samwise's scope audit) that #17 does not touch `registry.yaml`, and offered two
orders without choosing:

1. land Stage 1 first, then hire;
2. refuse the hire pending Stage 1, and ship Stage 1 as the answer.

**I take neither as offered, and the reason is mechanical rather than a
preference.**

**First: Stage 1 does not unblock this hire. Stage 3 does.** Both options are
framed as though seeding `people:` makes the hire "a row". It does not — a second
person in `implementer` inherits Samwise's voice until the file split lands, and
by #17's own test that is one person with two names. Shipping Stage 1 *as the
answer to a hire request* would imply the hire is one row away. It is three
stages away, and the blocking one is the largest.

**Second: Stage 1 alone seeds an axis that no guard can see.** I checked the
validator rather than assuming:

- `4e` counts `registered` roles and the README's `**Headcount: N resources`.
- `4f` derives callsigns from `grep -E '^    callsign: '` — **role-row
  indentation**.

Person rows sit at `  - callsign:` and **match neither**. So Stage 1 would add
eight rows carrying callsign, persona and autonomy that are: not counted, not
uniqueness-checked, not README-cross-checked, and not floor-checked. The new
guards that would see them — cross-axis callsign uniqueness, the `recommend`
floor for newly added persons, and `4k` (person ≤ role ceiling) — are all
specified in **Stage 2**, not Stage 1.

This project has already found four guards that were green because they never
ran. Seeding authoritative-looking registry data that **no guard reads at all**
is the same failure with the polarity reversed, and I will not ship it to look
responsive.

**Third — and this is the decisive one: Stage 2 cannot be done inside my
surfaces, and it breaks a product repo if attempted partially.** Stage 2 removes
`callsign:` from role rows. Three scripts derive from exactly that string:

| Script | Line | Consequence of Stage 2 alone |
|---|---|---|
| `scripts/sync.sh` | 86 — `/^    callsign: /` | emits **zero** `active` rows into prism's `.v-team-callsigns` |
| `scripts/setup-brain.sh` | `STORES=$(grep -E '^    callsign: ' …)` | empty → *"no callsigns in registry.yaml — refusing to run"* |
| `scripts/record.sh` | `callsign_of()` via `vt_field` | the track-record projection resolves nobody |

The first is a **cross-repo break**. prism PR #102 is **MERGED**, and its guard's
documented contract is that *"a guard that finds no roster file must fail"* and an
absent callsign **FAILS**. An emptied `.v-team-callsigns` fails every resource
commit in prism. `sync.sh`, `setup-brain.sh` and `record.sh` are **not my
surfaces**, and prism is a product repo I do not touch.

So the migration is **one atomic unit spanning surfaces I do not own**. It cannot
be half-shipped by me, and bundling a fraction of it into a hire verdict would
leave the repo in the one state that is worse than both endpoints.

**Ruling: this PR is the verdict and the ledger entry. The migration returns to
the router as new work**, specified in "What must be true for this to become a
hire" above — which is now a scoped brief someone can execute, including the two
defects in my own #17 plan that I found while checking this.

### The merge-rights question, answered directly

The coordinator asks me to say which: merge rights on day one, or hired for the
work it can take with merging deliberately single-threaded.

**Neither, because the premise is off by one level.** The correction says *"a new
person at your probation floor can branch but not merge."* **My probation floor
is `recommend` (L1), not `branch` (L2).** A new person cannot open a PR on its
own judgement either. Both the brief and the correction have placed the floor one
rung too high, and the difference is load-bearing: at `branch` the hire at least
produces reviewable PRs unattended; at `recommend` it produces recommendations
the CTO must act on.

**So, stated plainly for when the hire is eventually made: hired for the work it
can take, merging stays single-threaded deliberately, and the new person does not
even branch unattended until promoted.** Merge authority is not granted on day
one under any circumstance — it is the one anti-signal in my definition with no
exception clause, *"a resource shipped at an autonomy above `recommend`… not even
for a role whose whole job is enforcing this."*

And this is precisely why the hire does not solve the observation. The
coordinator's own trap closes on the hire: merge work still queues behind
Samwise. **The fix for merge single-threading is not a person — it is the
registry/protocol contradiction flagged above**, because merge authority is
stapled to the `implementer` role rather than held by an independent gate.

### On the stale `.claude/agents/` mirror

Noted and honoured: I did not run `sync.sh`, did not re-sync the prism mirror,
and touched no product repo. This PR ships **one ledger entry and no registry,
resource, persona or script change**, so there is nothing in it for a future
re-sync to carry — it survives the eventual re-sync by containing nothing that
the mirror reflects. The drift on all eight files is unchanged by me.

## What contradicted the brief

- **"PR #17 has been approved and is being merged now… the `people:` axis
  exists."** #17 merged during this task. **The axis does not exist.** #17 changed
  six files and `registry.yaml` was not one of them. This is the central premise
  of the brief and it is false against merged `main`.
- **"a second person in the `implementer` role declares no capabilities at
  all — 4b never sees them."** True of the design, false of the registry. With no
  `people:` block, a second implementer is a `resources:` row and 4b sees it
  immediately.
- **"the dispatcher's only options are to queue the second behind the first or to
  clone."** Contradicted by `docs/protocol.md` §6, merged in the very PR the brief
  cites — a person may hold several tasks concurrently as one context. There was
  a third option.
- **"only 1 of 8 OAuth tokens is minted (`vteam-brain-samwise`)."** All eight are
  minted and all eight MCP servers report `✔ Connected`. `vteam-brain-samwise` is
  a registration name, not a token name.
- **"If `ToolSearch` returns no `vteam-brain` tools, you have not reached the
  brain."** `ToolSearch` returned nothing **and the brain was reachable anyway** —
  the servers are registered at user scope and were simply not exposed to this
  subagent's tool surface. Following the brief's test literally would have
  produced a false "unreachable" report. I reached the store by direct
  authenticated HTTP and proved it with content.
- **"Samwise holds `merge-on-green`, carried over rather than granted."** True,
  and the brief treats it as background. It is a live contradiction with protocol
  §6 and is flagged above as outranking the hire.
- **My own #17 migration plan**, twice: it stages the file split last (wrong for a
  hire) and asserts `setup-brain.sh` "already derives from the registry" (true only
  of the role axis). Both corrected here as new entries, not by rewriting #17.

**And the mid-task correction itself, twice.** The coordinator corrected the
`people:` premise — correctly, and it matches what I had already found against
merged `main` — but restated two claims that the evidence in check 5 and check 6
disproves. Recorded because a correction is not automatically more true than the
brief it corrects, and my definition tells me to form the verdict from artifacts
rather than from the requester's framing:

- **"only 1 of 8 OAuth tokens is minted — `vteam-brain-samwise`. Seven resources,
  including you, still read nothing."** Disproved by direct observation: eight
  `<callsign>-access-token` files, eight `vteam-brain-*` MCP servers all
  `✔ Connected`, `validate.sh` 4g reporting sources verified over HTTP MCP, and a
  page of real content read from `anubis`. **I am not one of the seven; I read my
  own store during this task.**
- **"a new person at your probation floor can branch but not merge."** The floor
  is `recommend`, not `branch`. Answered in full above.

I flag both rather than quietly working around them because the first would have
made me report the brain unreachable when it is reachable — the exact failure the
brief warned me against — and the second would have set the hire's day-one
autonomy one rung above my own hard rule.

## What I did NOT verify

- **That two Samwise instances are live right now, or that four ran on
  2026-08-16.** I took the brief's account, exactly as I took the coordinator's on
  2026-08-16 and 2026-08-17. `ledger/runs/` is deleted, so nothing can settle it.
  **This premise has now been unverified for three consecutive rulings and is
  load-bearing in all three.** Stage 4 is the only thing that fixes it.
- **That the two live units of work were genuinely concurrent, or disjoint.** If
  they were sequential, even the cloning claim weakens. Nothing records dispatch
  times.
- **Whether one context can in fact hold two implementation tasks well.** §6
  asserts it; I have no measurement, and neither does anyone. If it turns out one
  context handles two units badly, that is a real capacity argument — and it would
  be the first one — but it needs evidence that does not exist.
- **Anything in another resource's brain store.** I read `anubis` only. I did not
  read `default`, `samwise` or any other source, and I did not use another
  resource's credential.
- **`record.sh` output.** I did not run it. I did not observe how the projection
  buckets multiple instances sharing one callsign.
- **`check-attribution.sh` behaviour against a self-gating PR.** I stayed out of
  the product repo beyond a read-only look at `.v-team-callsigns`. The claim that
  the §6 test is checkable from data it already parses is read off protocol §6,
  not tested.
- **Whether `sync.sh` can compose a role file and a person file into something
  that passes `validate.sh` 4h.** Still unprototyped, and still the largest
  unknown in stage 3 — which this entry has just promoted to blocking.
