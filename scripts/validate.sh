#!/usr/bin/env bash
# Validate the V-Team registry against the resource definitions.
#
# Catches the drift that would otherwise be silent: a resource declared in
# registry.yaml with no definition file, a definition nobody registered, or a
# definition missing the frontmatter Claude Code needs to load it.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

status=0
fail() { echo "::error::$1"; status=1; }

# 1. Every registered resource has a definition file.
registered=$(grep -E '^  - name: ' registry.yaml | sed 's/.*name: //' | tr -d ' ')

# One person per line, and its "role|callsign|autonomy" triple — the join
# every later check needs now that callsign/persona/autonomy moved off the
# resources: row and onto people: (docs/org-model.md, stage 1+2, shipped
# atomically because stage 1 alone seeds an axis no guard here could see).
# Block-scoped to `people:` specifically: `retired_callsigns:` uses the exact
# same "  - callsign: " shape and a file-wide grep would silently mix live
# people with dead names.
person_rows=$(awk '
  /^people:/  { inb=1; next }
  /^[a-z_]+:/ { inb=0 }
  inb && /^  - callsign: / {
    if (c != "") print c "|" r "|" a
    c=$0; sub(/^  - callsign: /,"",c); sub(/[[:space:]]*#.*/,"",c); gsub(/[[:space:]]*$/,"",c); r=""; a=""
  }
  inb && /^    role: /     { r=$0; sub(/^    role: /,"",r);     sub(/[[:space:]]*#.*/,"",r); gsub(/[[:space:]]*$/,"",r) }
  inb && /^    autonomy: / { a=$0; sub(/^    autonomy: /,"",a); sub(/[[:space:]]*#.*/,"",a); gsub(/[[:space:]]*$/,"",a) }
  END { if (c != "") print c "|" r "|" a }
' registry.yaml)
callsigns=$(echo "$person_rows" | cut -d'|' -f1)
roles_of_people=$(echo "$person_rows" | cut -d'|' -f2)
for r in $registered; do
  [[ -f "resources/$r.md" ]] || fail "registry.yaml declares '$r' but resources/$r.md does not exist"
done

# 2. Every definition file is registered.
for f in resources/*.md; do
  n="$(basename "$f" .md)"
  echo "$registered" | grep -qx "$n" || fail "resources/$n.md exists but is not in registry.yaml"
done

# 3. Frontmatter is present and carries name + description.
for f in resources/*.md; do
  head -1 "$f" | grep -qx -- '---' || { fail "$f: missing frontmatter opening ---"; continue; }
  fm=$(sed -n '2,/^---$/p' "$f")
  grep -q '^name: '        <<<"$fm" || fail "$f: frontmatter missing 'name:'"
  grep -q '^description: ' <<<"$fm" || fail "$f: frontmatter missing 'description:'"
  fmname=$(grep '^name: ' <<<"$fm" | head -1 | sed 's/^name: //' | tr -d ' ')
  want="$(basename "$f" .md)"
  [[ "$fmname" == "$want" ]] || fail "$f: frontmatter name '$fmname' does not match filename '$want'"
done

# 4. Every resource embeds the protocol. docs/protocol.md is canonical, but an
#    agent loading its own definition never reads it — so the compact copy has
#    to be present, or the rule does not exist for that resource.
for f in resources/*.md; do
  grep -q '^## Protocol'                  "$f" || fail "$f: missing '## Protocol' section (see docs/protocol.md)"
  grep -q 'done-condition'                "$f" || fail "$f: protocol missing a done-condition — termination is the largest failure category"
  grep -q 'handed-back'                   "$f" || fail "$f: protocol missing terminal states (complete / handed-back / escalated)"
  grep -q 'only goes up'                  "$f" || fail "$f: protocol missing the no-downward-escalation rule"
  grep -qi 'never transcripts'            "$f" || fail "$f: protocol missing the artifacts-not-transcripts rule"
done

# 4b. Capability ids are unique across resources. This is the MECHANICAL HALF of
#     the /hire overlap test — two resources declaring the same id is duplication
#     wearing a different name, and a script can see it. The judgement half (do
#     they differ on what they REFUSE?) stays with roster-steward.
caps=$(awk '
  /^    capabilities:/ { in_caps=1; next }
  /^    [a-z_-]+:/     { in_caps=0 }
  in_caps && /^      - / { sub(/^      - /,""); sub(/[[:space:]]*#.*/,""); print }
' registry.yaml)
while read -r dup; do
  [[ -n "$dup" ]] && fail "registry.yaml: capability '$dup' is declared by more than one resource (see skills/hire overlap test)"
done < <(echo "$caps" | sort | uniq -d)

# 4c. A capability nobody covers and a capability somebody covers are different
#     lists. An id in both is registry.yaml lying to /assign in one direction or
#     the other.
gap_ids=$(grep -E '^  - id: ' registry.yaml | sed 's/.*id: //' | tr -d ' ')
for g in $gap_ids; do
  echo "$caps" | grep -qx "$g" && fail "registry.yaml: '$g' is in known_gaps but is also declared as a capability"
done

# 4d. Altitude is one of the three levels the escalation ladder knows about.
while read -r alt; do
  case "$alt" in
    implementation|behavior|product) ;;
    *) fail "registry.yaml: unknown altitude '$alt' (expected implementation | behavior | product)" ;;
  esac
done < <(grep -E '^    altitude: ' registry.yaml | sed 's/.*altitude: //; s/#.*//' | tr -d ' ')

# 4e. README headcount matches the registry — on BOTH axes now. The roster
#     drifted once already (design-reviewer registered, defined, absent from
#     the README table) and the org model added a second number that can drift
#     independently: roles can outnumber people, or vice versa, the moment a
#     role goes unstaffed or gains a second person.
n_res=$(echo "$registered" | wc -w | tr -d ' ')
n_people=$(echo "$callsigns" | grep -c .)
readme_line=$(grep -oE '\*\*Headcount: [0-9]+ roles?, [0-9]+ people' README.md | head -1)
if [[ -z "$readme_line" ]]; then
  fail "README.md: no '**Headcount: N roles, M people' line to check against the registry"
else
  n_readme_roles=$(echo "$readme_line" | grep -oE '[0-9]+ roles?' | grep -oE '[0-9]+')
  n_readme_people=$(echo "$readme_line" | grep -oE '[0-9]+ people' | grep -oE '[0-9]+')
  [[ "$n_readme_roles" == "$n_res" ]] || fail "README.md claims $n_readme_roles roles but registry.yaml declares $n_res"
  [[ "$n_readme_people" == "$n_people" ]] || fail "README.md claims $n_readme_people people but registry.yaml declares $n_people"
fi
for r in $registered; do
  grep -q "\`$r\`" README.md || fail "README.md: '$r' is in registry.yaml but appears nowhere in the README roster"
done

# 4f. Callsigns. The CTO's rule (2026-08-16) is that a callsign is a CHARACTER,
#     that character is NOT HUMAN, and the name ENCODES THE JOB — amended
#     2026-08-17 (docs/org-model.md): the job, when the role has one person,
#     or the PERSONA, when it has several. "Non-human" is judgement and has no
#     honest mechanical check — a deny-list of names would be brittle and give
#     false confidence, so it is deliberately not attempted. What IS checkable:
#     the name exists on `people:`, it is unique across `people:` AND
#     `retired_callsigns:` (4i, below, shares `$callsigns`), every role has at
#     least one person, every person names a real role, and someone wrote the
#     one-clause justification in the README. That last one does not check the
#     rule; it checks that a human ARGUED it, which is the same shape as the
#     gap-entry-required check above and is usually the better guard. The
#     judgement half stays with roster-steward.
n_cs=$(echo "$callsigns" | grep -c .)
n_people=$(echo "$roles_of_people" | grep -c .)
[[ "$n_cs" == "$n_people" ]] || fail "registry.yaml: $n_people people but $n_cs callsigns — every person needs exactly one"
while read -r dup; do
  [[ -n "$dup" ]] && fail "registry.yaml: callsign '$dup' is used by more than one person"
done < <(echo "$callsigns" | sort | uniq -d)
for r in $registered; do
  echo "$roles_of_people" | grep -qx "$r" || fail "registry.yaml: role '$r' has no person in people: — every role needs at least one"
done
while read -r ro; do
  [[ -z "$ro" ]] && continue
  echo "$registered" | grep -qx "$ro" || fail "registry.yaml: a people: entry names role '$ro', which is not a registered resource"
done < <(echo "$roles_of_people")
while read -r cs; do
  [[ -z "$cs" ]] && continue
  grep -q "\*\*$cs\*\*" README.md || fail "README.md: callsign '$cs' has no bolded one-clause justification in the name-encoding paragraph (skills/hire, 'The callsign rule')"
done < <(echo "$callsigns")

# 4h. THE CALLSIGN IS ON THE DISPATCH SURFACE, not just in the registry.
#     Added 2026-08-16 after the CTO asked "what's with these names,
#     implementer, architect?" and then "even HR doesn't have a name?". Every
#     callsign was already correct in registry.yaml, README.md and
#     docs/delegation.md — and every one of those is a v-team-internal file
#     that a dispatcher never opens. What a dispatcher opens is
#     resources/<name>.md (mirrored to a product's .claude/agents/), whose
#     frontmatter is `name: <job title>` and whose description said nothing
#     about the callsign. So briefs and CTO reports addressed resources by job
#     title while the registry looked green. 4f checked that a name was ARGUED;
#     nothing checked that it was USABLE. This does.
#
#     The registry-side half of the rule cannot catch this and never could: the
#     defect was not a missing callsign, it was a callsign with no path to the
#     place the name gets spoken.
while read -r pair; do
  [[ -z "$pair" ]] && continue
  r="${pair%%|*}"; cs="${pair##*|}"
  f="resources/$r.md"
  [[ -f "$f" ]] || continue
  desc=$(sed -n '2,/^---$/p' "$f" | grep -m1 '^description: ')
  # Match against the file with newlines flattened, so a reflowed paragraph
  # does not fail a check about the words rather than the line breaks.
  flat=$(tr '\n' ' ' < "$f" | tr -s ' ')
  grep -qF "$cs" <<<"$desc" \
    || fail "$f: frontmatter description does not name the callsign '$cs' — the description is what a dispatcher reads when it picks and addresses this resource, so a description without the callsign is how '$r' gets called by job title"
  grep -qF "Callsign **$cs**" <<<"$flat" \
    || fail "$f: missing the 'Callsign **$cs** — <one-clause>' line under the H1"
  grep -qF "You are $cs" <<<"$flat" \
    || fail "$f: missing 'You are $cs' — the resource has to be told its own name, or it signs its work with the job title it was dispatched as"
  # The brain source id is the callsign, lowercased. 4g checks the stores that
  # EXIST, needs a live brain, and degrades to a warning when PGLite is locked.
  # This checks the string the resource is told to pass, needs nothing, and
  # always runs — so a rename that forgets the source id fails here even when
  # 4g cannot run. An unmigrated source does not error at runtime; it silently
  # writes into the federated `default` store.
  # Three shapes now bind a resource to its store, and the file must use at
  # least one of them. The store id is the callsign lowercased in all three:
  #   MCP          mcp__vteam-brain-<cs>__*   — the tool namespace IS the grant
  #   thin client  ~/.v-team/clients/<cs>     — the config holding its OAuth client
  #   direct CLI   --source <cs>              — only correct with no server running
  # Checking only the last one would fail every file the moment the recipe
  # stopped being a `--source` flag, which is exactly what happened on
  # 2026-08-17: the guard asserted the shape of the recipe instead of the fact
  # it exists to protect, which is that the file names THIS resource's store.
  lc_cs=$(tr '[:upper:]' '[:lower:]' <<<"$cs")
  grep -qF -- "--source $lc_cs" <<<"$flat" \
    || grep -qF -- "clients/$lc_cs" <<<"$flat" \
    || grep -qF -- "vteam-brain-$lc_cs" <<<"$flat" \
    || fail "$f: never names its own brain store '$lc_cs' — expected one of 'mcp__vteam-brain-$lc_cs__*', '~/.v-team/clients/$lc_cs', or '--source $lc_cs'. The store id is the callsign lowercased, and a mismatch sends this resource's memory into the federated 'default' store instead of erroring (docs/memory.md)"
done < <(echo "$person_rows" | awk -F'|' '{print $2 "|" $1}')

# 4i. The retired-callsign alias table stays resolvable. A trailer is never
#     rewritten, so every retired callsign is permanently in history and
#     record.sh has to map it to someone. An entry pointing at a resource that
#     no longer exists resolves to nothing and credits nobody — the silent zero
#     again, this time aimed at a track record. Also: a retired callsign must
#     not be reused as an active one, or one name means two resources across
#     history and no projection can tell them apart.
ret_pairs=$(awk '
  /^retired_callsigns:/ { inb=1; next }
  /^[a-z_]+:/           { inb=0 }
  inb && /^  - callsign: / { c=$0; sub(/^  - callsign: /,"",c); gsub(/[[:space:]]/,"",c) }
  inb && /^    resource: /  { r=$0; sub(/^    resource: /,"",r); gsub(/[[:space:]]/,"",r)
                              if (c != "") { print c "|" r; c="" } }
' registry.yaml)
while read -r pair; do
  [[ -z "$pair" ]] && continue
  rc="${pair%%|*}"; rr="${pair##*|}"
  echo "$registered" | grep -qx "$rr" \
    || fail "registry.yaml: retired callsign '$rc' maps to '$rr', which is not a resource — a trailer carrying '$rc' would resolve to nobody (retired_callsigns maps to a RESOURCE ID, never to another callsign)"
  grep -qxF "$rc" <<<"$callsigns" \
    && fail "registry.yaml: '$rc' is listed as retired but is also an active callsign — one name cannot mean two resources across history"
done < <(echo "$ret_pairs")

# 4j. A misattributed-run entry names a real resource too, for the same reason.
while read -r ar; do
  [[ -z "$ar" ]] && continue
  echo "$registered" | grep -qx "$ar" \
    || fail "registry.yaml: misattributed_runs names actual_resource '$ar', which is not a resource"
done < <(grep -E '^    actual_resource: ' registry.yaml | sed 's/.*actual_resource: //; s/#.*//' | tr -d ' ')

# 4g. Every resource has its OWN isolated brain source. Isolation is supposed to
#     be mechanical (docs/memory.md), and it silently was not: a gbrain write to
#     a source that does not exist lands in `default`, which is FEDERATED — so
#     three resources' orientation notes went into the store every resource
#     searches, and overwrote each other. Checked only where the brain actually
#     exists; CI has no brain and must not fail on its absence.
VT_BRAIN_HOME="${VT_BRAIN_HOME:-$HOME/.v-team/brain}"
# `gbrain` lives in ~/.bun/bin, which is not on a non-interactive PATH — every
# resource definition says so, and this script forgot. Without this line the
# whole check was skipped on the maintainer's own machine (2026-08-16).
GBRAIN_BIN="$(command -v gbrain 2>/dev/null || true)"
[[ -z "$GBRAIN_BIN" && -x "$HOME/.bun/bin/gbrain" ]] && GBRAIN_BIN="$HOME/.bun/bin/gbrain"
#     TWO WAYS TO ASK, because neither works in both states. The CLI opens the
#     PGLite file directly and is refused while `gbrain serve` holds it; the
#     HTTP server answers only while that same `serve` is running. So try HTTP
#     first, fall back to the CLI, and warn only when BOTH are unavailable.
#
#     The 2026-08-16 version piped the CLI straight into `awk`. A pipeline
#     reports the exit status of its LAST stage, so gbrain's `1` was thrown away
#     and its lock message — which goes to stderr, and was being discarded by
#     `2>/dev/null` — became an empty string that read as "no sources". That is
#     precisely the silent degradation this check exists to catch, committed
#     inside the check itself. Capture status separately, never from a pipeline.
VT_MCP_PORT="${VT_MCP_PORT:-7433}"
VT_MCP_TOKEN_FILE="${VT_MCP_TOKEN_FILE:-$HOME/.v-team/secrets/mcp-token}"
if [[ -d "$VT_BRAIN_HOME/.gbrain" ]]; then
  srcs=""; how=""
  # (a) HTTP MCP — works precisely when the CLI cannot.
  if [[ -s "$VT_MCP_TOKEN_FILE" ]] \
     && curl -fsS --max-time 3 "http://127.0.0.1:$VT_MCP_PORT/health" >/dev/null 2>&1; then
    body=$(curl -fsS --max-time 10 -X POST "http://127.0.0.1:$VT_MCP_PORT/mcp" \
             -H "Authorization: Bearer $(cat "$VT_MCP_TOKEN_FILE")" \
             -H 'Content-Type: application/json' \
             -H 'Accept: application/json, text/event-stream' \
             -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"sources_list","arguments":{}}}' 2>/dev/null) || body=""
    if [[ -n "$body" ]]; then
      srcs=$(printf '%s' "$body" | sed 's/^data: //' \
             | grep -oE '\\"id\\": ?\\"[a-z0-9_-]+\\"' | sed -E 's/.*\\"([a-z0-9_-]+)\\"$/\1/' | sort -u)
      [[ -n "$srcs" ]] && how="http mcp :$VT_MCP_PORT"
    fi
  fi
  # (b) CLI — works precisely when no server holds the lock.
  if [[ -z "$srcs" && -n "$GBRAIN_BIN" ]]; then
    cli_out=$(GBRAIN_HOME="$VT_BRAIN_HOME" GBRAIN_NO_RETRY_CONNECT=1 "$GBRAIN_BIN" sources list 2>/dev/null) && cli_rc=0 || cli_rc=$?
    if [[ $cli_rc -eq 0 ]]; then
      srcs=$(printf '%s\n' "$cli_out" | awk '$1!="SOURCES" && $1!~/^─/ {print $1}')
      how="cli"
    fi
  fi

  if [[ -n "$srcs" ]]; then
    while read -r cs; do
      [[ -z "$cs" ]] && continue
      lc=$(echo "$cs" | tr '[:upper:]' '[:lower:]')
      echo "$srcs" | grep -qx "$lc" || fail "brain: no isolated source '$lc' — that resource's memory writes fall through to the federated 'default' store (./scripts/setup-brain.sh)"
    done < <(echo "$callsigns")
    echo "  4g: per-resource brain sources verified via $how"
  else
    # A brain that exists but will not answer is NOT a pass — same shape of bug
    # as 4h: a guard that looks green because it never ran.
    echo "::warning::brain: $VT_BRAIN_HOME/.gbrain exists but neither the HTTP MCP server (127.0.0.1:$VT_MCP_PORT) nor the CLI could list sources — per-resource source isolation was NOT verified this run"
  fi
fi

# 5. Autonomy is one of the three known values — on BOTH axes now: a person's
#    own level (`autonomy:`, on people:) and their role's ceiling
#    (`autonomy_ceiling:`, on resources:). docs/org-model.md, stage 2.
while read -r a; do
  case "$a" in
    recommend|branch|merge-on-green) ;;
    *) fail "registry.yaml: unknown autonomy '$a' (expected recommend | branch | merge-on-green)" ;;
  esac
