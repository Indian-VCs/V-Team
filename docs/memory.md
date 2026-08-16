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

That sentence describes the **CLI**, and on the CLI it is weaker than it sounds:
`--source` scopes a *search*, and a resource that names another store is not
stopped. Over HTTP MCP — the path resources actually use now — the boundary is
the token, and it is enforced: naming another source returns `permission_denied`.
See **Access** below for what each path does and does not guarantee.

⚠ **The table above is what we intend; `gbrain sources list` says something
else.** Checked 2026-08-16: only `default` reports `federated`, and the eight
callsign stores report mode **`unset`**, not `isolated` — `vt_brain_ensure_source()`
calls `gbrain sources add <id>` with no mode flag. Behaviour still matches the
intent on the evidence available (a `search` with no `--source` returns nothing;
`--source bagheera` returns that store's page), so the guarantee is **observed,
not declared**. Setting the mode explicitly at creation belongs with the brain
write path in `scripts/`, which is parked; until then do not read `unset` as
proof of anything. The three `isolated` sources still listed — `alfred`,
`hermione`, `neo` — are the pre-rename orphans below, not live seats.

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

Every number is derived from artifacts the resource **cannot write about
itself** — the system's own rule applied to the resource's own file. It is
overwritten on each recompute and must not be hand-edited.

**Work is projected from commit trailers**, as of 2026-08-16. For every repo
the team ships into — this one, plus each product in `registry.yaml` resolved
as a sibling checkout — `record.sh` reads `Co-authored-by:` and `V-Team-Run:`
off non-merge commits reachable from that repo's default branch (taken from
`origin/HEAD`, never assumed to be `main`; prism-platform is `master`). It
counts commits landed, distinct runs, and **untraceable** commits — a callsign
with no run id, which cannot be joined to the brief that asked for it and is a
defect in the commit rather than a credit to the resource.

Two judgement calls carried over unchanged:

- **Only `resource-error` escapes count against a record.** Escapes attributed
  to *no-gate-coverage*, *ambiguous-brief* or *impossible-task* are excluded.
  Charging a worker for a system failure is what makes most performance
  management useless.
- **Hand-backs are not negative.** A resource handing back work above its tier
  is the escalation rule working. One that never hands back is either lucky or
  pushing through. A correct hand-back usually lands no commit, so the
  projection cannot see it at all — and reads that silence as nothing, never
  as a mark against anyone.

Absence still renders `no data`, never `0`. A resource with no trailered commit
has an **unread** record, not a clean one, and no promotion may be argued from
it.

### ⚠ This record is trusted, not verified

The projection is derived rather than self-reported, which is the property a
promotion argument needs. **It is not tamper-evidence, and nothing in this repo
should be read as claiming otherwise.**

Neither default branch is protected. Checked 2026-08-16: `Indian-VCs/V-Team`
`main` returns `protected: false` with no rulesets; `Indian-VCs/prism-platform`
`master` **cannot** be protected today — it is a private repo under a personal
account on a free plan, where GitHub offers neither branch protection nor
rulesets at all. Six of eight resources hold `Bash`. Any one of them can
force-push a rewritten history, and the regenerated `record` page would look
exactly as it does now.

Stated so a future reader cannot mistake it:

