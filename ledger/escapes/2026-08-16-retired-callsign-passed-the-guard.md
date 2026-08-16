---
date: 2026-08-16
kind: escape
attributed_to: router-error (dispatch layer), compounded by guard-gap
caught_by: Samwise, reading its own gate output on prism #95
product: prism-platform
status: closed by alias — trailers left as-is, history stays attributable
decided_by: roster-steward (Anubis)
---

## What escaped

The router wrote commit trailers from memory instead of from `registry.yaml`
and used `Co-authored-by: Neo <neo@indianvcs.com>`. **`Neo` was retired on
2026-08-15** (merged PR #5) for failing the species test — a human character
from *The Matrix* — and replaced by **Argus**.

`scripts/check-attribution.sh` returned `ok`, verbatim:

```
ok  51bd73663  Give a fund the columns its public page is composed from
    [Neo <neo@indianvcs.com> | 2026-08-16-public-workspace-landing-redesign]
No misattributed commits.
```

## Scope — **wider than reported. Five commits, four branches, two run ids.**

The brief said prism #95 (one commit) and #96 (several). Verified against the
repo:

| commit | branches | in `master`? |
|---|---|---|
| `2a86d7b` | `feat/public-page-redesign` | no |
| `51bd736` | `feat/public-page-redesign`, `feat/public-page-migration` (#95) | no |
| `10a3200` | `feat/clerk-satellite-wiring` | no |
| `350b3ab` | `feat/clerk-satellite-wiring` | no |
| `f954b0a` | `feat/clerk-satellite-wiring`, `feat/clerk-satellite-domains` (#96) | no |

**All five were unmerged when found; they are being merged as-is**, trailers
untouched, per the reversal below. Note the shape: five commits, but only **two
run ids** — `2026-08-16-public-workspace-landing-redesign` (2) and
`2026-08-16-clerk-satellite-domains` (3). That is why the alias is keyed by run
rather than by sha.

Separately: `41033e1` carries `Co-authored-by: Marshal` and **is in `master`**
— genuine `deployment-engineer` work under its old callsign. It stays, and it is
the case that proves the alias must map to the *historical* resource rather than
to whoever a later dispatcher meant.

## Why the guard passed

`check-attribution.sh` checks three things: trailer **shape**, that the name is
not a model or vendor, and that a `V-Team-Run` is present and well formed. It
never asks whether the callsign **is a resource**. A product repo has no
`registry.yaml`, so it had nothing to ask.

This is the third instance today of the same failure class — a check that is
green because it never asked the question. The other two are
`validate.sh` 4f (argued the name, never checked it was reachable) and
`pending.sh` (reported "nothing waiting" against a deleted directory).

## Fix — the half that is mine

`scripts/sync.sh` now emits the roster to `<product>/.v-team-callsigns` as
`<state>\t<callsign>\t<resource-id>`, generated from `registry.yaml` — **active
and retired both**, because a product-repo guard has to tell a legitimate old
name from an unknown one. `registry.yaml` gains `retired_callsigns:` and
`misattributed_runs:` (below), guarded by `validate.sh` 4i/4j.
`docs/protocol.md` §7 states the rule: write the trailer from the registry,
never from memory.

## Fix — the half that is NOT mine, handed over with the patch

`scripts/check-attribution.sh` is `prism-platform`'s and belongs to
**Cerberus** (`deployment-engineer`), which built it. My definition forbids me
touching a product repo, and I am not making an exception for a guard I want
fixed quickly. The patch is small and stated exactly so it needs no design work:

**Three states, not two.** A plain roster-membership check would start failing
on legitimate history the moment anyone is retired — and six were retired
yesterday — so `retired` is a first-class row, not an absence:

| trailer names | result |
|---|---|
| an **active** callsign | passes |
| a **retired** callsign | **passes**, resolves to its resource, prints a note |
| anything **else** | **fails** |
| roster file **missing** | **fails** — an unrunnable check must never read green |

```sh
# after MODEL_RE, near the other patterns
ROSTER_FILE="$(dirname "$0")/../.v-team-callsigns"
if [ ! -f "$ROSTER_FILE" ]; then
  annotate "no .v-team-callsigns in this repo — cannot verify co-authors name real resources. Re-run v-team scripts/sync.sh and commit it. FAILING rather than passing: an unrunnable roster check must never read as green."
  exit 1
fi

# inside the per-co-author loop, alongside the MODEL_RE test
name=$(printf '%s' "$ca" | sed 's/ *<.*//')
entry=$(awk -F'\t' -v n="$name" '$2==n {print $1"\t"$3}' "$ROSTER_FILE")
case "${entry%%$'\t'*}" in
  active)  : ;;
  retired) printf '  note    %s  co-author %s is a RETIRED callsign; resolves to %s\n' \
             "$short" "$name" "${entry##*$'\t'}" ;;
  *)       annotate "${short} names '${name}' as co-author, which is neither an active nor a retired callsign in registry.yaml. It resolves to nobody, so record.sh will credit nobody. Write the trailer from the registry, not from memory."
           bad_here=1 ;;
esac
```

The roster-missing branch **fails**, deliberately: absent input must never
render as clean. That is the lesson from the other two escapes today, and it is
now three-for-three.

**`.v-team-callsigns` has to be tracked in `prism-platform` for CI to see it.**
`.claude/agents/` is currently untracked there — already recorded in
`ledger/gaps/2026-08-16-callsign-not-on-the-dispatch-surface.md` — and this is
the second guard blocked by the same omission.

## Ruling on the branches — **REVERSED. Do not rewrite. Alias instead.**

I first ruled *rewrite them*, on the ground that "leave the older commits"
protects history and an unmerged branch is not history yet. **That ruling is
withdrawn, and the router's reversal is the better call.** Recorded in this
order rather than edited away, because the reasoning is the useful part.

Why the reversal is right and my ruling was not:

- Every affected branch is held by a **live worktree or a running agent**.
  Rewriting under one destroys uncommitted work — a certain cost against a
  cosmetic gain.
- **A rewrite fixes these five commits and nothing else.** The same defect
  recurs the next time anyone is renamed, and six people were renamed
  yesterday. An alias fixes every past and future instance at once.
- **My ruling created a permanent obligation to rewrite** — every rename would
  have to chase down unmerged branches before they merged. That is a migration
  disguised as a policy.
- The CTO wants throughput, and these merges were already gating.

**The alias is what makes "leave the older commits, don't touch those"
survivable.** History stays untouched *and* stays attributable. Without it the
instruction and the track record are in direct conflict; with it they are not.
That is the actual insight here, and it belongs to the reversal, not to me.

## The alias, and the one correction I made to the shape

The brief asked for `Neo → Samwise`. **I did not write that, and the reason
matters.** Two different facts were being collapsed into one table:

1. **`Neo` was `tenant-visibility-tester`'s callsign** before 2026-08-16. That
   is a rename, it is true, and it must *stay* true.
2. **These particular commits used `Neo` for `implementer` work.** That is an
   error, not a rename.

Writing `Neo → implementer` would make the alias table assert something false
about history, and any genuine pre-rename `Neo` commit would be miscredited.
**`Marshal` proves this is not theoretical** — it has real `deployment-engineer`
commits in `master` (`41033e1`), so `Marshal → deployment-engineer` has to keep
meaning exactly that. A table that launders errors into renames stops being
evidence.

So `registry.yaml` gets **two blocks**:

- **`retired_callsigns:`** — the rename history. `callsign → RESOURCE ID`,
  never `callsign → callsign`. This is the property the brief asked for:
  `Neo → Argus` breaks the day `tenant-visibility-tester` is renamed again and
  needs a migration; `Neo → tenant-visibility-tester` resolves through the
  roster and **survives every future rename untouched.**
- **`misattributed_runs:`** — the corrections, **keyed by run id, not by commit
  sha**. The run identifies the dispatch, one entry covers every commit it
  produced, and it keeps covering them if a branch is rebased and the shas
  change. Verified: the five commits fall under exactly **two** run ids, so two
  entries cover all of them and anything else those runs produce.

This corrects the record without rewriting it — which is the same rule this
ledger runs on: *a wrong entry gets a correcting entry, never a rewrite.*

Guarded by `validate.sh` 4i/4j: a retired callsign must map to a resource that
exists, a retired name may never be reused as an active one, and a
misattributed run must name a real resource. All three verified red and green.

## What I did NOT verify

- I did not run the proposed `check-attribution.sh` patch. It is written
  against the script as it stands on `master` today and is untested; Cerberus
  should prove it red and green, as it did for the original guard.
- I did not inspect the full commit list of `feat/clerk-satellite-wiring` or
  `feat/public-page-redesign` beyond the trailer grep, so there may be more
  affected commits on those branches than the five listed.
- I did not check whether any *other* retired callsign (`Hermione`, `Ariadne`,
  `Alfred`, `Janus`) appears in an unmerged trailer. The grep covered commits
  since 2026-08-15 and found only `Neo` and the merged `Marshal`.
