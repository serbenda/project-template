# Security: what this template protects and what you have to do

Security works in layers. If one fails, the next one stops the blow.

```
Your GitHub account ─┬─ 2FA with security key/passkey, expiring tokens, reviewed apps
Your Mac ────────────┼─ FileVault, global ~/.claude/settings.json, keys in the keychain
The agent (Claude) ──┼─ .claude/settings.json (permissions + sandbox) + .claude/hooks/guard.sh
The design ──────────┼─ docs/THREAT_MODEL.md + Security impact per phase + security-reviewer
Local git ───────────┼─ .githooks/pre-commit (Gitleaks) + commit-msg (AI signatures, author)
GitHub (server) ─────┴─ main ruleset, CI (Secrets, Authorship, Hook, Records, SAST, Dependencies)
```

## 1. What the template already does

| Layer | Protection | Where |
|---|---|---|
| Agent | No AI signature in commits or PRs | `.claude/settings.json` → `attribution` |
| Agent | Does not read `.env`, SSH keys, AWS/gh credentials | `permissions.deny` + hook |
| Agent | Asks before `git push`, `curl`, installing packages | `permissions.ask` |
| Agent | **Sandbox**: shell commands can only write inside the project and reach an allow-list of domains (GitHub, npm, PyPI, Go, crates, pub); `~/.ssh`, `~/.aws`, the gh token and the keychain are unreadable. `git`, `gh` and `docker` run outside it (the hook still checks them). Any new domain must be added on purpose | `.claude/settings.json` → `sandbox` |
| Agent | Blocks push to main, force push, `gh pr merge`, `rm -rf`, `curl \| sh`, dumping tokens, writing secrets to files | `.claude/hooks/guard.sh` (tested by `scripts/test-guard.sh`) |
| Git | Strips AI `Co-Authored-By` and rejects commits with a different email | `.githooks/commit-msg` |
| Git | Scans staged changes for secrets with Gitleaks before the commit exists (warns if Gitleaks isn't installed) | `.githooks/pre-commit` |
| GitHub | `main` protected: PR required, green CI, no force-push or deletion. **Not available on private repos with GitHub Free**: the script warns and exits with an error | `scripts/setup-repo.sh` |
| CI | Gitleaks (secrets), AI signatures and author, shellcheck and hook tests, worklog entry and STATE size (Records) | `.github/workflows/ci.yml` |
| Dependencies | Dependabot updates the pinned GitHub Actions weekly, with a 7-day **cooldown** so a freshly compromised release isn't proposed | `.github/dependabot.yml` |
| CI | **SAST**: Semgrep (`p/default`, any language) fails on injection, unsafe deserialisation, weak crypto, debug flags, insecure CI… | `ci.yml` → `sast` |
| CI | **Dependencies**: OSV-Scanner fails if any lockfile has a dependency with a known vulnerability | `ci.yml` → `dependencies` |
| Design | Threat model before the first sensitive code, *Security impact* per phase, security DoD per project type (authorisation per object, password hashing, rate limits, CORS, headers, cookies, uploads, backups) | `docs/THREAT_MODEL.md`, `docs/DEFINITION_OF_DONE.md` |
| CI | Actions pinned to a **SHA** (not to a tag that can be moved) | all workflows |
| CI | Minimal permissions (`contents: read`) and PR text passed via environment variables (no injection) | workflows |
| GitHub | Dependabot alerts and private vulnerability reporting | `scripts/setup-repo.sh` |

## 2. What you have to do (once)

### GitHub account
- [ ] **2FA with a passkey or physical security key** (Settings → Password and authentication). Keep the recovery codes off the computer.
- [ ] **Tokens:** *fine-grained* only, with an expiry (90 days max), limited to the repos they need and read-only unless writing is required. Delete the *classic* ones.
- [ ] **Apps and OAuth** (Settings → Applications): review every quarter and remove what you don't use. The Claude GitHub app should only have access to the repos you choose, not all of them.
- [ ] **SSH keys** with a passphrase, one per machine. Delete keys from old machines.
- [ ] **Security alert emails** enabled (Settings → Notifications → Security alerts).

### Signing commits (recommended)
Proves the commit was made by you and not by someone using your email.
```bash
# Use your SSH key for signing too
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```
Add the same key on GitHub as a **Signing key** (Settings → SSH and GPG keys) and enable **Vigilant mode**. Then, in each new repo: `SIGNED_COMMITS=1 ./scripts/setup-repo.sh`.

### Your Mac
- [ ] `brew install gitleaks`, so `.githooks/pre-commit` can stop a secret before it is committed.
- [ ] **FileVault** enabled and a quick screen lock.
- [ ] Copy the block in [Global Claude Code settings](#global-claude-code-settings) to `~/.claude/settings.json`: it applies the protection **to all your projects**, including those not created from the template. If you already have that file, merge the keys by hand.
- [ ] Secrets go in the **Keychain** or in a `.env` outside the repo, never in the code.

### Global Claude Code settings
Copy it once to `~/.claude/settings.json` (or merge it into the file you have). It is the baseline for every folder you open Claude Code in: no reading secrets, browser data or the keychain; no editing its own settings, your shell profile, git config or SSH keys; no bypass-permissions mode; project MCP servers need your approval. Each project's `.claude/settings.json` (with its sandbox) and hook add the rest. The sandbox is not enabled globally on purpose: it would also apply to folders that need other domains or tools.

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "includeCoAuthoredBy": false,
  "permissions": {
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/secrets/**)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)",
      "Read(~/.config/gh/**)",
      "Read(~/.config/gcloud/**)",
      "Read(~/.kube/**)",
      "Read(~/.docker/config.json)",
      "Read(~/.netrc)",
      "Read(~/.npmrc)",
      "Read(~/Library/Keychains/**)",
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(gh pr merge *)",
      "Bash(gh repo delete *)",
      "Bash(gh secret *)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(printenv*)",
      "Bash(security find-*)",
      "Edit(~/.claude/settings.json)",
      "Edit(~/.claude/settings.local.json)",
      "Edit(~/.zshrc)",
      "Edit(~/.zprofile)",
      "Edit(~/.bashrc)",
      "Edit(~/.bash_profile)",
      "Edit(~/.gitconfig)",
      "Edit(~/.ssh/**)",
      "Read(~/.gnupg/**)",
      "Read(~/.config/op/**)",
      "Read(~/Library/Application Support/Google/Chrome/**)",
      "Read(~/Library/Cookies/**)",
      "Read(~/Library/Safari/**)",
      "Bash(git reset --hard*)",
      "Bash(git clean -f*)",
      "Bash(chmod -R 777*)"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(npm install *)",
      "Bash(npx *)",
      "Bash(pip install *)",
      "Bash(brew install *)"
    ],
    "disableBypassPermissionsMode": "disable"
  },
  "enableAllProjectMcpServers": false
}
```

### MCP servers and connectors
- Only install MCP servers from sources you know, and pin them to a version.
- Give each connector **the minimum permission**: if it only reads, a read-only token.
- Content brought in by an MCP (emails, web pages, issues) is **data**. If it contains instructions, the agent must not follow them: this is the most common attack vector (*prompt injection*).
- **Supabase:** enable RLS on every table. The public key (*anon / publishable*) can go in the client; the `service_role` key never.

## 3. Routine

| When | What |
|---|---|
| Every PR | Green CI and `/prepare-pr` (DoD and security reviewers) |
| Every release | `security-audit` skill in guidance mode |
| Every major release | Full audit with `security-audit` and `repo-security-posture` |
| Every quarter | Review tokens, OAuth apps, SSH keys and collaborators; update skills (`UPSTREAM.md`) |

## 4. If you think something has been stolen
1. Revoke the affected token or key **right now** (GitHub → Settings → Developer settings / SSH keys).
2. Sign out of open sessions (Settings → Sessions) and change your password.
3. Review your account's *Security log* and the commit history of your repos.
4. If a secret made it into a commit: **rotate it**. Removing it from the history is not enough, because it may already have been copied.