done < <(grep -E '^    autonomy: ' registry.yaml | sed 's/.*autonomy: //; s/#.*//' | tr -d ' ')
while read -r a; do
  case "$a" in
    recommend|branch|merge-on-green) ;;
    *) fail "registry.yaml: unknown autonomy_ceiling '$a' (expected recommend | branch | merge-on-green)" ;;
  esac
done < <(grep -E '^    autonomy_ceiling: ' registry.yaml | sed 's/.*autonomy_ceiling: //; s/#.*//' | tr -d ' ')

# 4k. A person may not exceed their role's ceiling — autonomy_ceiling is the
#     most anyone in that job may ever hold (docs/org-model.md). Numbered 4k
#     rather than appended after 7: it belongs beside 4f/4h, which is where a
#     reader looking for "what does validate.sh say about people:" will look.
vt_autonomy_rank() { case "$1" in recommend) echo 0 ;; branch) echo 1 ;; merge-on-green) echo 2 ;; *) echo -1 ;; esac; }
while IFS='|' read -r cs role aut; do
  [[ -z "$cs" ]] && continue
  ceiling=$(awk "/^  - name: $role\$/,/^\$/" registry.yaml | grep -m1 '^    autonomy_ceiling: ' | sed 's/.*autonomy_ceiling: //; s/[[:space:]]*#.*//' | sed 's/[[:space:]]*$//')
  if [[ -z "$ceiling" ]]; then
    fail "registry.yaml: role '$role' (person '$cs') declares no autonomy_ceiling"
    continue
  fi
  p_rank=$(vt_autonomy_rank "$aut"); c_rank=$(vt_autonomy_rank "$ceiling")
  if (( p_rank > c_rank )); then
    fail "registry.yaml: '$cs' holds autonomy '$aut', above role '$role''s ceiling '$ceiling' — nobody may exceed their role's ceiling"
  fi
