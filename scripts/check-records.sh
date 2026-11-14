#!/usr/bin/env bash
# Checks that the project's written memory is kept, so it doesn't depend on the agent remembering to do it.
#   1. docs/STATE.md has at most 150 lines.
#   2. With BASE and HEAD (a PR): if the changes touch anything other than documentation,
#      docs/WORKLOG.md must change too. Dependabot-only ranges are exempt.
# Usage: scripts/check-records.sh                 (only the STATE size)
#        scripts/check-records.sh BASE HEAD       (also the worklog rule for that range)
set -euo pipefail
cd "$(dirname "$0")/.."

failed=0
max_state=150

lines=$(wc -l < docs/STATE.md | tr -d ' ')
if (( lines > max_state )); then
  echo "✗ docs/STATE.md has $lines lines (max $max_state). Replace what is outdated and link instead of copying." >&2
  failed=1
else
  echo "✓ docs/STATE.md: $lines/$max_state lines."
fi

if [[ $# -eq 2 ]]; then
  base="$1" head="$2"
  authors=$(git log --no-merges --format='%ae' "$base..$head" | sort -u)
  if [[ -n "$authors" ]] && ! grep -qv 'dependabot\[bot\]' <<< "$authors"; then
    echo "✓ Only Dependabot commits: worklog not required."
  else
    changed=$(git diff --name-only "$base" "$head")
    # Documentation-only changes don't need a worklog entry: docs/, Markdown files and LICENSE.
    code=$(grep -Ev '^docs/|\.md$|^LICENSE' <<< "$changed" || true)
    if [[ -z "$code" ]]; then
      echo "✓ Documentation-only changes: worklog not required."
    elif grep -qx 'docs/WORKLOG.md' <<< "$changed"; then
      echo "✓ docs/WORKLOG.md updated along with the changes."
    else
      echo "✗ These changes touch more than documentation but docs/WORKLOG.md was not updated:" >&2
      sed 's/^/    /' <<< "$code" >&2
      echo "  Add an entry with the record-changes skill (why, what was rejected, how it was tested, pending)." >&2
      failed=1
    fi
  fi
fi

exit $failed
