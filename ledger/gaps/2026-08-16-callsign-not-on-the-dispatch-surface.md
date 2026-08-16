---
date: 2026-08-16
requested_by: CTO
capability: team.callsign
product: v-team (this repo) + prism-platform/.claude/agents mirror
status: not-hired
verdict: guard-only — zero renames, zero hires
decided_by: roster-steward (Anubis)
---

## Requested

Verbatim, from the CTO:

> "what's with these names, implementer, architect? call the hr"

and, mid-audit:

> "even HR doesn't have a name?"

The brief that reached me listed six suspected violations — `Neo`, `Hermione`,
`Ariadne`, `Alfred`, `Samwise`, `Marshal` — and asserted that `architect` and
`implementer` had **no callsign at all**, and that I had none either.

## VERDICT — **no hire, no rename.** The deliverable is `validate.sh` rule 4h.

## Audit — the full roster, before

Read from `registry.yaml`, `resources/*.md`, `personas/variants.md`,
`README.md`, `docs/delegation.md` and `docs/memory.md` on branch
`brain-access-declaration`.

| Resource | Callsign | Non-human character? | In registry | In README clause | **On the dispatch surface** |
|---|---|---|---|---|---|
| `architect` | Jarvis | yes — J.A.R.V.I.S., an AI (borderline, see below) | ✅ | ✅ | ❌ |
| `roster-steward` | Anubis | yes — jackal-headed Egyptian god | ✅ | ✅ | ⚠️ body prose only |
| `adversarial-reviewer` | Heimdall | yes — Norse god | ✅ | ✅ | ❌ |
| `tenant-visibility-tester` | Argus | yes — hundred-eyed giant | ✅ | ✅ | ❌ |
| `content-auditor` | Mimir | yes — Norse jötunn | ✅ | ✅ | ❌ |
| `design-reviewer` | Bagheera | yes — a panther | ✅ | ✅ | ❌ |
| `deployment-engineer` | Cerberus | yes — three-headed dog | ✅ | ✅ | ❌ |
| `implementer` | Samwise | yes — a hobbit (borderline, ruled below) | ✅ | ✅ | ❌ |

**Eight of eight compliant on the naming rule. Eight of eight absent from the
dispatch surface.** After: identical callsign column, with the last column ✅
across the board. Nothing was renamed.

## The four /hire checks

### 1. Recurrence — **MET, and this is the first time tonight it has been.**

Two dated artifacts, both 2026-08-16, both the CTO, both the same uncovered
thing — a resource being addressed by job title:

1. *"what's with these names, implementer, architect?"* — reports naming two
   resources by job title.
2. *"even HR doesn't have a name?"* — a dispatch brief naming a third the same
   way, after (1) had already been raised.

`ledger/gaps/2026-08-16-dispatch-has-no-owner.md` is a third, indirect
occurrence: it records six callsigns being changed at once because nobody held
the naming bar at draft time. Three occurrences, one day.

### 2. Gap, or bad decomposition? — **Neither. It is a stale premise.**

The brief's list of violations describes the roster as it stood **before** PR #5
(`org/delegation-callsigns-memory`, merged 2026-08-15). Every name on it had
already been retired:

| Suspected (from the brief) | Actual state | Verdict on the suspicion |
|---|---|---|
| `Neo` — human | renamed → **Argus**, 2026-08-16 | correct rule, stale fact |
| `Hermione` — human | renamed → **Mimir** | correct rule, stale fact |
| `Ariadne` — human | renamed → **Bagheera** | correct rule, stale fact |
| `Alfred` — human | renamed → **Jarvis** | correct rule, stale fact |
| `Marshal` — a rank | renamed → **Cerberus** | correct rule, stale fact |
| `Janus` — Roman god, listed as known-good | renamed → **Anubis** | listed as compliant; it *was*, and was replaced anyway for job-encoding |
| `Samwise` — "you rule on it" | unchanged | ruled below |
| `architect`, `implementer` — "no callsign" | **both have one** | the real defect is one layer down |
| `roster-steward` — "you have none either" | **has one: Anubis** | same |

So the answer to the CTO's own framing — *is this "no callsign assigned" or
"callsign assigned but never used"?* — is **unambiguously the second**, and the
brief's inference that the rule "was never enforced" is wrong in mechanism while
being right in effect.

### 3. Guard before resource — **the guard is the whole answer. Rule 4h.**

**Where it leaked.** `validate.sh` already had rule 4f: a callsign exists, is
unique, and has a bolded one-clause justification in `README.md`. That rule is
sound and it passed. It checks `registry.yaml` and `README.md` — **and neither
of those is a file a dispatcher ever opens.**

What a dispatcher opens is `resources/<name>.md`, mirrored into a product's
`.claude/agents/`. Its frontmatter is:

```yaml
name: implementer
description: Lands a specified change on a branch with the gate green. …
```

`name:` is the job title (rule 3 requires it to equal the filename, correctly —
that string is the routing key). The `description:` is what a dispatcher reads
when it selects and then *refers to* a resource, and on seven of eight files it
did not contain the callsign. On the eighth (`roster-steward.md`) the callsign
appeared only in body prose at line 14, below the frontmatter — enough for a
resource reading its own file, useless to a dispatcher scanning descriptions.

