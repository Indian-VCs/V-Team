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

# 4. Autonomy is one of the three known values.
while read -r a; do
  case "$a" in
    recommend|branch|merge-on-green) ;;
    *) fail "registry.yaml: unknown autonomy '$a' (expected recommend | branch | merge-on-green)" ;;
  esac
done < <(grep -E '^    autonomy: ' registry.yaml | sed 's/.*autonomy: //; s/#.*//' | tr -d ' ')

# 5. A new or changed resource must start at recommend — probation is not
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
fi

[[ $status -eq 0 ]] && echo "registry valid: $(echo "$registered" | wc -w | tr -d ' ') resources"
exit $status
