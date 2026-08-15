---
date: 2026-08-16
requested_by: CTO
capability: design.visual
product: prism-platform
status: no-coverage
recurrence: 2
---

## Requested

Two findings from the admin sidebar (`vchub`, Fund admin role):

1. The ⌘K search box is awkwardly placed — pinned at the bottom of the sidebar,
   between the scrolling nav and the account block.
2. It is not discoverable that a SETTINGS section exists below the fold. The
   CTO hunted for several seconds and found it **by accidentally scrolling**.

## Capability needed

`design.visual` — **second occurrence in two days.** The first was
[2026-08-15-resources-rail-uneven-spacing](2026-08-15-resources-rail-uneven-spacing.md).

Per `skills/hire` step 1, a repeated gap is the hiring signal and a single one
is an anecdote. **This gap has now met that bar** — which the
`deployment-engineer` hire, made the same day on CTO instruction, did not.

## Structure (read-only, from source — NOT a design verdict)

`.pr-shell2__sidebar` is a flex column of three parts
(`src/design-system/styles/shell.css:78-99`):

| Part | Rule | Behaviour |
|---|---|---|
| `.pr-shell2__nav` | `flex: 1; overflow-y: auto; padding-bottom: var(--space-2)` | the only scrolling region |
| `.pr-shell2__actions` | `flex: none` | the ⌘K search slot |
| `.pr-shell2__account` | `flex: none; border-top` | vchub / Fund admin |

**Finding 2 traces to the nav's bottom edge.** It scrolls with 8px of bottom
padding and **no fade, mask or gradient** — so an overflowing list clips at a
hard edge that looks identical to a list that simply ended. On macOS, overlay
scrollbars are hidden at rest, so at rest there is *zero* affordance. That is
why it read as "there is nothing below" rather than "there is more".

Precedent exists in the design system: `DECISIONS.md:452` records a
"scroll-fade trade-off" already argued for `DatasetTable → DS Table`.

**Finding 1 is not a bug — it is an unargued decision.** `shell.css:85-86`
says: *"Shell affordances (⌘K) — sidebar footer on desktop... The proto rail
pins search at the bottom; this is that slot."* So the placement is fidelity to
`docs/designs/prism-v2/proto/`, copied rather than reasoned. Searching
`DECISIONS.md` for `search` returns hits for the deals catalog, PageHeader
toolbar and the admin palette — **nothing arguing sidebar search placement.**

Consequence for routing: moving it is not overriding a recorded decision, it is
making one for the first time. That is product/design altitude, not
implementation. An implementer told to "move search to the top" would be
inventing design law, which is the near-fit failure this ledger exists to
prevent.

## Closest, and why each is NOT this

| Resource | Declares | Why it is not coverage |
|---|---|---|
| Neo (`tenant-visibility-tester`) | `test.config-vs-rendered` | Could confirm what renders. Cannot decide what *should*. |
| Samwise (`implementer`) | `code.implement` | Can execute a specified fix. A scroll affordance's form is a design choice. |
| Alfred (`architect`) | `product.should-this-exist` | Nearest on altitude, but declares no visual capability and would be a near-fit. |

## Reproducibility — better than last time

Unlike the resources-rail report, this one **is** reachable locally: `fund-vchub`
exists in the local dev DB (`hub.localhost:3000`), which is the workspace in the
screenshot. Whoever takes this can observe it rather than infer it.

## Options

1. `/hire design.visual` — the recurrence bar is now met.
2. Split: the scroll affordance is a specifiable fix once someone chooses its
   form; the search placement needs a decision first.
3. CTO decides both directly.
