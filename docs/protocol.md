# Protocol

Cross-cutting rules every resource follows. This file is canonical; each
resource file embeds a compact copy because an agent loading its own
definition does not read this one. `scripts/validate.sh` fails if a resource
is missing its copy.

Every rule here traces to a measured failure mode — provenance at the bottom.

## 1. Termination

**Specification and design faults are 41.8% of observed multi-agent failures —
the largest category — and missing termination conditions are named in it.**
A resource that does not know when it is done either loops or stops early.

Every resource declares three things and honours them:

- **Done-condition** — the observable state that means finished. Not a feeling
  of completeness. "Every claimed surface has been opened in a browser" is a
  done-condition. "The content looks right" is not.
- **Budget** — a turn or token limit, set by the router per task.
- **Exhaustion behaviour** — on hitting the budget: **hand back with partial
  state and say exactly what is incomplete.** Never continue silently, never
  summarise as if finished.

Three states are terminal. Say which one you ended in, every time:

| Terminal state | Meaning |
|---|---|
| `complete` | done-condition met |
| `handed-back` | above your tier, blocked, or budget exhausted — with what remains |
| `escalated` | the question is above your altitude |

Ending without naming one of these is itself a failure.

## 2. Escalation is a handoff, not a conversation

**LLM teams that discuss underperform single agents by 6.3–41.1%, through
"integrative compromise" — converging on middle-ground answers that satisfy
everyone and optimise for nothing.** Conformity pressure dilutes the strongest
reasoning, and it worsens as the team grows.

So escalation transfers a decision. It does not open a negotiation.

- The escalating resource states the question, what it found, and stops.
- The receiving resource **decides alone**. It does not confer, does not seek
  consensus, does not average.
- There is no round trip. No "what do you think?" in either direction.

## 3. Escalation only goes up

A resource may escalate to a **higher altitude** only:

```
implementation  ->  behavior  ->  product  ->  CTO
```

**Never downward, never sideways.** Downward escalation is how ping-pong loops
form, and step repetition is a named failure mode. If a higher-altitude
resource needs implementation work done, that is **new work returned to the
router** — not a reply to the escalation.

**"Sideways" means same altitude.** Behavior → behavior is sideways and is
forbidden; implementation → behavior is one rung **up** and is allowed, and
`skills/assign` names it as a route. This sentence exists because an audit on
2026-08-16 read an upward edge as a sideways one and reported a defect that was
not there. The direction is decided by the ladder above, never by the job title
of the receiver — escalating to a reviewer is fine; a reviewer replying back
down is not.

**The escalation target is declared in the brief, not chosen by the sender.**
A resource picking its own receiver is a dispatch decision the run graph never
records. If the brief names no target, the escalation goes to the router as new
work. See `docs/delegation.md`.

## 4. Independence before integration

Two resources examining the same artifact must **not** see each other's output
first. Independent analysis before integration is one of the few conditions
under which multi-agent measurably beats a single agent; sharing first destroys
it by anchoring the second reader.

The router enforces this: parallel reviewers of the same diff get identical
briefs and no sight of each other.

## 5. Artifacts, never transcripts

Resources exchange **structured output only** — findings, plans, verdicts.
Never a conversation log, never "here's what the other agent said."

Frameworks that pass structured documents outperform those that pass dialogue,
because a document carries what is needed and a transcript carries drift plus
whatever context happened to be nearby. Loss of conversation history is a named
failure mode; the fix is to never depend on it.

A brief is self-contained by construction. If a resource needs something, it
goes in the brief as a fact — not as a pointer to where it was said.

## 6. One accountable

Every unit of work has exactly **one** accountable resource. Never two, never
zero. Two accountables means nobody is. See `dashboard.md`.

**One person, one live agent. A person is never cloned.** CTO ruling,
2026-08-17: *"the same agent or person should not be invoked twice because, in
the real world, one person can take only one task. He can take multiple tasks at
a time, but he cannot be cloned multiple times."*

- A person may hold **several tasks concurrently** — as **one** context.
- More work for a busy person is more work in the **same** context, never a
  second copy of them.
- More work than the people can hold is a **hiring signal**, not a spawning one.
  That is what *"hiring can be done based on the need"* means, and it is the
  first legitimate capacity argument this repo has had.

