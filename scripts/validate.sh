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

# 4e. README headcount matches the registry. The roster drifted once already —
#     design-reviewer was registered, defined and absent from the README table.
#     Nothing caught it, so now something does.
n_res=$(echo "$registered" | wc -w | tr -d ' ')
n_readme=$(grep -oE '\*\*Headcount: [0-9]+ resources' README.md | grep -oE '[0-9]+' | head -1)
if [[ -z "$n_readme" ]]; then
  fail "README.md: no '**Headcount: N resources' line to check against the registry"
elif [[ "$n_readme" != "$n_res" ]]; then
  fail "README.md claims $n_readme resources but registry.yaml declares $n_res"
fi
for r in $registered; do
  grep -q "\`$r\`" README.md || fail "README.md: '$r' is in registry.yaml but appears nowhere in the README roster"
done

# 5. Autonomy is one of the three known values.
while read -r a; do
  case "$a" in
    recommend|branch|merge-on-green) ;;
    *) fail "registry.yaml: unknown autonomy '$a' (expected recommend | branch | merge-on-green)" ;;
  esac
done < <(grep -E '^    autonomy: ' registry.yaml | sed 's/.*autonomy: //; s/#.*//' | tr -d ' ')

# 6. A new or changed resource must start at recommend — probation is not
#    optional. Enforced only against the base ref in CI, where it is knowable.
if [[ -n "${GITHUB_BASE_REF:-}" ]]; then
  changed=$(git diff --name-only "origin/$GITHUB_BASE_REF"...HEAD -- resources/ || true)
  for f in $changed; do
    n="$(basename "$f" .md)"
    aut=$(awk "/^  - name: $n\$/,/^  - name: /" registry.yaml | grep -m1 '^    autonomy: ' | sed 's/.*autonomy: //; s/#.*//' | tr -d ' ')
    if [[ -n "$aut" && "$aut" != "recommend" ]]; then
      fail "$f changed but '$n' has autonomy '$aut' — a changed resource re-enters probation at 'recommend' (docs/charter.md)"
    fi
  done

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

[[ $status -eq 0 ]] && echo "registry valid: $(echo "$registered" | wc -w | tr -d ' ') resources"
exit $status
