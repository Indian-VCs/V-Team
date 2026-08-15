# IndianVCs V-Team

**V-Team — the Virtual team.** A standing set of AI **resources** — auditor,
tester, reviewer, implementer, architect — that work on the IndianVCs products
instead of being briefed one prompt at a time.

The point: open one Claude session, describe what needs doing, and the V-Team
figures out whether it has someone who can do it. **If it doesn't, it says so
and names the missing capability** rather than handing the work to a near-fit
that produces confident, wrong output.

The team is virtual. The work isn't.

## Quick start

```
/assign  <what you need done>     # routes to a resource, or reports a gap
/hire    <capability id>          # drafts a new resource for a gap
/retire  <resource>               # removes one — team size has a measured cost
```

Everything else runs on a schedule:

```
./scripts/setup-brain.sh --mcp           # the V-Team's own brain, one store per resource
./scripts/install-schedule.sh            # install the launchd routines
./scripts/install-schedule.sh --status   # are they loaded, when did they last run
VT_DRY=1 ./scripts/beat.sh               # preview the prompts, call nothing
```

Each resource has its **own isolated knowledge store** in a brain separate from
the personal gbrain — `~/.v-team/brain`, registered over MCP as `vteam-brain`.
Isolation is enforced by the engine, not by policy: a resource physically
cannot read another's store, which is what keeps the independence rule real.
See `docs/memory.md`.

| Routine | When | Does |
|---|---|---|
| `beat.sh` | every 6h (00/06/12/18) | reads each beat, writes **proposals** to `ledger/learnings/`. Never touches a rule file. |
| `weekly.sh` | Mondays 08:00 | metrics from git + Actions, then the CTO report |

**launchd, not cron** — `StartCalendarInterval` runs a missed job once on wake,
so a closed laptop delays a run instead of losing it. The beat then picks its
mode from the gap: `normal` · `catch-up` · `backfill` · `cold-start`. The cap of
5 items/day is **per run, never per missed day** — returning after two weeks
produces one good digest, not seventy stale ones.

Metrics are gathered deterministically; the model only writes narrative. If it
is unavailable the report still lands with its numbers intact, and the failure
shows up in the **Liveness** section rather than vanishing.

`VT_MODEL_CMD` points the routines at any model. Defaults to the Claude Code
CLI; set it to a gateway script to move batch work off your interactive quota
without changing anything else.

## What's here

| Path | What it is |
|---|---|
| `registry.yaml` | The skills matrix. Capabilities, altitude, autonomy, and the known gaps. |
| `resources/` | One definition per resource. These sync into each product's `.claude/agents/`. |
| `personas/` | The variants that weren't picked. Swapping is a one-line change in `registry.yaml`. |
| `skills/assign/` | The router. Matches a request to a capability, or reports no coverage. |
| `skills/hire/` | Turns a gap into a new resource definition. |
| `skills/retire/` | Removes one. V-teams are temporary by design. |
| `ledger/` | Evidence. Escapes, attributions, rule-state changes, run graphs. |
| `docs/protocol.md` | **Cross-cutting rules every resource follows.** Termination, escalation, independence. |
| `docs/` | Charter, difficulty map, learning policy, weekly report, dashboard design. |

## The V-Team

**Headcount: 8 resources across 7 departments.** One product staffed
(prism-platform); the other five are dormant and staffed on need.

| Callsign | Resource | Dept | Persona | Altitude | Autonomy |
|---|---|---|---|---|---|
| **Alfred** | `architect` | Architecture | — | product | recommend |
| **Janus** | `roster-steward` | Team | Evidence Clerk | product | recommend *(probation)* |
| **Heimdall** | `adversarial-reviewer` | Quality | Isolation Hawk | behavior | recommend |
| **Neo** | `tenant-visibility-tester` | Quality | Admin | behavior | recommend |
| **Hermione** | `content-auditor` | Content | Fact-Checker | behavior | recommend |
| **Ariadne** | `design-reviewer` | Design | Wayfinder | behavior | recommend *(probation)* |
| **Marshal** | `deployment-engineer` | Deployment | Release Marshal | behavior | recommend *(probation)* |
| **Samwise** | `implementer` | Engineering | Conventions-First | implementation | PR + merge on green |

Callsigns are for talking about the team. `/assign` routes on the functional
id, because "who covers content auditing" has an answer and "who is Hermione"
does not.

Each name encodes the job. **Heimdall** watches the boundary between realms —
tenant isolation. **Neo** checks what actually renders against what the config
claims. **Hermione** opens the source before the copy. **Samwise** is
dependable and never improvises. **Ariadne** hands you the thread out of the
labyrinth. **Marshal** walks the checklist and holds the release. **Alfred**
holds the whole picture and none of the authority. **Janus** is the door — one
face on who comes in, one on who goes out.

### Department sizes

