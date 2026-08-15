# Memory

Each resource has its own knowledge store. The team has a shared one. They live
in a brain that is **separate from the personal gbrain**, and the separation is
not cosmetic.

## Why a separate brain

The personal brain (`~/.gbrain`) is **behavioural only** by standing doctrine —
preferences, decisions, and their rationale, never knowledge or code. A
resource's episodic memory ("this file has bitten me twice") is knowledge. Two
reasons not to mix them:

1. It violates a rule already written down.
2. It would put an automated writer, running unattended every six hours, inside
   the store that holds how Dhayan works.

`GBRAIN_HOME` gives a genuinely separate config and database. Nothing here
reads or writes `~/.gbrain`.

```
~/.v-team/brain/.gbrain/     the V-Team brain      (this)
~/.gbrain/                   the personal brain    (never touched)
```

## Four kinds of memory, and which one was missing

| Kind | What it is | Where |
|---|---|---|
| Semantic | facts about the domain | personal gbrain + repo docs |
| Procedural | how to do the job | `resources/*.md`, `docs/protocol.md` |
| Working | within one task | the context window, ephemeral by design |
| **Episodic** | **what happened to me** | **this brain — the gap** |

Episodic memory is most of what makes a senior engineer senior. Not more
knowledge — accumulated situational memory of *this* system.

## Isolation is mechanical, not a policy

```
default    federated   the TEAM store — every resource searches it
mimir      isolated    content-auditor
argus      isolated    tenant-visibility-tester
heimdall   isolated    adversarial-reviewer
samwise    isolated    implementer
jarvis     isolated    architect
bagheera   isolated    design-reviewer
cerberus   isolated    deployment-engineer
anubis     isolated    roster-steward
```

An **isolated** gbrain source is only searched when explicitly named via
`--source`. So a resource physically cannot see another's store during normal
operation.

**This list is derived from `registry.yaml`, not maintained by hand.** It was
hand-maintained until 2026-08-16 and the guarantee above was false for three
months' worth of hires: a gbrain write to a source that does not exist does not
fail, it lands in `default` — which is *federated*, so every resource can read
it. `setup-brain.sh` now derives the store list from the registry's callsigns,
`vt_brain_ensure_source()` creates the store before any write and spools rather
than falling through to `default`, and `validate.sh` 4g fails when a registered
resource has no store. See
`ledger/escapes/2026-08-16-hire-path-no-brain-source.md`.

**A store id is a callsign, so renaming a callsign orphans a store.** The
2026-08-16 rename migrated `alfred`→`jarvis`, `hermione`→`mimir`, `neo`→`argus`
page by page; the old ids still exist holding duplicate copies and want a
`gbrain sources remove --confirm-destructive` once the copies are confirmed.

That matters because private memory would otherwise **break the independence
rule**. If Heimdall's notebook said "the last reviewer flagged X here," that is
anchoring — precisely what independence exists to prevent, and one of the few
conditions the research says makes multi-agent work at all. First-person-only
is enforced by the engine rather than by asking nicely.

Anything meant to be shared goes to `default`, deliberately.

## Page conventions

Within a resource's store:

| Slug | Holds |
|---|---|
| `orientation` | its ramp notes — written once at setup |
| `surface-<path>` | accumulated notes per file or module |
| `episode-<YYYY-MM-DD>-<slug>` | what it observed on a task, and the outcome |
| `record` | findings raised / confirmed / dismissed — derived, never claimed |

| `orientation-notes` | what it took away from its ramp — first-person |

## Orientation is a process, not a page

`setup-brain.sh` seeds an `orientation` page telling a resource what to read.
Nothing made it read. `orient.sh` runs the ramp for real:

```sh
./scripts/orient.sh              # any resource not yet oriented
./scripts/orient.sh heimdall     # one, forced
./scripts/orient.sh --status
```

It puts the product's hard rules and every escape touching that resource's
declared surfaces in front of it, and asks for notes it would want on its first
task — not a summary. The output lands in **its own** store as
`orientation-notes`.

