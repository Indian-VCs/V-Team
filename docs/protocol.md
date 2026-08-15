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

## 7. Every commit says who did it

Any commit a resource authors carries an attribution trailer:

```
Name the ungrouped spaces shelf "Other"

V-Team-Resource: implementer (Samwise)
V-Team-Run: 2026-08-16-resources-panel-other-group
V-Team-Node: L0.2
```

`V-Team-Resource` is mandatory and names the **functional id**, with the
callsign in parentheses. `V-Team-Run` and `V-Team-Node` are required whenever
the work came from a dispatch, so a commit joins back to `ledger/runs/`.

**Trailers, not a subject prefix**, because trailers are queryable:

```sh
git log --format='%(trailers:key=V-Team-Resource)' --since=1.month | sort | uniq -c
git log --format='%H %(trailers:key=V-Team-Run)' -- src/lib/data/
```

That makes "what did this resource touch" and "which commits belong to that
run" answerable from git, which matters because `record.sh` must derive a
resource's track record from artifacts the resource **cannot write about
itself**. A trailer written at commit time by the worker is still self-report;
what makes it evidence is that CI refuses the commit without it, and that the
run/node values have to match a ledger file nobody edits after the fact.

**Enforcement is a guard, not a habit** (`skills/hire` step 3: prefer a
deterministic check to a resource every time):

- `.githooks/commit-msg` — rejects a commit with no `V-Team-Resource` trailer.
  Convenience only; hooks are not shared by git and are trivially skipped with
  `--no-verify`.
- `.github/workflows/attribution.yml` — fails a PR when any commit in its range
  lacks the trailer. This is the actual guarantee, and it mirrors the existing
  `agents-sync` check.

**A human commit is not a resource commit.** The CTO committing by hand does
not need the trailer; the guard checks commits on resource branches, and a
human-authored commit is exempt by author identity, never by an opt-out flag.

**Deploy identity is separate from attribution.** The trailer says *who did the
work*; the commit author says *which credential acted*. Every resource except
`deployment-engineer` authors as `mano@indianvcs.com`; deploys act as the
`indianvcs` identity. Never mutate a shared global git config to switch — that
silently re-attributes another resource's commits. Set it explicitly per
invocation.

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
