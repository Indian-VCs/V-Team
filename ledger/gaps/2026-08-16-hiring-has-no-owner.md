---
date: 2026-08-16
requested_by: CTO
capability: team.hire, team.retire, team.probation, team.registry-honesty, team.orientation
product: v-team (this repo)
status: hired
---

## Requested

Verbatim, from the CTO: *"even the hiring has to be done by a resource, not
here"* and *"hire a HR"*.

## The bootstrap problem, stated plainly

The V-Team had seven registered resources and none of them owned hiring. Every
hire ever made — including both of tonight's, `deployment-engineer` (Marshal)
and `design-reviewer` (Ariadne) — was authored directly in the CTO's chat
window, with no resource holding the bar.

**This hire was made the same way.** It is the bootstrap: the resource that
will own all future hiring was itself hired by the process it exists to
replace, including retroactive review of the two hires that immediately
preceded it. That fact is written into `resources/roster-steward.md` under a
`## Bootstrap` heading rather than left out of the record. A role whose own
creation violated the rule it enforces should carry that fact.

## Capability needed

`team.hire`, `team.retire`, `team.probation`, `team.registry-honesty`,
`team.orientation`. **None appeared in `registry.yaml` or in `known_gaps`
before today** — same shape as the deployment hire: the gap was not merely
uncovered, it was unnamed.

## The four /hire checks, and their answers

### 1. Has the gap recurred? — **NOT MET by the skill's own standard.**

The skill's bar is what `design-reviewer` cleared: two dated `ledger/gaps/`
entries naming the same uncovered capability. There are **zero** such entries
for hiring. `ledger/gaps/` held three files this morning, none about who owns
the roster.

The honest position is that the *condition* recurred and the *record* did not.
Recurrence here is retro-constructed from artifacts that were logged for other
reasons:

| Dated artifact | What it shows |
|---|---|
| `ledger/gaps/2026-08-16-deployment-identity-boundary.md` | a hire that recorded its own failed recurrence test and proceeded anyway |
| commit `1384c0e` — *"Marshal was missing the Protocol section — validate.sh caught it"* | a malformed resource reached a commit; only a script stood between it and the registry |
| `README.md` on this branch | claims **6** resources; `registry.yaml` declares **7**. `design-reviewer` is registered, defined, and absent from the roster table, the department sizes and the org chart. Nobody noticed. |

That third one was found while writing this entry, not before it. It is the
cleanest single piece of evidence for the hire, and it is also evidence that
retro-constructed recurrence is worth less than logged recurrence — the drift
existed for hours with no one accountable for seeing it.

**Hired anyway on direct CTO instruction**, recorded here rather than dressed
up as evidence, exactly as the deployment hire was. If this resource proves
unused, the honest read is that the bar existed for a reason.

### 2. Is it a gap, or a bad decomposition? — **A gap.**

The split was attempted. "Hiring" decomposes into: judge whether a gap is real
(nobody), write the definition (nobody — it was the CTO by hand), validate the
artifact (`scripts/validate.sh`, covered), register it (nobody), orient it
(`scripts/orient.sh` exists, nobody runs it). Four of five parts have no owner
and no owner-shaped nearby role. The decomposition does not rescue it.

### 3. Could a deterministic guard close it instead? — **PARTLY YES. The hire
was scoped down accordingly.**

Taken seriously against this role, four of the listed concerns are checks, not
a person, and were written as checks in this PR (`scripts/validate.sh`):

| Now a guard | Was going to be a duty |
|---|---|
| capability id declared by more than one resource → fail | the *mechanical half* of the `/hire` overlap test |
| an id in both `capabilities:` and `known_gaps:` → fail | "registry.yaml is honest", one direction of it |
| `altitude:` outside implementation/behavior/product → fail | roster hygiene |
| README headcount ≠ registry count, or a registered resource missing from the README → fail | the exact drift found in check 1 |
| a PR that adds `resources/*.md` with no new `ledger/gaps/` entry → fail | "every hire is recorded" |

Already existing and deliberately not duplicated into the role: frontmatter
completeness, the embedded `## Protocol` copy, autonomy-is-recommend on a
changed resource (`validate.sh` rules 3, 4, 6), and orientation status
(`scripts/orient.sh --status`).

**What is left, and only what is left, is the hire:** whether a gap is real,
whether a request is a bad decomposition, whether two resources differ on what
they *refuse*, whether a resource has earned promotion, and when to retire.
None of those have a guard shape. Scoping this down is the outcome
`skills/hire` step 3 wants, not a failure of the request.

### 4. Does it duplicate an existing resource? — **No. `architect` is closest
and is not it.**

| Test | Result |
|---|---|
| **Subset** | No. `architect` declares `product.impact`, `product.should-this-exist`, `escalation.terminal`; none of `team.*` is contained in them. Both answer "should this exist" — but about **different objects**: the product versus the team. |
| **Overlap** | Zero shared capability ids (now enforced mechanically). |
| **Refusals differ** | Yes, sharply — and this is the diversity the skill asks for. `architect` refuses to write anything and has no write tools. `roster-steward`'s entire output *is* a written rule file. `architect` refuses to decide; `roster-steward` refuses to *approve*, which is a different line — it decides a verdict, then hands it to the CTO to merge. |
| **Routing** | Unambiguous on real past requests. *"Should the admin sidebar have a search box?"* → `architect`. *"Do we need someone who owns security review?"* → `roster-steward`. *"Should this capability be a resource or a lint rule?"* → `roster-steward`, always. |

Checked against the other six as well: `implementer` (writes code, no
judgement on roles), `adversarial-reviewer` (diffs only — a registry entry is a
diff, but its beat is tenant isolation and it approves nothing), `content-auditor`
(sourcing, product content), `tenant-visibility-tester` (running app),
`design-reviewer` (interface), `deployment-engineer` (production). None overlap.

## Persona

Three variants drafted in `personas/variants.md` — 7A Evidence Clerk (active),
7B Guard-First Steward, 7C Roster Auditor. 7A ships because the failure being
answered is headcount added without evidence, and 7A's first look is exactly
the check that was skipped eight times. 7B's opening move biases toward
never hiring; it survives as an anti-signal instead. 7C's opening move became
the `validate.sh` guards above.

## Probation

**L1 / recommend**, like everyone. The resource that enforces probation starts
on it, hired below its own bar, by the process it exists to replace. Noted in
its definition rather than smoothed over.

## Deliberately NOT done at this hire

- **Reporting lines and delegation structure.** The CTO has raised this as an
  open question. It is `roster-steward`'s **first real task**, taken through the
  router as work — not settled inside its own hire.
- **Auditing `deployment-engineer.md` and `design-reviewer.md`.** Both are
  flagged for retroactive review *by the new resource*. Neither was rewritten,
  deliberately, so the audit reads an untouched artifact.
- **Fixing the existing org-chart edges.** The mermaid chart already contains
  resource-to-resource arrows, and `SAMWISE -. escalates .-> HEIMDALL` is
  *sideways* (implementation → behavior is fine, but the arrow points at a
  reviewer rather than at the router, and `docs/protocol.md` §3 says higher
  altitude returns work to the router, never as a reply). No new
  resource-to-resource edges were drawn at this hire; the existing ones were
  left in place and are logged here as an audit item.
- **Retiring anything.** Headcount has only ever gone up. That is a standing
  finding for the new resource, not an action taken tonight.
