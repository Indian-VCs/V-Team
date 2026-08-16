---
date: 2026-08-16
requested_by: CTO (via router, dispatch 2026-08-16-trailer-projection)
capability: record.derive-from-vcs, record.tamper-evidence
product: v-team (this repo)
status: blocked
verdict: not-yet — dependency absent
decided_by: roster-steward (Anubis)
---

## Requested

Replace file-based run records with a **projection**: derive each resource's
track record from GitHub state it cannot rewrite — the `Co-authored-by` and
`V-Team-Run` trailers mandated by `docs/protocol.md` §7, joined against merged
PRs — then delete `ledger/runs/`.

The dispatch named branch protection as a precondition and instructed that it be
verified **first**, because "a resource with Bash can force-push and rewrite the
very history that is supposed to be unforgeable."

## VERDICT — **not yet.** The precondition is false. Nothing was built.

## 1. Branch protection — **OFF on both repos.**

| repo | branch | `protected` | rulesets |
|---|---|---|---|
| `Indian-VCs/V-Team` | `main` | **false** | `[]` (empty, readable — repo is public) |
| `Indian-VCs/prism-platform` | `master` | **false** | **403 — "Upgrade to GitHub Pro or make this repository public"** |

This is not a permissions artifact. The `protected` boolean on
`GET /repos/{owner}/{repo}/branches` is returned to any caller with pull
access, so `false` here is a positive finding, not an absence of visibility.
Every branch on both repos reports `protected: false`.

The two repos fail for **different reasons**, and this matters:

- **V-Team** is public. Protection is *available* and simply **not enabled**.
  This is a switch nobody flipped.
- **prism-platform** is private, owned by `Indian-VCs`, which is a **User
  account, not an organization**. On a free plan, branch protection and
  rulesets are **not offered at all** for private repos — the 403 is GitHub
  declining the feature, not declining the caller. This one cannot be fixed by
  flipping a switch. It needs the repo made public, the account upgraded, or
  the guarantee sourced from somewhere other than branch protection.

## 2. Why this voids the design rather than delaying it

The projection's entire security claim is *"derived from GitHub state a
resource cannot rewrite."* Force-push to `main` is exactly the rewrite it
assumes away. Without protection:

- `git push --force` rewrites merged history, and with it every trailer the
  projection counts.
- A resource can therefore **author its own track record** — the precise
  failure the projection exists to prevent, and an explicit anti-signal in
  `resources/roster-steward.md`: *"Promotion argued from a resource's own
  account of itself."*
- The projection would be **strictly worse than the JSONL it replaces**,
  because it would carry the *appearance* of tamper-evidence while having none.
  `ledger/runs/` at least never claimed to be unforgeable.

**6 of 8 resources hold `Bash`** — verified, listed below — so tool-allowlisting
cannot close this. The dispatch's own claim on this point is confirmed.

Confirmed: the acting account (`manodhayan-ivc`) has `admin: false`,
`maintain: false`, **`push: true`** on both repos. It can push to `main` today
and could not enable protection even if told to. The threat model is not
hypothetical; it describes the credential that wrote this file.

## 3. The silent-zero defect is real, and wider than reported

The dispatch located it at `scripts/record.sh:47`. Verified — and it is worse:

- **`:47`** — `compgen -G "ledger/runs/*.jsonl"` guards the run block, but its
  false branch is **silent**: the pre-initialised `0`s at `:46` stand. A
  missing directory renders `dispatched 0 / complete 0 / dropped 0`, which
  reads as *dispatched and clean*, not as *no input*.
- **`:30`–`:41`** (learnings) — **no guard at all.** `proposed`, `active`,
  `contested`, `retired` and `adopted` render as literal `0`. Only `conv`
  degrades honestly to `no data` (`:37`). `ledger/learnings/` is **not in git**
  (confirmed: `git ls-files ledger/learnings/` is empty; the directory is
  present but empty on disk), so **this is firing right now, for all 8
  resources.**
- **`:67`** (escapes) — **no guard at all.** If `ledger/escapes/` were ever
  absent, `own_errors` would render `0` and the page would state *"**0**
  escape(s) attributed to `resource-error`"* — a clean record manufactured from
  a missing directory. `ledger/escapes/` is in git today (7 files), so this one
  is currently truthful. It is a latent trap, not a live defect.

The fix is not confined to `:47`. Every ledger read in `record.sh` needs to
distinguish *absent input* from *zero observations*, and absent input must
**fail loudly** rather than render a flattering number. This was not done,
because doing it inside a projection that has no substrate would be polishing
the wrong artifact.

## 4. `ledger/runs/` was **kept**

The dispatch permitted removal only after the projection produced a correct
record for at least one resource. No projection was built, so no proof exists,
so the files stay. Removing evidence before its replacement works is the
regression the dispatch itself warned against.

Standing consequence: **the `deployment-engineer` promotion refusal remains
reproducible.** Its record is empty in `ledger/runs/` today and stays empty.
Had `ledger/runs/` been deleted ahead of a working projection, that refusal
would have become unreproducible — and under the silent-zero defect above, an
empty record would have rendered as a *clean* one.

## 5. Claims checked against the dispatch

| claim | result |
|---|---|
| `ledger/runs/` is ~28 lines, smallest thing in the ledger | **true** — 28 lines across 5 files |
| `ledger/rules/` has never existed | **true** — no commit in any ref touches that path |
| `ledger/learnings/` read by `record.sh`, `weekly.sh`, `beat.sh`; not in git | **true** — all three read it; `beat.sh` *writes* it; untracked |
| 6 of 8 resources hold `Bash` | **true** — all but `architect` and `content-auditor` |
| the silent zero is at `record.sh:47` | **partly** — `:47` is the guarded case; `:30`–`:41` and `:67` are unguarded and worse |

## What has to be true before this is retried

1. `main` protected on `Indian-VCs/V-Team`, force-push denied, admins included.
   Available today; needs someone with admin.
2. A decision on `prism-platform`, which **cannot** have branch protection on
   the current plan. Three options, none free: make it public, put the account
   on a paid plan, or accept that its history is not a trustworthy substrate
   and keep run records as files for that repo.
3. Only then: the projection, the loud-failure fix, and — last — the removal of
   `ledger/runs/`.

Until 1 and 2 hold, deriving trust from git history on these repos is an
assertion dressed as a derivation.
