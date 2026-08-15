---
date: 2026-08-16
requested_by: CTO
capability: deploy.production, deploy.identity-boundary
product: prism-platform
status: hired
---

## Requested

Deployment currently works only under the `indianvcs` identity, not `mano`. The
CTO asked for a deployment engineer who owns deploys with the indianvcs
credential, while every other resource keeps committing as mano — plus
per-commit attribution so it is knowable which resource did which work.

## Capability needed

`deploy.production`, `deploy.rollback`, `deploy.env-secrets`,
`deploy.domains-tls`, `deploy.identity-boundary`. **None of these appeared in
`registry.yaml` or in `known_gaps` before today** — the gap was not merely
uncovered, it was unnamed.

## Closest, and why each is NOT this

| Resource | Declares | Why it is not coverage |
|---|---|---|
| implementer | `code.implement` | Merges to a branch. Never touches production, and holds no deploy credential. |
| adversarial-reviewer | `code.review` | Reads diffs. A deploy is not a diff. |
| architect | `product.impact` | Decides nothing and runs nothing. |

## The /hire check that FAILED

`skills/hire` step 1: *has the gap recurred?* **No.** This is its first
occurrence, and `ledger/gaps/` held exactly one prior entry (design.visual,
same day). The skill says one request is an anecdote — note it and wait.

Hired anyway on **direct CTO instruction**, recorded here rather than dressed
up as evidence. If this hire proves unused, the honest read is that the bar
existed for a reason.

## The part that was NOT hired

`skills/hire` step 3: *could a deterministic guard close it instead?* For the
attribution half — **yes**, and it was closed that way. Commit trailers plus a
`commit-msg` hook and a CI check (`docs/protocol.md` §7), not a resource
remembering to write them. Logged here because "part of this request was
answered by a guard" is the outcome the skill wants recorded.

## Outstanding

The deploy identity is **unconfirmed**. Three candidates appear in the repo and
its docs: `mano@indianvcs.com` (16 of the last 20 commits),
`255698712+Indian-VCs@users.noreply.github.com` (the other 4), and
`product@indianvcs.com` (gbrain `memory-operational-gotchas`, `TODOS.md:308`).
The new resource's first task is to establish which one the deploy path
actually requires — until then it hands back rather than guessing.
