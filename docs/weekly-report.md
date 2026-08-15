# Weekly report — CTO

Every line is bound to an artifact. That is what decides whether it still gets
read in week six.

Delivered as a gbrain page **and** a file in this repo, so it is diffable week
to week. Mondays.

## Sections

| Section | Evidence source | Bound to |
|---|---|---|
| **Went well** | merged work that survived the window — no revert, no hotfix, no escape | git + Actions |
| **Went wrong** | escapes, CI failures, mis-triage, rule violations | ledger + Actions |
| **Not measured** | repos and surfaces nothing is watching | registry |
| **Improve** | concerns, rule-state changes, coverage gaps | HR pass + `ledger/gaps/` |
| **Waiting on you** | decisions with defaults, so silence is a valid answer | ledger |

## Rules

**"Went well" is bound to survival, not activity.** Nothing qualifies on the
strength of having happened. It is the section most likely to rot into fiction
— a generator asked weekly for wins will produce wins.

**Every "went wrong" line carries an attribution.** Without it the report says
"3 escapes" and the CTO cannot act. With it:

- **resource error** → the rule set gets an entry
- **ambiguous brief** → the spec process, not the agent
- **no gate coverage** → an engineering investment

Same headline number, three different Mondays.

**Unmeasured never renders as healthy.** Five of six repos have no CI. A row
showing zero escapes in vc-stack would be reporting that nothing is watching it
— as good news. Those rows say **not measured**, never zero. A false clean bill
of health is worse than a blank. This is also the sanctioned reminder channel
for gate gaps (gbrain `pref-work-with-what-exists-remind-later`).

**But distinguish `dormant` from `not measured`.** The baseline found all five
ungated repos at **zero commits in four weeks**. An ungated repo nobody is
committing to is a far smaller exposure than an ungated repo under active
development, and reporting it as unmonitored risk every week is noise — which
is how a report stops being read.

| Repo state | Renders as |
|---|---|
| no gate, commits in the window | **not measured** — real exposure, surface it |
| no gate, zero commits | **dormant** — one line, no alarm |
| gate present | measured normally |

A dormant repo that receives a commit flips back to `not measured` in that
week's report automatically.

**"Waiting on you" items carry defaults.** The CTO should be able to say
nothing and have the sensible thing happen.

## Expectations

The first three reports will be thin and partly wrong. There are no baselines
and trends need about four weeks. The week-over-week delta is where the value
is; the first one is a snapshot.

## Shape

```
IndianVCs V-Team · week of YYYY-MM-DD · 1 product staffed · 5 resources

WENT WELL
  9 PRs merged, 8 still standing · escape rate 4% (prev 9%)
  knip baseline held at zero

WENT WRONG
  1 escape — storage driver ENOENT, production
    attribution: no gate coverage (env-var boot assertion proposed)
  2 mis-triages — both under-tiered, both in src/lib/data/
    attribution: router difficulty heuristic

NOT MEASURED
  vc-stack · VC-Hub · rating-vcs · prism — no CI
  e2e — manual dispatch only, not in the green bar

IMPROVE
  e2e still requires manual dispatch — blocked 3 verifications this week
  2 rules -> contested (DS/RSC boundary; one lint rule may retire both)

WAITING ON YOU
  content-auditor  recommend -> branch   (12 clean handoffs)   default: hold
  coverage gap x3: infra.cloudflare-workers                    default: hold
```