Result: a registry that is 100% green and a CTO who reads "the implementer
found X". The guard was measuring the argument, not the artefact.

**`skills/hire` leaked the same way.** Its "Register it" step 1 said *"Write
`resources/<name>.md` with the standard frontmatter"* — no mention of the
callsign. Step 5 put the callsign in the README. So the hire path, followed
exactly, produces a resource with a correct callsign that is never used. It did
so three times.

**Rule 4h**, per resource, from the `name`/`callsign` pairs in `registry.yaml`:

- the callsign appears in the frontmatter `description:` string;
- the file carries `Callsign **<X>** — <one-clause>` under the H1;
- the file carries the sentence `You are <X>`, so the resource signs its own
  work by callsign even when the brief that dispatched it used the job title.

Matching is done against the file with newlines flattened, so reflowing a
paragraph cannot fail a check that is about words.

**Why this guard is sufficient where 4f was not.** 4f asks "did a human argue
for this name?" — judgement, correctly delegated to a person. 4h asks "can the
name be reached from the file a dispatcher loads?" — a pure artefact question, so
it belongs in a script. Together they cover both halves. Verified in both
directions: green on the fixed tree, and red with the exact per-resource message
when `Jarvis` is removed from `architect.md`'s description.

**4h also pins the brain source id**, which is the callsign lowercased: the
resource file must tell the resource to read `--source <lowercase callsign>`.
This is deliberately a *file* check, not a *store* check. 4g inspects the stores
that exist, needs a live brain, and degrades to a warning under a PGLite lock —
so a rename that forgot to migrate could sail past it on any locked run. 4h
needs nothing and always runs. Verified red (`--source samwise` → `frodo` fails
with the per-file message) and green.

**Two further guard defects found while writing it, both fixed here:**

1. **Rule 4g never ran.** It gates on `command -v gbrain`, but `gbrain` lives in
   `~/.bun/bin`, which is not on a non-interactive `PATH` — a fact every
   resource definition states and this script did not. On the maintainer's own
   machine the brain-isolation check silently did nothing. Now resolves the
   binary explicitly.
2. **Rule 4g passed on a locked brain.** PGLite is single-writer; a running
   `gbrain serve` makes `sources list` return nothing, which was
   indistinguishable from "all sources present". Now emits an explicit
   `::warning::` saying isolation was **not** verified this run. It stays a
   warning, not a failure — a locked brain is not a roster defect — but it can
   no longer be mistaken for proof.

Both are the same bug as the one being reported: **a guard that looks green
because it never ran.**

### 4. Duplicate — n/a. No resource proposed.

## Callsign rulings

### `Samwise` — **COMPLIANT.** Precedent recorded.

The test is **species, not manner**: does the character belong to a people that
is not *Homo sapiens* within its own fiction? Hobbits are a distinct people of
Middle-earth and are named as such throughout.

**The honest counter-argument, recorded rather than suppressed:** Tolkien's
Prologue to *The Lord of the Rings* calls hobbits *"relatives of ours: far
nearer to us than Elves, or even than Dwarves."* A strict reading makes them a
branch of Men. I rule that statement to be about kinship, not species — and note
that it does not need to carry the ruling on its own, because the four names
that failed (`Neo`, `Hermione`, `Ariadne`, `Alfred`) are humans outright with no
second reading available. The bar separates "arguably human" from "human"; it
has to, or it is not a bar.

Two tie-breakers for a case still 50/50 after the species test, in order:

1. **The one-clause justification must survive the ambiguity.** If the clause
   cannot name the non-human referent, the name fails.
2. **Incumbency breaks a true tie toward keeping the name** — a rename costs an
   unrewritable commit-trailer and `ledger/` record plus a brain-store
   migration, against zero naming benefit at that margin. Incumbency is a
   tie-breaker only; it never rescues a name that fails the species test.

Neither tie-breaker was needed for Samwise; the species test settles it. Both
are written down because the next borderline case will not be this clean.

### `Jarvis` — **COMPLIANT, with the ambiguity named.**

