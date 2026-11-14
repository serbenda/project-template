#!/usr/bin/env bash
# Tests for scripts/check-records.sh: builds throwaway git repos and checks each case passes (0) or fails (1).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
failures=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# new_repo <name>: a minimal repo with the script, a STATE and a WORKLOG, and one base commit
new_repo() {
  local d="$tmp/$1"
  mkdir -p "$d/scripts" "$d/docs"
  cp "$root/scripts/check-records.sh" "$d/scripts/"
  printf '# State\n' > "$d/docs/STATE.md"
  printf '# Worklog\n' > "$d/docs/WORKLOG.md"
  git -C "$d" init -q
  git -C "$d" -c user.email=owner@example.com -c user.name=Owner add -A
  git -C "$d" -c user.email=owner@example.com -c user.name=Owner -c core.hooksPath=/dev/null commit -qm base
  echo "$d"
}
commit() {  # commit <repo> <email> <message>
  git -C "$1" add -A
  git -C "$1" -c user.email="$2" -c user.name=x -c core.hooksPath=/dev/null commit -qm "$3"
}
check() {  # check <expected> <description> <repo> [range args...]
  local expected="$1" desc="$2" repo="$3" actual; shift 3
  bash "$repo/scripts/check-records.sh" "$@" >/dev/null 2>&1
  actual=$?
  if [[ "$actual" == "$expected" ]]; then echo "  ok    [$actual] $desc"
  else echo "  FAIL  [$actual, expected $expected] $desc"; failures=$((failures + 1)); fi
}

r=$(new_repo code-with-worklog); b=$(git -C "$r" rev-parse HEAD)
echo 'x' > "$r/app.py"; echo '## entry' >> "$r/docs/WORKLOG.md"; commit "$r" owner@example.com "feat: x"
check 0 "code change with worklog entry" "$r" "$b" "$(git -C "$r" rev-parse HEAD)"

r=$(new_repo code-without-worklog); b=$(git -C "$r" rev-parse HEAD)
echo 'x' > "$r/app.py"; commit "$r" owner@example.com "feat: x"
check 1 "code change without worklog entry" "$r" "$b" "$(git -C "$r" rev-parse HEAD)"

r=$(new_repo docs-only); b=$(git -C "$r" rev-parse HEAD)
echo 'more' >> "$r/docs/STATE.md"; echo 'readme' > "$r/README.md"; commit "$r" owner@example.com "docs: x"
check 0 "documentation-only change" "$r" "$b" "$(git -C "$r" rev-parse HEAD)"

r=$(new_repo dependabot); b=$(git -C "$r" rev-parse HEAD)
mkdir -p "$r/.github/workflows"; echo 'on: push' > "$r/.github/workflows/ci.yml"
commit "$r" "49699333+dependabot[bot]@users.noreply.github.com" "ci: bump action"
check 0 "Dependabot-only change" "$r" "$b" "$(git -C "$r" rev-parse HEAD)"

r=$(new_repo state-too-long)
for i in $(seq 1 151); do echo "line $i" >> "$r/docs/STATE.md"; done
check 1 "STATE.md over 150 lines" "$r"

r=$(new_repo state-ok)
check 0 "STATE.md within the limit" "$r"

echo
if (( failures == 0 )); then echo "✓ All check-records tests pass."; exit 0
else echo "✗ $failures check-records tests fail."; exit 1; fi
