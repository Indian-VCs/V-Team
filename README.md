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

Everything else runs on a schedule: daily learning (capped, proposals only)
and a weekly report to the CTO.

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

| Resource | Persona | Altitude | Autonomy |
|---|---|---|---|
| `content-auditor` | Fact-Checker | behavior | recommend |
| `tenant-visibility-tester` | Admin | behavior | recommend |
| `adversarial-reviewer` | Isolation Hawk | behavior | recommend |
| `implementer` | Conventions-First | implementation | PR + merge on green |
| `architect` | — | product | recommend |

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
