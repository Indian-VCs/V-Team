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
hermione   isolated    content-auditor
neo        isolated    tenant-visibility-tester
heimdall   isolated    adversarial-reviewer
samwise    isolated    implementer
alfred     isolated    architect
```

An **isolated** gbrain source is only searched when explicitly named via
`--source`. So a resource physically cannot see another's store during normal
operation.

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

`record` is what the monthly report reads for promotion proposals. It is
computed from ledger outcomes, not from a resource's own account of how it did.

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

**The real fix is Postgres.** A Supabase-backed V-Team brain accepts concurrent
connections, so MCP and the scheduled routines can both hold it. A `gbrain`
Supabase project already exists. Migration path:

```sh
GBRAIN_HOME=~/.v-team/brain gbrain migrate --to supabase
```

Deferred deliberately — PGLite costs nothing and works today, and the write
volume is five capped items a day. Revisit when a blocked write appears in the
weekly report more than once.

## Embeddings

`ollama:nomic-embed-text` @768d — on-device, already a login service here, and
free. The routines embed on every write, so a metered embedding provider would
turn the beat into a recurring bill for no gain at this volume.
