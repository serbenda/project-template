#!/usr/bin/env bash
# Brings the template's improvements into a project created from an older version of it.
# Run it from the template repo, pointing at the project. Dry run by default: it changes nothing
# until you pass --apply, and even then it only replaces the files the template owns.
#
# Usage: scripts/sync-from-template.sh <path-to-project>            report what would change
#        scripts/sync-from-template.sh <path-to-project> --diff     ...and show the full diffs
#        scripts/sync-from-template.sh <path-to-project> --apply    replace the template-owned files
#
# After --apply: review `git diff` in the project, merge the "review" files by hand,
# add a worklog entry and commit on a branch (never on main).
set -euo pipefail

template="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:-}"
mode="${2:-report}"
[[ -z "$target" || ! -d "$target" ]] && { echo "Usage: $0 <path-to-project> [--diff|--apply]" >&2; exit 2; }
target="$(cd "$target" && pwd)"
[[ "$target" == "$template" ]] && { echo "The target is the template itself." >&2; exit 2; }

git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "$target is not a git repo." >&2; exit 2; }
branch="$(git -C "$target" branch --show-current)"
if [[ "$mode" == "--apply" ]]; then
  [[ "$branch" =~ ^(main|master)$ ]] && { echo "The project is on $branch: switch to development or a branch first." >&2; exit 1; }
  [[ -n "$(git -C "$target" status --porcelain)" ]] && { echo "The project has uncommitted changes: commit or stash them first." >&2; exit 1; }
fi

# Files the template owns: replaced as a whole on --apply. Projects should not customise them.
owned=(
  .claude/hooks/guard.sh
  .claude/skills/record-changes/SKILL.md
  .githooks/commit-msg
  .githooks/pre-commit
  scripts/test-guard.sh
  scripts/check-records.sh
  scripts/test-check-records.sh
  scripts/sync-from-template.sh
)
while IFS= read -r f; do owned+=("$f"); done < <(cd "$template" && ls .claude/commands/*.md .claude/agents/*.md)

# Files projects usually adapt (permissions for their stack, CI jobs, rules): only reported, never copied.
review=(
  .claude/settings.json
  .github/workflows/ci.yml
  .github/dependabot.yml
  AGENTS.md
  CLAUDE.md
  docs/DEFINITION_OF_DONE.md
  docs/SETUP.md
  scripts/setup-repo.sh
)

# Files from the older, Spanish version of the template, now renamed.
legacy=(
  .claude/hooks/guardia.sh scripts/test-guardia.sh
  .claude/commands/estado.md .claude/commands/nueva-fase.md .claude/commands/cerrar-fase.md .claude/commands/preparar-pr.md
  .claude/agents/revisor-seguridad.md .claude/agents/revisor-dod.md .claude/agents/revisor-arquitectura.md
  .claude/skills/registro-cambios
)

version="$(git -C "$template" rev-parse --short HEAD)"
echo "→ Template $version → $target (branch: ${branch:-?})"
[[ -n "$(git -C "$template" status --porcelain)" ]] && echo "  ⚠ The template has uncommitted changes: the files are copied as they are on disk."
[[ -f "$target/.claude/TEMPLATE_VERSION" ]] && echo "  Project was last synced from: $(cat "$target/.claude/TEMPLATE_VERSION")"

changes=0
echo; echo "Template-owned files (replaced with --apply):"
for f in "${owned[@]}"; do
  if [[ ! -e "$target/$f" ]]; then state="NEW"
  elif cmp -s "$template/$f" "$target/$f"; then state="same"
  else state="CHANGED"; fi
  [[ "$state" == "same" ]] && continue
  changes=$((changes + 1))
  printf '  %-8s %s\n' "$state" "$f"
  [[ "$mode" == "--diff" && "$state" == "CHANGED" ]] && diff -u "$target/$f" "$template/$f" | sed 's/^/      /' || true
  if [[ "$mode" == "--apply" ]]; then
    mkdir -p "$(dirname "$target/$f")"
    cp "$template/$f" "$target/$f"
    [[ "$f" == *.sh || "$f" == .githooks/* ]] && chmod +x "$target/$f"
  fi
done
(( changes == 0 )) && echo "  (all up to date)"

echo; echo "Files to merge by hand (never copied):"
pending=0
for f in "${review[@]}"; do
  [[ -e "$template/$f" ]] || continue
  if [[ ! -e "$target/$f" ]]; then echo "  MISSING  $f   → cp \"$template/$f\" \"$target/$f\""; pending=$((pending + 1))
  elif ! cmp -s "$template/$f" "$target/$f"; then
    echo "  DIFFERS  $f   → diff -u \"$target/$f\" \"$template/$f\""; pending=$((pending + 1))
    [[ "$mode" == "--diff" ]] && { diff -u "$target/$f" "$template/$f" | sed 's/^/      /' || true; }
  fi
done
(( pending == 0 )) && echo "  (nothing to merge)"

found=()
for f in "${legacy[@]}"; do [[ -e "$target/$f" ]] && found+=("$f"); done
if (( ${#found[@]} > 0 )); then
  echo; echo "Files from the older Spanish template (renamed since): remove them once the new ones are in place:"
  printf '  %s\n' "${found[@]}"
  if grep -q 'guardia.sh' "$target/.claude/settings.json" 2>/dev/null; then
    echo "  ⚠ .claude/settings.json still runs .claude/hooks/guardia.sh: point the hook to guard.sh when you merge settings.json."
  fi
fi

echo
if [[ "$mode" == "--apply" ]]; then
  echo "$version" > "$target/.claude/TEMPLATE_VERSION"
  echo "✓ Applied. In the project: review 'git diff', merge the files above by hand, run scripts/test-guard.sh,"
  echo "  add a worklog entry and commit on '$branch'."
else
  echo "Dry run: nothing changed. Use --diff to see the diffs or --apply to replace the template-owned files."
fi