Runs **once** per resource, unattended. Re-run deliberately after a resource's
definition changes: a changed resource is a different worker, which is the same
reason it re-enters probation.

## Track record

```sh
./scripts/record.sh              # recompute every `record` page
./scripts/record.sh --print      # stdout, write nothing
```

Every number is derived from ledger artifacts the resource **cannot write about
itself** — the system's own rule applied to the resource's own file. It is
overwritten on each recompute and must not be hand-edited.

Two judgement calls encoded in it:

- **Only `resource-error` escapes count against a record.** Escapes attributed
  to *no-gate-coverage*, *ambiguous-brief* or *impossible-task* are excluded.
  Charging a worker for a system failure is what makes most performance
  management useless.
- **Hand-backs are not negative.** A resource handing back work above its tier
  is the escalation rule working. One that never hands back is either lucky or
  pushing through.

`dropped` — dispatched and never returned — is a finding, not a statistic. Any
non-zero value means the run graph caught something the session would have lost.

The **monthly** report reads this for autonomy proposals. The weekly does not:
a week is noise for a trust decision.

## Bounded, or it becomes noise

Episodic memory that only grows is context tax with extra steps — the same
failure the rule-state machine exists to prevent. So:

- every entry links to a ledger artifact; an entry with no evidence is deleted
- `surface-*` pages are consolidated, not appended forever
- entries decay unless re-triggered, exactly like heuristic rules
  (`docs/learning.md`)

## Access

**MCP** — registered as `vteam-brain` (user scope), so the tools appear as
`mcp__vteam-brain__*` alongside the personal `mcp__gbrain__*`. Two brains, two
tool namespaces, no ambiguity about which one you are writing to.

**CLI** —

```sh
export GBRAIN_HOME=~/.v-team/brain
GBRAIN_SOURCE=heimdall gbrain query "what has bitten me in src/lib/data"
GBRAIN_SOURCE=heimdall gbrain put surface-lib-data < note.md
gbrain sources list
```

## ⚠ PGLite is single-writer — know this before relying on it

The V-Team brain is PGLite, and **PGLite allows one process at a time**. While
`gbrain serve` holds it for MCP, a CLI write from a scheduled routine will be
refused, and vice versa. This is already visibly true of the personal brain: a
CLI `list` returns *"already open through gbrain serve (MCP, PID …)"*.

Consequences:

- The routines must **degrade gracefully**, not fail silently — a blocked write
  spools and retries on the next window, and the block shows up in the weekly
  **Liveness** section.
- Do not assume a write landed because the command exited.

### This is blocking, not theoretical

Registering the `vteam-brain` MCP server made it immediate. Claude Code keeps
the server connected, `gbrain serve` holds the PGLite lock continuously, and
**every scheduled CLI write spools instead of landing** — confirmed:

```
brain locked — spooled mimir/record (retries next window)
```

`GBRAIN_NO_RETRY_CONNECT=1` is set on every CLI call so a locked brain fails
fast rather than hanging; without it the routine blocks instead of spooling.
That makes the failure survivable, not solved: with MCP permanently connected
the spool never drains.

**PGLite supports MCP access or scheduled writes. Not both.**

Three ways out, in order of preference:

1. **Migrate to Postgres** — the only configuration where both work.
   ```sh
   GBRAIN_HOME=~/.v-team/brain gbrain migrate --to supabase
   ```
   Needs Supabase credentials. A `gbrain` Supabase project is referenced in
   prism-platform's CLAUDE.md, so the target may already exist.
2. **Drop the MCP registration** — routines own the brain, and it is read from
   the CLI on demand. Cheapest, but gives up the MCP access that was the point.
3. **Leave it spooling** — writes accumulate in `~/.v-team/spool/` and land
   whenever MCP is disconnected. Not a design, just a fact about the current
   state.

Until (1) or (2), treat the brain as write-deferred and check
`~/.v-team/spool/` for anything queued.

## Embeddings

`ollama:nomic-embed-text` @768d — on-device, already a login service here, and
free. The routines embed on every write, so a metered embedding provider would
turn the beat into a recurring bill for no gain at this volume.