**This reverses the previous revision of this paragraph**, which said a resource
may run as many instances as there is work for and called the registry a
description of *roles, not headcount*. That was true when written and is false
now: the registry is becoming a description of **roles and the people who hold
them** (`docs/org-model.md`). Four `implementer` instances ran concurrently on
2026-08-16 under the old rule, sharing one callsign, one brain source and one
track record; that is the thing this rule forbids.

**It constrains the router, and nothing can check it yet.** A resource cannot
know how many copies of itself exist. Detecting a second live copy needs an
artifact recording live dispatches — `ledger/runs/*.jsonl`, deleted 2026-08-16.
So this is honoured by hand until that substrate is restored, and no guard is
claimed for it. Instances that do exist still owe **distinguishability in the
record**, which is the `V-Team-Run` id and one more reason §7 requires it.

**And a person may not gate their own work.** The unit of work "decide whether
this merges" is a different unit from "build it", and when one person holds
both, their one accountable is also their only reviewer — the exact collapse
this rule exists to prevent.

**The no-cloning rule makes this test simpler, not harder.** While a role could
be cloned, the test had to be per *run* — both sides logged under one callsign,
so the run id was the only thing separating builder from gate. With one person
per callsign, the callsign alone is the test:

> A person may not gate a PR whose commits carry **their own callsign**. Two
> people in the same role gating each other's work is the intended use —
> different person, different accountable.

That is mechanically checkable from data `check-attribution.sh` already parses,
and it needs no new resource. It gets *more* reliable once people are rows,
because the trailer stops being ambiguous about who authored what.

## 7. A resource is addressed by callsign — in the trailer, and everywhere else

**The callsign is the unit of address, not just the unit of attribution.** Every
dispatch brief, every report, every escalation and every commit trailer names
the resource's **callsign**; the functional id (`implementer`, `architect`) is
the routing key `/assign` matches on and is not a name. A report that says "the
implementer found X" is a defect.

This sentence exists because on 2026-08-16 the rule lived only in the router's
head. All eight callsigns were correct in `registry.yaml` and `README.md`, and
briefs still used job titles, so the CTO asked *"what's with these names,
implementer, architect?"* and then *"even HR doesn't have a name?"* — reasonably
concluding the team had no names at all. `scripts/validate.sh` 4h now forces
each resource file to carry `You are <callsign>`, so a resource signs by
callsign even when the brief that dispatched it used the title. The router side
has no guard and is this rule.



**The CTO's hand commits carry nothing extra.** A commit a resource makes
carries a GitHub-native co-author trailer naming the resource, plus the run id
that ties it to the ledger:

```
Name the ungrouped spaces shelf "Other"

Co-authored-by: Samwise <samwise@indianvcs.com>
V-Team-Run: 2026-08-16-resources-panel-other-group
```

The format is GitHub's, exactly — `Co-authored-by: Name <email>`, in the
trailer block after a blank line, one line per co-author. GitHub silently
ignores a line it cannot parse, so a malformed trailer yields a commit that
looks attributed and credits nobody. `V-Team-Run` is required on any commit
that carries a co-author. It is what groups the commits of one dispatch
together — and, until 2026-08-16, what joined them to a `ledger/runs/` file the
worker did not write. That file no longer exists (see *What this cannot
enforce* below); the run id is now a grouping key with nothing on the other
side of the join.

**Never a co-author naming Claude, Anthropic, or any model.** Resource
callsigns only. This is enforced, not trusted.

**Write the trailer from `registry.yaml`, never from memory.** On 2026-08-16 the
router wrote five commits `Co-authored-by: Neo <neo@indianvcs.com>` from memory;
`Neo` had been retired the previous day for failing the species test, and
`check-attribution.sh` returned `ok` on every one of them because it validated
shape and never asked whether the name was a resource.

**A callsign has three states, not two, and the middle one is the point:**

| trailer names | result |
|---|---|
| an **active** callsign | passes |
| a **retired** callsign | **passes** — legitimate history, resolves via `retired_callsigns` |
| anything else | **fails** — it resolves to nobody, so the work credits nobody |

A plain roster-membership check would be wrong: it starts failing on true
history the moment anyone is retired, and six were retired on 2026-08-16.
**Trailers are never rewritten, so every retired callsign is permanently in the
record and must stay resolvable.** `registry.yaml` carries `retired_callsigns:`
mapping each old name to a **resource id** — never to another callsign, which
would need a migration on the next rename. `scripts/sync.sh` emits both states
to `<product>/.v-team-callsigns`; a guard that finds no roster file must
**fail**, never pass.

