# Learning policy

The V-Team gets better by recording what escaped, not by accumulating advice.

## The safety boundary — read this first

**Unverified web content never lands in a rule file.**

Every resource has a beat and learns daily. Prism is live with real users. A
scheduled job that pulls text off the internet into instructions that govern
production code is a prompt-injection path with a cron trigger.

So: **web learning is a hypothesis generator, never a rule source.** A finding
enters at `observed` — not injected into anyone's context — and can only reach
`active` by being validated **against this repo**: someone tried it, the gate
stayed green, the ledger recorded it.

Outside evidence and inside evidence are not the same currency. Only inside
evidence promotes.

## Rule states

No single observation writes a rule, and none retires one.

| State | In the resource's context? | Leaves when |
|---|---|---|
| `observed` | no | a second escape matches its shape |
| `candidate` | no | confirmed across **distinct contexts** |
| `active` | yes | contradicting evidence accumulates |
| `contested` | yes, with the caveat attached | resolved up, or superseded |
| `superseded` | no — pointer retained | — |
| `retired` | no | reopens automatically on recurrence |

**"Distinct contexts" is load-bearing.** Two hits in one file is one bug; the
same shape in two subsystems is a pattern.

**Supersede, never delete.** A failure returning eighteen months later should
be recognised as a recurrence, not discovered fresh.

## Guard rules vs heuristic rules — do not prune alike

- **Guard rules** prevent a known failure ("never run e2e against the shared
  cast"). **Silence is success** — not firing is evidence it is working. These
  retire only when the cause is structurally impossible: the code path is gone,
  or a lint rule now covers it.
- **Heuristic rules** are style and approach. Silence genuinely is evidence of
  irrelevance. These decay.

Pruning both on a timer would delete the most valuable rules for doing their
job.

## Prefer a guard to a rule

When an escape is recorded, ask what the **strongest** available prevention is,
in this order:

1. deterministic guard — lint rule, type, CI check
2. a shared helper that makes the mistake unrepresentable
3. a test case
4. a prompt rule
5. a runbook note

A prompt rule is the *weakest* form. An agent that shipped a null-deref should
not get "be careful about nulls" — it should get a lint rule, after which no
resource can make that mistake again, including ones that don't exist yet.

## Cadence

**Journal daily. Decide periodically.**

The daily job appends observations and **never edits a rule file**. The
periodic job reads accumulated evidence, moves states, and opens a PR. A
manager keeps running notes continuously but makes formal calls on a cadence —
same split.

## Beats, not clocks

Diversity comes from different sources and different questions, not different
refresh rates. Each resource owns a beat: a domain, a source set, a standing
question. Cadence follows the beat's real publish rate.

**Cap: 5 items per day per resource. Zero is a valid day.** A cap, not a quota
— a resource required to produce five findings on a quiet day will manufacture
three, and manufactured rules are permanent context tax on a false premise.

## Depth and breadth

The architect holds the **map** — what exists and why it matters, broad and
shallow. The resources below go **deep** on the tools they actually use.

Knowledge flows both ways. When a resource learns something deep enough to
change the map, the architect takes it. That upward flow is the part most
organisations waste.

## Method comparison

When two resources solve comparable tasks differently, compare outcomes on
ledger evidence and write the better method into the shared rule set.

The propagation step is the whole value. Without it you just get two resources
doing it differently forever.