Borderline in the opposite direction and it was not on the brief's list, so it
is raised here rather than left silent. J.A.R.V.I.S. is a non-human system;
**Edwin Jarvis is a human butler** — and the callsign replaced `Alfred`, also a
fictional butler, which makes "we swapped one butler for another" a fair
challenge. It stands under tie-breaker 1: the README clause (*"sees every system
at once and gives orders to no one"*) names the non-human referent
unambiguously, and `resources/architect.md` now says so in its own body. **The
CTO can overrule this one cheaply** — `Jarvis` is in no commit trailer, only in
merged file content and the `jarvis` brain store.

### `Marshal` — the brief is right that it is a rank, and it is already gone.

Retired → `Cerberus` on 2026-08-16. It survives in one commit trailer
(`9177819`), which is not rewritten. `resources/deployment-engineer.md` now
distinguishes *Release Marshal* the **persona** (swappable) from the callsign
(not), because that file was still the strongest surviving argument for the
confusion.

## Brain sources — **no migration needed, and here is why that is not luck**

The source id is the callsign lowercased (`docs/memory.md`). **Zero callsigns
changed in this PR, so zero stores are orphaned, so nothing was migrated and
nothing needed to be.** Stated explicitly rather than left implicit, because a
silently orphaned store does not error — a gbrain write to a nonexistent source
lands in the federated `default`, which this team has already been bitten by
once (`ledger/escapes/2026-08-16-hire-path-no-brain-source.md`).

Current mapping, unchanged, and **verified file-by-file in both the source and
the `prism-platform/.claude/agents/` mirror** — every resource's `--source` id
is exactly its callsign lowercased, 8/8 in each tree:

| resource | callsign | `--source` in `resources/` | `--source` in mirror |
|---|---|---|---|
| `content-auditor` | Mimir | `mimir` | `mimir` |
| `tenant-visibility-tester` | Argus | `argus` | `argus` |
| `adversarial-reviewer` | Heimdall | `heimdall` | `heimdall` |
| `implementer` | Samwise | `samwise` | `samwise` |
| `design-reviewer` | Bagheera | `bagheera` | `bagheera` |
| `deployment-engineer` | Cerberus | `cerberus` | `cerberus` |
| `roster-steward` | Anubis | `anubis` | `anubis` |
| `architect` | Jarvis | `jarvis` | `jarvis` |

That correspondence is now mechanical (4h) rather than observed once. The
pre-rename orphans `alfred` · `hermione` · `neo` remain listed in
`docs/memory.md` as dead stores, correctly.

**Not verified:** I could not confirm the live source list. `gbrain sources
list` refused — PGLite is single-writer and a `gbrain serve` (PID 48432) held
the lock for this session's duration. The claim above rests on the argument that
an unchanged callsign cannot orphan a store, which is sound, plus
`docs/memory.md` as written. It does **not** rest on an observation, and rule
4g's new warning now says so out loud on every run in that state.

## The mirror — a fourth leak, refreshed but NOT closed

`scripts/sync.sh ../prism-platform --check` reported **all eight files
drifted**: the mirror dated from 01:11 and the source from 13:46, and the entire
`## Memory — your own store` section was missing from every mirrored copy. So
even the callsign that *did* exist in `resources/roster-steward.md` was not
reliably reaching the file a dispatcher loads. Re-synced with `sync.sh`, the
existing mechanism; `--check` is now clean.

**Two things this does not fix, handed off rather than claimed:**

1. **`.claude/agents/` is untracked in `prism-platform`.** Not gitignored —
   simply never committed. A mirror that exists only in a working tree cannot
   drift-check in CI and does not survive a fresh clone.
2. **No CI job runs `sync.sh --check`.** `prism-platform`'s `agents-sync`
   workflow compares `CLAUDE.md` against `AGENTS.md` and says nothing about
   `.claude/agents/`. `sync.sh`'s own header comment claims it "mirrors the
   CLAUDE.md/AGENTS.md drift check prism-platform already runs" — it does not;
   nothing runs it. That comment is the guard equivalent of an uncited
   recurrence.

**Why I did not close them in this PR.** Both need a commit in
`prism-platform`, and two implementers hold that working tree right now with
uncommitted work across `src/` and `prisma/` on `feat/public-page-redesign`.
Creating a branch there would move `HEAD` under them for the sake of a mirror
that has never been tracked. That is a repo-policy change with a live race
attached, and it is the CTO's call, not mine, so it goes back to the router as
new work rather than being taken here. The disk mirror is correct in the
meantime.

## Scoped out

| Was it a person's job? | Now |
|---|---|
| noticing a resource shipped without its callsign in use | `validate.sh` 4h |
| noticing the brain check never ran | `validate.sh` 4g, binary resolution |
| noticing the brain check passed without running | `validate.sh` 4g, warning |
| remembering to put the callsign in the resource file | `skills/hire` step 1 |
| re-litigating a borderline callsign | `skills/hire`, species test + tie-breakers |

## What contradicted the brief

- **The premise.** Six of the eight named violations were already fixed the day
  before, in a merged PR. Acting on the list without reading the roster would
  have renamed six compliant resources, orphaned six brain stores and broken the
  documented `Samwise` example in `docs/protocol.md` §7 and
  `prism-platform/CLAUDE.md`.
- **"`architect` and `implementer` have no callsign."** Both do.
- **"Even HR doesn't have a name."** I have one: **Anubis**, in the registry,
  in the README, in my own definition, and in two commit trailers on this
  branch (`8f2fe26`, `b40f13a`). I was dispatched as `roster-steward` because
  the dispatch surface never carried it — which is the defect, and the CTO's
  instinct that it points at unenforcement is right about the outcome even
  though the mechanism is the opposite of the one assumed.
- **"A seventh rule is the obvious shape."** `validate.sh` already had seven
  (1, 2, 3, 4, 4b–4g, 5, 6, 7 by its own numbering). The new one is 4h.
- **The instruction to assign myself a callsign.** Declined as written: I
  already have one, and minting a second would violate the rule I own
  (permanence) and orphan the `anubis` store. I applied the *intent* — no
  exemption from the fix — to the name I already have.
