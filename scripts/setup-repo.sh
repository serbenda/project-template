#!/usr/bin/env bash
# Sets up a repo freshly created from the template.
# Requires: gh authenticated (gh auth login) with admin permissions on the repo.
# Usage: ./scripts/setup-repo.sh            (detects the repo of the current directory)
#        ./scripts/setup-repo.sh owner/repo
set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
NAME="${REPO#*/}"
echo "→ Configuring $REPO"

# 1. Local commit authorship
git config user.name  "Sergio Santiago Bendaña Quesada"
git config user.email "serbenda@gmail.com"
# Git hook that strips AI signatures from commits and checks the author
git config core.hooksPath .githooks
chmod +x .githooks/* .claude/hooks/*.sh scripts/*.sh

# 2. Replace the project name placeholder
grep -rl --exclude-dir=.git --exclude=setup-repo.sh "PROJECT_NAME" . | xargs -r sed -i.bak "s/PROJECT_NAME/$NAME/g"
find . -name '*.bak' -not -path './.git/*' -delete

# 3. development branch
if ! git ls-remote --exit-code --heads origin development >/dev/null 2>&1; then
  git push origin "HEAD:refs/heads/development"
fi
git fetch origin development
git switch development 2>/dev/null || git switch -c development --track origin/development

# 4. Repo settings
#    delete_branch_on_merge=false: otherwise GitHub would delete development when merging the PR to main.
gh api -X PATCH "repos/$REPO" \
  -F delete_branch_on_merge=false \
  -F allow_merge_commit=true \
  -F allow_squash_merge=true \
  -F allow_rebase_merge=false \
  -F has_wiki=false >/dev/null

# 5. Security: Dependabot alerts, private vulnerability reporting,
#    secret scanning and push protection (free on public repos)
warn() { echo "  ⚠ Could not enable: $1 (check it by hand in Settings → Security)" >&2; }
gh api -X PUT "repos/$REPO/vulnerability-alerts" >/dev/null 2>&1 || warn "Dependabot alerts"
gh api -X PUT "repos/$REPO/automated-security-fixes" >/dev/null 2>&1 || warn "Dependabot automated security fixes"
gh api -X PUT "repos/$REPO/private-vulnerability-reporting" >/dev/null 2>&1 || warn "private vulnerability reporting"
gh api -X PATCH "repos/$REPO" --input - >/dev/null 2>&1 <<'JSON' || warn "secret scanning and push protection (private repos require GitHub Advanced Security)"
{"security_and_analysis": {
  "secret_scanning": {"status": "enabled"},
  "secret_scanning_push_protection": {"status": "enabled"}
}}
JSON

# 6. Protect main with a ruleset: PR required, green CI, no force-push or deletion
gh api -X POST "repos/$REPO/rulesets" --input - >/dev/null <<'JSON'
{
  "name": "Protect main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": true
    }},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": false,
      "required_status_checks": [
        {"context": "Secrets"},
        {"context": "Hook"},
        {"context": "Authorship"}
      ]
    }}
  ]
}
JSON

# 6b. Optional: require signed commits (SIGNED_COMMITS=1 ./scripts/setup-repo.sh). Set up your signing key first:
#     docs/SECURITY_GUIDE.md → "Signing commits"
if [[ "${SIGNED_COMMITS:-0}" == "1" ]]; then
  gh api -X POST "repos/$REPO/rulesets" --input - >/dev/null <<'JSON'
{"name": "Signed commits", "target": "branch", "enforcement": "active",
 "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH", "refs/heads/development"], "exclude": []}},
 "rules": [{"type": "required_signatures"}]}
JSON
  echo "  ✓ Signed commits required on main and development"
fi

# 7. Basic labels
for label in "bug:d73a4a" "enhancement:a2eeef" "docs:0075ca" "security:b60205" "dependencies:0366d6"; do
  gh label create "${label%%:*}" --color "${label##*:}" --repo "$REPO" --force >/dev/null
done

echo "✓ Done. Work on 'development' and open a PR to 'main'."
echo "  Review the placeholder changes with: git status"
