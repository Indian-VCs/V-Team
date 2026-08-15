# Difficulty map

**Difficulty is inversely proportional to gate coverage.**

Where lint, typecheck, knip and the unit suite catch a mistake, work is cheap
no matter how intricate it looks — a resource can be wrong and the gate
corrects it for free. Where the gate is blind, the cost of being wrong is
unbounded and effort has to be high.

This is why effort is selected by **task difficulty, not resource identity**.
A "junior" that stays cheap on work that turned out to be hard is exactly the
failure mode to avoid.

## prism-platform

Its `CLAUDE.md` "Hard rules & gotchas" section is already this map — every
entry is a place where something breaks in a way the gate does not see.

| Surface | Gate catches it? | Tier |
|---|---|---|
| `src/lib/data/**`, `src/lib/tenant.ts` — fund scoping | ESLint catches the *import*, not a wrong scope | **high** |
| `src/lib/auth.ts`, `ops-auth.ts`, `vendor-auth.ts` | no — and it is live Clerk with real users | **high** |
| `prisma/schema.prisma`, migrations | no — additive-only pilot rule, `fund_id` denorms | **high** |
| workspace `sections` config | no — "in master" ≠ "member can see it" | **high** |
| DS components with hooks across the RSC boundary | **no** — "typecheck does NOT catch this; it fails at render" | **high** |
| anything calling `assertDestructiveDbAllowed` | refuses non-localhost, but blast radius is prod | **high** |
| JSONB columns | zod on read and write — mostly caught | medium |
| `.pr-*` / Tailwind layering | no, but visually obvious | medium |
| routes, components, unit tests | yes | low |
| `content/**`, docs, catalog copy | not by the gate — by the content auditor | low effort, specialist review |

## Other products

vc-stack, VC-Hub, rating-vcs, prism and HotTakes have `lint` and `test` scripts
but nothing running them on push. **By this definition, every change in those
repos is high difficulty**, because nothing catches you.

This is not a reason to refuse the work — see gbrain
`pref-work-with-what-exists-remind-later`. Work inside what exists, rate the
difficulty honestly, and let the weekly report carry the reminder.

## Rules

**Bias triage up.** Over-tiering costs tokens. Under-tiering costs a production
incident. Not comparable.

**Escalate on discovery.** Triage happens before the work and will sometimes be
wrong — "change this label" turns out to touch the sections config. A resource
that discovers the work is above its tier **hands back. It never pushes
through.**

**Mis-triage is evidence.** Every hand-back goes to the ledger, and this map is
one of the things the learning loop should be pointed at — the evidence there
is unambiguous.

## Note

Closing a gate gap moves work in that repo **down** a tier permanently. Gate
investment pays twice: safety, and a lower cost on everything done there
afterwards.