This alias is what makes *"leave the older commits, don't touch those"*
survivable: history stays untouched **and** stays attributable. Without it those
two goals are in direct conflict.

**Trailers, not a subject prefix**, because trailers are queryable:

```sh
git log --format='%(trailers:key=Co-authored-by)' --since=1.month | sort | uniq -c
git log --format='%H %(trailers:key=V-Team-Run)' -- src/lib/data/
```

**Enforcement is a guard, not a habit** (`skills/hire` step 3):

- `.githooks/commit-msg` — refuses a wrong co-author locally. Convenience
  only; hooks are not shared by git and are skipped with `--no-verify`.
- `.github/workflows/attribution.yml` — fails a PR when a co-author is
  malformed, names a model, or lacks a run id. It mirrors the existing
  `agents-sync` check.

**What this cannot enforce, stated so nobody mistakes green for proof.**
Because a hand commit carries nothing, a resource that omits the trailer is
indistinguishable from the CTO committing by hand, and passes. Absence of a
trailer stopped being evidence the moment "carries nothing" became the human
signal. So attribution is reliable for commits that claim it and **silent about
commits that do not**.

**That hole got wider on 2026-08-16, not narrower.** The previous revision of
this paragraph named the fix: `record.sh` reconciling `ledger/runs/` — written
by the router, not the worker — against the commits a dispatch actually landed.
**That reconciliation is no longer possible.** `ledger/runs/` was deleted the
same day, when the track record became a projection over the trailers
themselves (`ledger/gaps/2026-08-16-trailer-projection-has-no-substrate.md`,
CTO-ruled and correct on its own terms). The deletion is not the error; the
consequence has to be said out loud:

- **Before:** two independent records of the same dispatch — run files the
  worker could not author, and commits the worker wrote. A commit missing its
  trailer had something to be missing *from*.
- **After:** one record, the commits, which is the very thing being checked.
  The projection derives the record from the trailers, so a commit with no
  trailer is not merely unattributed — it is **absent from the record
  entirely**, and nothing remains that could notice the absence.

This is circular by construction and it is the accepted cost of the projection,
recorded rather than laundered. Closing it now needs a substrate outside the
commit that nobody has yet built: the router recording what it dispatched, in
some form the worker cannot write. Until then this section proves that a commit
claiming a callsign is reachable from the default branch — **and nothing about
work that left no commit at all**, which includes every hand-back, every
escalation, and every dispatch that was dropped.

**Dropped from the previous revision, and why.** `V-Team-Resource:` is gone,
replaced by `Co-authored-by:` — one trailer, GitHub-native, and it renders on
the commit instead of being invisible outside a `git log` format string. The
author-identity exemption is gone with it: telling a hand commit from a
resource commit no longer needs author identity, so the exempt list it
required was dead weight. `V-Team-Node:` is gone — the node is derivable from
the run file, and every additional mandatory field is another thing to get
wrong for no gain in what can be reconstructed. `V-Team-Run:` stays, and is
now enforced rather than merely expected, because it is the only field that
points at an artifact the resource cannot author.

**Deploy identity is separate from attribution.** The trailer says *who did
the work*; the commit author says *which credential acted*, and on this
project it says more than that — Vercel builds a commit only when its author
maps to a Vercel account with access to the project, and there is exactly one
such account (`product@indianvcs.com`) because seats are billed per user. So
commits authored `mano@indianvcs.com` are invisible to the deploy pipeline by
construction. Only `deployment-engineer` authors as `product@indianvcs.com`,
and only on the commits that are meant to build. Set it explicitly per
invocation — never by mutating a shared git config, which silently
re-attributes every other resource's commits.

## Provenance

- Cemri et al., *Why Do Multi-Agent LLM Systems Fail?* (MAST) — 1,600+
  annotated traces, 7 frameworks, 14 failure modes.
  Specification/design 41.8% · inter-agent misalignment 36.9% · verification
  21.3%. https://arxiv.org/pdf/2503.13657
- *Multi-Agent Teams Hold Experts Back* — 6.3–41.1% underperformance,
  integrative compromise, degradation with team size, and the conditions under
  which multi-agent does win. https://arxiv.org/pdf/2602.01011
- MetaGPT — structured documents over dialogue.
  https://arxiv.org/html/2308.00352v6
- *Microspeak: v-team* — v-teams are cross-org, self-organising and
  **temporary**; the origin of `/retire`.
  https://devblogs.microsoft.com/oldnewthing/20121211-00/?p=5863
