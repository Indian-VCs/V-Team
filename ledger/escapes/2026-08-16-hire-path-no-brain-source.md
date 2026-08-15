---
date: 2026-08-16
found_by: CTO
should_have_caught: /hire (skills/hire) — the register step
attribution: no-gate-coverage
---

## What escaped

`docs/memory.md` states that each resource has an **isolated** gbrain source and
that isolation is *"mechanical, not a policy"* — a resource physically cannot
read another's store. **That guarantee was false for every resource hired after
`setup-brain.sh` last ran.**

Verified against `~/.v-team/brain` before the fix:

```
default    federated   1 pages
alfred     isolated    3 pages
heimdall   isolated    3 pages
hermione   isolated    3 pages
neo        isolated    3 pages
samwise    isolated    3 pages
```

No store for `ariadne`, `marshal` or `janus` — the three resources hired on
2026-08-15/16, including `roster-steward` itself.

`scripts/orient.sh` reported `done` for all three and advanced their stamps.
It had not failed: **a gbrain write against a source that does not exist does
not error — it lands in `default`.** `default` is *federated*, which is the one
store every resource searches without asking. So three resources' first-person
orientation notes were written into the shared store.

All three write the same slug (`orientation-notes`), so each overwrote the last.
The single surviving page in `default` was `Orientation notes — janus`.
**Ariadne's and Marshal's ramp notes are gone** — not misfiled, overwritten.

Two distinct failures from one cause:

1. **Loss.** Two resources' orientation output destroyed, and their stamps said
   otherwise, so nothing would ever have re-run it.
2. **Leak.** The surviving notes were readable by every resource. Private
   memory in a federated store is exactly the anchoring the independence rule
   (`docs/protocol.md` §4) exists to prevent — and independence is one of the
   few conditions under which multi-agent beats a single agent at all.

## Root cause — confirmed

`scripts/setup-brain.sh` carried a frozen list:

```sh
STORES="hermione neo heimdall samwise alfred"
```

Those are the five resources that existed the day it was written. **Nothing in
the `/hire` path ever called `gbrain sources add` for a new hire.**
`skills/hire/SKILL.md` "Register it" listed five steps and none of them was the
brain. The store was created by a script that only ever ran once, for a roster
that has since changed four times.

## Attribution — `no-gate-coverage`

Not `resource-error`. No resource made a mistake: the hire path had no such
step, so there was nothing to omit. Not `ambiguous-brief` — no brief was
involved. Not `impossible-task`.

Per `docs/memory.md`, only `resource-error` escapes count against a track
record, so this correctly charges nobody. It is a system failure and the fix is
structural.

## Fixed

| Fix | File |
|---|---|
| `STORES` derived from `registry.yaml` callsigns; refuses to run if empty | `scripts/setup-brain.sh` |
| `vt_brain_ensure_source()` creates the store before any write, and **spools rather than falling through to `default`** if it cannot | `scripts/lib.sh` |
| `vt_brain_drain()` will not drain into a non-existent source | `scripts/lib.sh` |
| Guard 4g: a registered resource with no store fails the validator (skipped where no brain exists, e.g. CI) | `scripts/validate.sh` |
| Register step 7: create the store and orient, *before* the PR | `skills/hire/SKILL.md` |
| The isolation claim now says what makes it true and links here | `docs/memory.md` |

The guard is the important one. "Never fall back to `default`" is the rule that
makes the *next* variant of this survivable: a lost note is recoverable, a
leaked one is not.

## Data actions taken — stated explicitly

**Created** (isolated): `argus`, `mimir`, `jarvis`, `bagheera`, `cerberus`,
`anubis`.

**Migrated**, page by page, after the callsign rename (a store id is a callsign):
`alfred`→`jarvis`, `hermione`→`mimir`, `neo`→`argus` — 3 pages each
(`orientation`, `orientation-notes`, `record`).

**Moved** `default/orientation-notes` (*"Orientation notes — janus"*, written
2026-08-15) into `anubis/orientation-notes`.

**Deleted — exactly one page:** `default/orientation-notes`, after confirming
the copy in `anubis`. It was the leaked page and the only page in `default`.
gbrain reports it `recoverable_until: now + 72h via restore_page`. `default` is
now empty, which is correct — nothing has yet been deliberately shared.

**Nothing else was deleted.** `alfred`, `hermione` and `neo` still exist holding
duplicate copies; `sources archive` produced no effect and removing them needs
`--confirm-destructive`, which was not run so close to a budget boundary. That
is a named follow-up, not a silent omission.

**Stamps cleared:** `orient-design-reviewer`, `orient-deployment-engineer`. They
claimed an orientation whose output does not exist. `orient-roster-steward` was
left — those notes survived and are now in `anubis`.

## Re-running orientation for Bagheera and Cerberus — recommendation, not an assumption

It is a model call each. **Recommend: yes, re-run both.** Two resources are on
probation, both have declared surfaces they have never read against, and the
alternative is state that lies — the stamps said oriented and the notes did not
exist. Two model calls is cheap against a probationary resource working blind.

The honest cost note: both are queued for retroactive audit by `roster-steward`,
and a resource whose definition changes is a different worker that must be
re-oriented anyway. So this may be paid twice. That is correct by design and is
still the right order — the audit reads the definition, not the notes.

`./scripts/orient.sh design-reviewer` and `./scripts/orient.sh
deployment-engineer` will do it; the cleared stamps mean the next unattended run
picks them up on its own.
