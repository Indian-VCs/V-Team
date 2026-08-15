---
date: 2026-08-15
requested_by: CTO
capability: design.visual
product: prism-platform
status: no-coverage
---

## Requested

Uneven vertical spacing between items in the **Resources** nav rail
(Databases · Insights · Newsletters · Events · Podcasts). Reported from a
screenshot: the gap below the selected item reads larger than the gaps between
the unselected items below it.

## Capability needed

`design.visual` — already on the `known_gaps` list in `registry.yaml`, noted
there as "/design-review skill exists; no standing resource."

Judging whether spacing is *wrong* — as opposed to merely different — requires
deciding what the intended rhythm is. That is a design judgement, and no
resource holds it.

## Closest, and why each is NOT this

| Resource | Declares | Why it is not coverage |
|---|---|---|
| Neo (`tenant-visibility-tester`) | `test.config-vs-rendered` | Adjacent: compares rendered output to config. But it answers *whether an item appears*, not whether the gaps between items are right. |
| Hermione (`content-auditor`) | `content.audit.voice` | The labels, not their layout. |
| Samwise (`implementer`) | `code.implement` | Can execute a named fix; cannot decide what the correct spacing is. |

Per `skills/assign/SKILL.md`, adjacency is treated as a gap — "adjacency is how
bad assignments happen."

## Note for whoever picks this up

The five labels are NOT in the codebase (`grep -rl "Podcasts" src/` and
`"Newsletters"` both return nothing in prism-platform). They are tenant
`sections` config / seed data, so the defect is in the rail component's
spacing rules, not in the item list. `sections` config is named in
`docs/difficulty.md` as a low-gate-coverage surface — effort would tier **high**
if this reaches an implementer.

## Options presented

1. `/hire design.visual`
2. Reduce scope: CTO or a manual `/design-review` pass produces a precise
   done-condition, then Samwise implements it as `code.implement`
3. CTO handles it manually
