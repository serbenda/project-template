# Security: what this template protects and what you have to do

Security works in layers. If one fails, the next one stops the blow.

```
Your GitHub account ─┬─ 2FA with security key/passkey, expiring tokens, reviewed apps
Your Mac ────────────┼─ FileVault, global ~/.claude/settings.json, keys in the keychain
The agent (Claude) ──┼─ .claude/settings.json (permissions) + .claude/hooks/guard.sh
Local git ───────────┼─ .githooks/commit-msg (strips AI signatures, checks author)
GitHub (server) ─────┴─ main ruleset, CI (Secrets, Authorship, Hook)
```

## 1. What the template already does

| Layer | Protection | Where |
|---|---|---|
| Agent | No AI signature in commits or PRs | `.claude/settings.json` → `attribution` |
| Agent | Does not read `.env`, SSH keys, AWS/gh credentials | `permissions.deny` + hook |
| Agent | Asks before `git push`, `curl`, installing packages | `permissions.ask` |
| Agent | Blocks push to main, force push, `gh pr merge`, `rm -rf`, `curl \| sh`, dumping tokens, writing secrets to files | `.claude/hooks/guard.sh` (tested by `scripts/test-guard.sh`) |
| Git | Strips AI `Co-Authored-By` and rejects commits with a different email | `.githooks/commit-msg` |
| GitHub | `main` protected: PR required, green CI, no force-push or deletion. **Not available on private repos with GitHub Free**: the script warns and exits with an error | `scripts/setup-repo.sh` |
| CI | Gitleaks (secrets), AI signatures and author, shellcheck and hook tests | `.github/workflows/ci.yml` |
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
- [ ] **FileVault** enabled and a quick screen lock.
- [ ] Copy `docs/claude-settings-global.json` to `~/.claude/settings.json`: it applies the protection **to all your projects**, including those not created from the template. If you already have that file, merge the keys by hand.
- [ ] Secrets go in the **Keychain** or in a `.env` outside the repo, never in the code.

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