| Dept | Size | Owns |
|---|---|---|
| Quality | **2** | does it break, and can a member see it |
| Architecture | **1** | should this exist |
| Content | **1** | is it factually true |
| Design | **1** | can a member find what is there |
| Deployment | **1** | does it ship, versioned, and can it come back |
| Engineering | **1** | build it |
| Team | **1** | who is on the team, and have they earned it |

Quality is the largest deliberately. Verification is the one shape where
multi-agent measurably beats a single agent; generation is not.

Deployment is separate from Engineering because of the **credential
boundary**, not the workload: deploys act as the `indianvcs` identity while
every other resource authors as `mano@indianvcs.com`. One resource holding both
is how a feature commit ends up wearing the deploy identity. Marshal also owns
`version.md` — no release ships unversioned, and the bump lands **after** merge
and **before** deploy, as its own `release/<version>` PR.

### Org structure

```mermaid
flowchart TD
    CTO["👤 CTO — Dhayan<br/><i>decides · sole approver</i>"]
    ROUTER(["/assign — router<br/><i>the only dispatcher</i>"])

    ALFRED["<b>Alfred</b> · architect<br/>Architecture<br/><i>product altitude · recommend-only</i>"]
    JANUS["<b>Janus</b> · roster-steward<br/>Team<br/><i>product altitude · recommend · probation</i>"]

    HEIMDALL["<b>Heimdall</b><br/>adversarial-reviewer"]
    NEO["<b>Neo</b><br/>tenant-visibility-tester"]
    HERMIONE["<b>Hermione</b><br/>content-auditor"]
    ARIADNE["<b>Ariadne</b> · design-reviewer<br/>Design<br/><i>recommend · probation</i>"]
    MARSHAL["<b>Marshal</b> · deployment-engineer<br/>Deployment<br/><i>recommend · probation</i>"]
    SAMWISE["<b>Samwise</b> · implementer<br/>Engineering<br/><i>merge on green</i>"]

    CTO --> ROUTER
    ROUTER --> ALFRED
    ROUTER --> JANUS
    ROUTER --> HEIMDALL
    ROUTER --> NEO
    ROUTER --> HERMIONE
    ROUTER --> ARIADNE
    ROUTER --> MARSHAL
    ROUTER --> SAMWISE

    SAMWISE -. escalates .-> HEIMDALL
    SAMWISE -. escalates .-> NEO
    HEIMDALL -. escalates .-> ALFRED
    NEO -. escalates .-> ALFRED
    HERMIONE -. escalates .-> ALFRED
    MARSHAL -. escalates .-> ALFRED
    ALFRED -. recommends .-> CTO
    JANUS -. recommends .-> CTO

    subgraph QUALITY [" Quality · 2 "]
        HEIMDALL
        NEO
    end
    subgraph CONTENT [" Content · 1 "]
        HERMIONE
    end
    subgraph DESIGN [" Design · 1 "]
        ARIADNE
    end
    subgraph DEPLOY [" Deployment · 1 "]
        MARSHAL
    end
```

Solid lines are **dispatch** — only the router does it, and it holds the whole
run graph. Dotted lines are **escalation**, which travels one way only:
implementation → behavior → product → CTO. Nothing escalates downward or
sideways, and an escalation is a handoff with a verdict, never a negotiation.

**Alfred and Janus are both product altitude and both terminal**, on different
objects: Alfred answers whether a *product* change should exist, Janus whether a
*resource* should. Neither decides — both hand the CTO a recommendation. Janus
also owns the other direction: `/retire`, and whether anyone has earned a
promotion off probation.

> The chart's remaining resource-to-resource escalation edges predate this and
> are flagged for audit — `SAMWISE -. escalates .-> HEIMDALL` points sideways at
> a reviewer rather than back at the router, which `docs/protocol.md` §3 does not
> allow. No new resource-to-resource edges are drawn.

The tree of work is data (`ledger/runs/`), not a spawn chain. Resources
decompose and hand back plans; they never spawn each other.

## The three ideas it runs on

**Difficulty selects effort, not identity.** There is no "junior" that is
deliberately worse. Effort is chosen by how hard the task is, and difficulty is
defined as *inverse gate coverage* — where lint, typecheck, knip and the unit
suite catch a mistake, work is cheap; where the gate is blind, effort is high.
See `docs/difficulty.md`.

**Altitude and autonomy are separate.** Altitude is which question you may
answer — which module (implementation), how it should behave (behavior),
whether it should exist (product). Autonomy is what you may do unapproved. The
architect is highest altitude and lowest autonomy: it decides nothing.

**Learning is evidence-weighted.** No single observation writes a rule or
retires one. Rules move through states on accumulated evidence, and anything
learned from the web enters as a *proposal* — never straight into a rule file.
See `docs/learning.md`.

## Scope

prism-platform first. The other five products get staffed on need, not on
principle. Gate gaps in those repos are not blockers — they surface in the
weekly report as **not measured**, every week, until they're closed.

## Decisions

Recorded in gbrain: `decision-resource-team-charter`,
`pref-evidence-weighted-agent-learning`,
`pref-work-with-what-exists-remind-later`.
