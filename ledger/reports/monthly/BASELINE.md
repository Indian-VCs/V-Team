# BASELINE — day zero

**Captured 2026-08-15, before any V-Team resource has run.**

This is the control group. Every monthly report answers "better than what?" by
pointing here. It is measured, not estimated — every number below has a command
next to it that reproduces it.

Window: **2026-07-18 → 2026-08-15** (4 weeks), the month immediately preceding
the V-Team.

---

## 1. Delivery — prism-platform

| Metric | Value |
|---|---|
| Commits | **236** (233 on master) |
| PRs merged | **66** |
| PRs open at capture | 3 |
| `feat` commits | 101 |
| `fix` commits | 63 |
| **Rework ratio** (`fix`/`feat`) | **0.62** |
| Reverts | **1** (`b07d494`, reapplied as `bf7fbe4`) |

```sh
git log --since=2026-07-18 --oneline | wc -l
gh pr list --state merged --limit 200 --json mergedAt \
  --jq '[.[] | select(.mergedAt > "2026-07-18")] | length'
```

Rework ratio is the headline number to beat. It is a proxy, not a measure —
`fix` commits include work that was never broken in production — but it is
consistently derived and it moves in the right direction when the team works.

## 2. Gate health

| Workflow | Success | Failure | Cancelled | Pass rate |
|---|---|---|---|---|
| `ci.yml` (lint/typecheck/knip/units) | 177 | **1** | 22 | **99.4%** |
| `agents-sync` | 24 | 0 | 0 | 100% |
| **`e2e.yml`** | 6 | **16** | 6 | **27%** |

```sh
gh run list --workflow=ci.yml --limit 200 --json conclusion,createdAt \
  --jq '[.[] | select(.createdAt > "2026-07-18")] | group_by(.conclusion)
        | map({(.[0].conclusion // "null"): length}) | add'
```

Cancellations are the concurrency group superseding in-flight runs, not
failures.

**e2e at 27% is the standout.** The gate everything else depends on is nearly
perfect; the one that verifies user-facing behaviour fails roughly three runs
in four. That is the pre-existing condition the tenant-visibility tester exists
to work around — it does not fix e2e, it routes around it.

## 3. Escapes — defects found downstream of the stage that should have caught them

Six documented in gbrain for this window. Attributed retrospectively using
`ledger/README.md` categories:

| Escape | Found by | Attribution |
|---|---|---|
| Storage driver `ENOENT /var/task/.storage` | production | no-gate-coverage |
| Editor crash that shipped typecheck-clean | production | no-gate-coverage |
| e2e Turbopack font outage | CI | no-gate-coverage |
| Clerk e2e cast password desync (×3) | CI | no-gate-coverage |
| `spaces` was never actually ungated | an agent, mid-task | ambiguous-brief |
| Agent swept another agent's commits into its PR | review | no-gate-coverage |

**Escape count: 6 · resource-error: 0 · ambiguous-brief: 1 ·
no-gate-coverage: 5.**

That distribution is the most important thing on this page. Five of six escapes
were *nothing watching*, not *someone wrong*. A team of resources cannot fix
those — a gate can. Expect the V-Team's first months to move the
`ambiguous-brief` and `resource-error` columns, and expect
`no-gate-coverage` to stay flat until gates are added.

## 4. Repo coverage — and a finding

| Repo | CI gate | Commits in window |
|---|---|---|
| **prism-platform** | full (lint, typecheck, knip, units) | **236** |
| vc-stack | none | **0** |
| VC-Hub | none | **0** |
| rating-vcs | none | **0** |
| prism | none | **0** |
| HotTakes | ci + deploy | **0** |

**All five ungated repos are dormant.** Zero commits in four weeks. This
materially changes the risk picture: an ungated repo nobody is committing to is
a much smaller exposure than an ungated repo under active development, and it
supports the decision to scope the V-Team to prism-platform and staff the rest
on need.

It also means the weekly report's `not measured` rows should say **dormant**
where that is true. Reporting a dormant repo as unmonitored risk every week is
noise, and noise is how a report stops being read.

## 5. The V-Team at day zero

| Resource | Altitude | Autonomy | Dispatches |
|---|---|---|---|
| content-auditor | behavior | recommend | 0 |
| tenant-visibility-tester | behavior | recommend | 0 |
| adversarial-reviewer | behavior | recommend | 0 |
| implementer | implementation | merge-on-green | 0 |
| architect | product | recommend | 0 |

**Open capability gaps: 5** — `infra.ci`, `infra.cloudflare-workers`,
`security.review`, `design.visual`, `data.migration`.

**Learnings: 0 · conversion rate: undefined · cross-resource shares: 0 ·
runs recorded: 0.**

## 6. Cost

Not captured. There is no pre-V-Team token accounting to compare against, so
`tokens per landed outcome` starts from the first weekly report rather than
from here. Stated explicitly so a later reader does not mistake a missing
baseline for a zero.

---

## Comparability caveat — read before the first monthly report

Three of these numbers are **not** measured the way the V-Team will measure
them:

1. **Escapes** are counted retrospectively from gbrain pages written for other
   purposes. The V-Team will record them prospectively and will almost
   certainly find more — a rising escape count in month one is very likely
   better instrumentation, not worse quality.
2. **Rework ratio** uses commit-message prefixes as a proxy for defects.
3. **e2e pass rate** is contaminated by the shared Clerk cast, which fails runs
   for reasons unrelated to the code under test.

Read month one for **direction and distribution**, not for absolute
improvement. The first honest comparison is month two against month one, both
measured the same way.