done <<< "$person_rows"

# 6. A NEW person must start at recommend — probation is not optional.
#    "New" means: this callsign did not exist ANYWHERE in the base ref's
#    registry.yaml — not as a role-row callsign (the pre-migration shape),
#    not already on people:, not retired. That is the mechanical form of
#    stage 1's one exemption (docs/org-model.md): the eight rows this
#    migration seeds carry forward an autonomy that already existed, they are
#    not granted one, and the check has to know the difference or it would
#    block its own migration. Enforced only against the base ref in CI, where
#    it is knowable.
if [[ -n "${GITHUB_BASE_REF:-}" ]]; then
  base_registry=$(git show "origin/$GITHUB_BASE_REF:registry.yaml" 2>/dev/null || true)
  if [[ -n "$base_registry" ]]; then
    base_known_callsigns=$(
      { grep -E '^    callsign: ' <<<"$base_registry"                                    # pre-migration: on resources:
        awk '/^people:/{i=1;next} /^[a-z_]+:/{i=0} i&&/^  - callsign: /' <<<"$base_registry"  # already on people:
        awk '/^retired_callsigns:/{i=1;next} /^[a-z_]+:/{i=0} i&&/^  - callsign: /' <<<"$base_registry"
      } | sed 's/.*callsign: //; s/[[:space:]]*#.*//' | sed 's/[[:space:]]*$//'
    )
    while IFS='|' read -r cs role aut; do
      [[ -z "$cs" ]] && continue
      grep -qxF "$cs" <<<"$base_known_callsigns" && continue   # existed before — carried over, exempt
      [[ "$aut" == "recommend" ]] \
        || fail "registry.yaml: '$cs' is a new person (role '$role') but starts at '$aut' — every new person starts at recommend, no exceptions (docs/org-model.md)"
    done <<< "$person_rows"
  fi

  # 7. A hire is evidence or it is not a hire. A PR that adds a resource must
  #    add the ledger/gaps/ entry recording every /hire check and its answer —
  #    including the ones that failed. This is the mechanical half of "hires are
  #    recorded"; whether the recurrence bar was actually MET stays judgement,
  #    and belongs to roster-steward.
  new_res=$(git diff --name-only --diff-filter=A "origin/$GITHUB_BASE_REF"...HEAD -- resources/ || true)
  if [[ -n "$new_res" ]]; then
    new_gap=$(git diff --name-only --diff-filter=A "origin/$GITHUB_BASE_REF"...HEAD -- ledger/gaps/ || true)
    [[ -n "$new_gap" ]] || fail "this PR adds $(echo "$new_res" | wc -l | tr -d ' ') resource(s) but no ledger/gaps/ entry — a hire without its recorded checks is not reviewable (skills/hire)"
  fi
fi

[[ $status -eq 0 ]] && echo "registry valid: $(echo "$registered" | wc -w | tr -d ' ') roles, $(echo "$callsigns" | grep -c .) people"
exit $status