| | |
|---|---|
| **Proves** | a commit reachable from the default branch *right now* carries this callsign and this run id, and that prism CI (`attribution.yml`, enforcing since #82) rejected the malformed ones. The resource authored a commit, not a claim about itself, and someone merged it. |
| **Does not prove** | that the history was not rewritten to add that commit or remove another. There is no append-only property here. A resource can, today, author its own track record. |

So the guarantee is **trust-based**. Cite this page as a shared account of what
happened; never as evidence against a resource that disputes it.

**The exact condition that would change that:** branch protection enabled on
`main` with force-push denied, and the same on `master` once prism-platform is
public or on a plan that offers rulesets. When both are true, this section
comes out — and not before. The finding that produced it is PR #7; the CTO's
ruling on 2026-08-16 was *"I know branch is not protected, and it's okay for
now. I'll protect it when needed."*

### What the projection cannot see

`ledger/runs/*.jsonl` was removed on 2026-08-16 once the projection produced
real records. Two things went with it, and neither is recoverable from git:

- **`dropped`** — dispatched and never returned. A commit that was never made
  is indistinguishable from a dispatch that was never made. This was the one
  thing the run graph caught that trailers cannot, and losing it is a real
  cost, not a wash.
- **hand-back and escalation counts**, for the same reason.

The mechanism is not gone: `skills/assign` §7 still appends a run file per
dispatch and `skills/retire` still reads them, so the directory refills as work
is dispatched. What was deleted is five backfilled files (`887b9e4`) that
`record.sh` no longer reads — and git still holds them at `8f2fe26`, so nothing
is destroyed, only removed from the working tree.

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

**Resources read the brain over HTTP MCP, against the running server. The CLI is
the fallback.** This reverses the previous rule, and the reversal is the point:
a running `gbrain serve` used to be what blocked every resource, and is now the
access path. CTO ruling, 2026-08-17 — *"use mcp over http"*. A process-lifecycle
rule ("don't run `serve` while resources work") was considered and rejected.

### Why the previous MCP attempt failed, so it is not repeated

`vteam-brain` was registered as a **stdio** server — `command: gbrain`,
`args: [serve]`. An MCP server inherits the PATH of the process that spawns it,
`gbrain` lives in `~/.bun/bin`, and that PATH does not contain it, so the server
never started. Worse, stdio is the wrong shape regardless: each client spawns
its *own* `gbrain serve`, every one of them tries to open the same PGLite file,
and all but the first are refused. Stdio cannot fix a single-writer problem
because stdio multiplies the writers.

HTTP inverts that. **One** server process owns the file; every client is a
network client of it.

### The server

```sh
gbrain serve --http --port 7433 --bind 127.0.0.1 \
  --token-ttl 31536000 --suppress-bootstrap-token \
  >> ~/.v-team/logs/serve-http.log 2>&1 &
```

| | |
|---|---|
| MCP endpoint | `http://127.0.0.1:7433/mcp` |
| Health | `http://127.0.0.1:7433/health` → `{"status":"ok",...}` |
| Admin | `http://127.0.0.1:7433/admin` |

Bound to loopback deliberately. Auth is OAuth 2.1; an unauthenticated `POST
/mcp` returns `401 invalid_token`.

### One server registration per resource, because the token *is* the identity

The bearer token carries the resource's identity — its `source_id` and the set
of sources it may read. So a single shared `vteam-brain` registration would give
every resource the *same* identity, which is worse than what it replaces. Each
resource gets its own OAuth client and its own registration:

```sh
# once per callsign, with `gbrain serve` STOPPED (this writes to the DB)
gbrain auth register-client "vteam-<callsign>" \
  --scopes "read" --source "<callsign>" --federated-read "<callsign>,default"

# then, per callsign — user scope, so every project and every dispatched agent sees it
claude mcp add --transport http --scope user "vteam-brain-<callsign>" \
  http://127.0.0.1:7433/mcp --header "Authorization: Bearer <that client's token>"
```

`scripts/setup-brain.sh --mcp` does both, idempotently, for every callsign in
`registry.yaml`. Tokens land in `~/.v-team/secrets/`, mode `0600`, and are never
printed or committed.

**Registration must be user scope.** A dispatched resource is a subagent; it
resolves MCP tools through `ToolSearch` against the servers its *session* loaded
at start. Project scope keyed to one directory does not reliably reach an agent
dispatched with a different cwd, and local scope does not survive at all.

**A new registration only takes effect in a NEW session.** Verified 2026-08-17:
a server added mid-session is `✔ Connected` in `claude mcp list` and still
completely invisible to an agent dispatched from the session that was already
running — `ToolSearch` returns *"No matching deferred tools found"*. This is the
exact difference the stdio attempt died on. After running `setup-brain.sh --mcp`,
restart the session before believing anything.

### The recipe a resource runs

```
ToolSearch  select:mcp__vteam-brain-heimdall__whoami,mcp__vteam-brain-heimdall__get_page,mcp__vteam-brain-heimdall__query

mcp__vteam-brain-heimdall__whoami    {}
mcp__vteam-brain-heimdall__get_page  {"slug":"orientation-notes"}
mcp__vteam-brain-heimdall__query     {"query":"what has bitten me in src/lib/data"}
```

Each resource carries this in the **Memory** section of its own definition,
because an agent loading its own definition reads nothing else.

### Isolation is now access control, not search scoping — a real upgrade

This is the part most likely to have been lost, and it was not. Verified
2026-08-17 against the live server with the `samwise` token:

| attempt | result |
|---|---|
| `get_page {"slug":"orientation-notes"}` | returns the **`samwise`** page — eight stores hold that slug, the server picks yours |
| `query {"source_id":"jarvis"}` | **`permission_denied`** — *"source 'jarvis' is outside your granted sources"* |
| `query {"source_id":"__all__"}` | clamped to the grant — only `samwise` rows come back |
| `list_pages {"source":"jarvis"}` | `source` is not a parameter; ignored with a warning, returns `samwise` |
| `put_page` | not in `tools/list` at all, and `insufficient_scope` if called anyway |

`whoami` states the grant explicitly:

```json
{"scopes":["read"], "source_id":"samwise", "federated_read":["samwise","default"]}
```

Compare the CLI, where `--source` is *search* scoping and nothing stops a
resource naming another store. **The MCP path is strictly stronger**: the engine
now enforces what the independence rule (`docs/protocol.md` §4) previously only
asked for.

**The standard this has to meet is lower than what it delivers.** CTO ruling,
2026-08-17: **search-scoped isolation is sufficient.** Access control is not
required — discipline, plus each resource passing its own `--source`, is
accepted. So the enforcement above is headroom, not a requirement, and the CLI
fallback is *not* a downgrade below the bar. Treat this as decided; it is not an
open risk and does not need re-litigating.

One difference worth knowing rather than worrying about: `sources_list`
enumerates every source in the brain — id, page count — including stores the
caller cannot read. Names and volumes are visible; content is not. Under the
ruling above this is acceptable; it is recorded so nobody rediscovers it and
mistakes it for a break.

**And the guarantee is only as good as the token each resource is handed.** A
legacy full-access bearer (`~/.v-team/secrets/mcp-token`, scopes `read`+`write`,
no `source_id`) exists for the write path, and it reads **every** store — checked
2026-08-17, `query --source_id jarvis` with it returns jarvis's pages. Registering
*that* token for a resource would collapse isolation completely while looking
identical in `claude mcp list`. Per-resource clients only; never the shared one.

### Fallback: the CLI as a thin client of the same server

**This is the path that works in a session that is already running**, and that
is not a small caveat: a registration only reaches a *new* session, so every
resource dispatched from a session that started earlier has no MCP tools at all.
Before this existed, that case had **no working path** — tools absent on one
side, a locked file on the other — which is precisely how Jarvis came to rule on
a production PR with no memory.

`GBRAIN_HOME` points at the resource's **client config**, not at the brain:

```sh
export PATH="$HOME/.bun/bin:$PATH"
export GBRAIN_HOME="$HOME/.v-team/clients/heimdall"

gbrain list                            # what that resource holds
gbrain get   orientation-notes
gbrain query "<terms>"                 # its store + default
```

Each `~/.v-team/clients/<callsign>/.gbrain/config.json` carries a `remote_mcp`
block — gbrain's built-in **thin-client** mode. The CLI dispatches each shared
op to the running server over HTTP and renders the reply with the same formatter
the local path uses, so output is identical and only the transport changes. It
uses the same OAuth client as that resource's MCP registration, so the grant and
the denials are the same: naming another store returns `permission_denied`.

Verified 2026-08-17, with `serve --http` holding the lock:

```
$ GBRAIN_HOME=~/.v-team/brain    gbrain get orientation-notes --source samwise
GBrain's local database is already open through `gbrain serve` (MCP, PID 28665) …

$ GBRAIN_HOME=~/.v-team/clients/samwise gbrain get orientation-notes
title: Orientation notes — samwise        # real content, server still up
```

**The direct-file recipe (`GBRAIN_HOME=$HOME/.v-team/brain`) is now the thing to
avoid** while a server runs. It is still correct when nothing holds the lock, and
`scripts/lib.sh` `vt_brain()` / `vt_brain_put()` still use it — which is exactly
why writes remain blocked; see below.

## Failure has to be loud, and by default it is not

Silent degradation is the actual harm. On 2026-08-16 Jarvis ruled on a
production PR with no memory access at all and only knew because it happened to
check; Anubis shipped runs whose isolation check had never run. Two distinct
mechanisms produce that, and they need different countermeasures.

**1. An unreachable HTTP server is invisible, not noisy.** When the server is
down its tools are simply *absent* from the agent's surface — `ToolSearch`
returns "No matching deferred tools found", which reads exactly like a store
with nothing in it. Confirmed 2026-08-17: the personal brain's `gbrain` server
is registered at `localhost:7432`, nothing is listening there, and
`mcp__gbrain__*` does not appear in a dispatched agent's tool list at all — no
error, no warning, just absence.

So **HTTP MCP does not make failure loud on its own. It changes the shape of the
silence.** Every resource definition now says, in its own words: if `ToolSearch`
returns nothing for your server name, you have *not* reached the brain, and you
must report that rather than answer as though the store were empty. That is a
procedural guard, not a mechanical one, and it should be read as weaker.

A liveness check that *is* mechanical, for scripts:

```sh
curl -fsS --max-time 3 http://127.0.0.1:7433/health >/dev/null \
  || { echo "::error::brain unreachable at 127.0.0.1:7433"; exit 1; }
```

**2. The CLI's lock error was never silent — the callers were.** Checked
2026-08-17: with `serve` holding the lock, `gbrain sources list` writes its
message to **stderr** and exits **1**. Anubis's warning said the command
"returned nothing", and `validate.sh` 4g reported isolation unverified, because
both piped the command into `awk`/`grep` — and a pipeline reports the exit code
of the *last* stage, so `gbrain`'s `1` was discarded and an error became an empty
string. The defect was in the caller, not in `gbrain`. `validate.sh` 4g now
queries the HTTP server when it is up, and captures the CLI's exit status
separately when it is not.

## ⚠ PGLite is single-writer — reads are solved, writes are not

The V-Team brain is PGLite, and **PGLite allows one process at a time**. HTTP MCP
resolves this for **reads**: the server holds the file and every resource is a
client of it, so a running `serve` no longer locks anyone out.

**It does not resolve writes yet, and nothing here should be read as claiming it
does.** The scheduled routines in `scripts/lib.sh` (`vt_brain_put`) still shell
out to the CLI, which still cannot open a file `serve` holds. So with `serve`
running continuously, every scheduled write still spools:

```
brain locked — spooled mimir/record (retries next window)
```

`GBRAIN_NO_RETRY_CONNECT=1` makes that fail fast rather than hang. The spool at
`~/.v-team/spool/` drains only when `serve` is stopped.

### What the write path should become

The server already owns serialisation, so routing writes through it is the fix
and it makes writes *safer*, not merely possible:

- `vt_brain_put()` calls `POST /mcp` `put_page` with the **write-scoped** token
  at `~/.v-team/secrets/mcp-token` (`scopes: ["read","write"]`), keeping the
  spool as the fallback for when the server is down.
- **Resources still do not write.** Their tokens are `read` only, `put_page` is
  not even in their `tools/list`, and that is deliberate: a `record` page a
  resource can write is a track record it can author about itself, which
  `docs/memory.md` above spends a whole section refusing. Writing stays with
  `scripts/`, which writes *about* resources from artifacts they cannot forge.

**Not implemented, and not verified.** This change was scoped out of the HTTP-MCP
read fix: the write token's surface was confirmed (`put_page` present, `write`
scope granted) but **no live write was executed over HTTP**, because the brain
has no backups and a failed write experiment is not recoverable. Until it lands,
treat the brain as write-deferred and check `~/.v-team/spool/`.

Migrating to Postgres (`gbrain migrate --to supabase`) remains the option that
removes the single-writer constraint entirely, and would make this section moot.

## Embeddings

`ollama:nomic-embed-text` @768d — on-device, already a login service here, and
free. The routines embed on every write, so a metered embedding provider would
turn the beat into a recurring bill for no gain at this volume.
