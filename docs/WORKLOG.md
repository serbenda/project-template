# Worklog

> The **context** of each change: what, why, what was rejected, commits, how it was tested and what is pending.
> Maintained by the agent with the `record-changes` skill. New entries **on top**.
> In full mode, user-visible changes go once per phase in [CHANGELOG.md](../CHANGELOG.md); the current status is in [STATE.md](STATE.md).

<!--
## YYYY-MM-DD — Short title of the change
- **Phase / issue:** P03 · #12 (or "—")
- **What:**
- **Why:**
- **Rejected:**
- **Files:**
- **Commits:**
- **Tested:**
- **Pending:**
-->

## 2026-11-16 — The owner's identity in one file: .github/OWNER
- **Phase / issue:** —
- **What:**
  - New `.github/OWNER` (name, email, login, noreply), a guardrail. The git hooks read it from the last commit, the guard from the project's last commit, CI's Authorship job from the PR's base branch (the PR's own file only while the base still names someone other than the repository's owner: the template's, before setup). Nothing reads the copy on disk, so a change counts only once the owner commits it.
  - `setup-repo.sh` writes it on a project's first run for the person running it (`OWNER_NAME`/`OWNER_EMAIL`, else the repo's git identity, else GitHub's noreply), names them in the project README's copyright line and in CODEOWNERS, and sets the git identity from it on every run. It also says what to do when it can't switch to development.
  - `sync-from-template.sh` gives a project from before the file the template's (the new hooks refuse every commit without one) and never replaces a project's own.
  - The name and email are no longer written in the hooks, CI, guard, setup-repo or docs; the tests use a fictitious owner where they can.
- **Why:** the owner's name and email were hard-coded in about 15 guardrail files: changing the email, or handing the template to someone else, meant editing all of them.
- **Rejected:** reading the identity from `git config` (anyone can set it, so it can't be the reference it is checked against); a multi-owner list (one owner is the template's model).
- **Files:** .github/OWNER, .githooks/commit-msg, .githooks/applypatch-msg, .githooks/pre-push, .github/workflows/ci.yml, .claude/hooks/guard.sh, scripts/setup-repo.sh, scripts/sync-from-template.sh, scripts/test-guard.sh, scripts/test-githooks.sh, scripts/test-scripts.sh, AGENTS.md, README.es.md, README.md, docs/templates/README.project.md, .claude/agents/dod-reviewer.md, CHANGELOG.md
- **Commits:** pending (the owner's)
- **Tested:** the four suites on /bin/bash 3.2 (guard 1316, git hooks 160, records 46, scripts 63). The Authorship step run locally with the PR's real base and head, after CI caught it exiting (128) when the base has no OWNER yet: `git show` failing inside `$(…)` ended the step under `bash -e`.
- **Pending:** —

## 2026-11-16 — Final review (Fable, second pass): fixes for its High, Mediums and Lows
- **Phase / issue:** —
- **What:**
  - **H1:** the tripwire no longer counts the `AGENTS.md`/`CLAUDE.md` files packages ship inside dependency folders (`node_modules/`, `.venv/`, `vendor/`…, a fixed list in the guard), which blocked the agent after every install.
  - **M1:** nested `CLAUDE.local.md` files count for the tripwire (only the owner's root one is left out); SECURITY_GUIDE no longer claims more than is enforced.
  - **M2:** dev container: `--cap-drop=ALL` (in runArgs and the CI check); SECURITY_GUIDE says root in the container could escape through unmasked `/proc`, which settings must stay (`USER vscode`, `no-new-privileges`, no capabilities), the Mac vs Linux kernel difference, and the alternatives weighed (`enableWeakerNestedSandbox`, a custom seccomp profile).
  - **L1:** `.scanners` and `.semgrep` in shell text without a trailing slash (`mv .scanners x`). **L2:** writes to patterns with no literal start or with brace lists (`>> *.md`, `[A]GENTS.md`, `{AGENTS,README}.md`, `*/semgrep/Dockerfile`) are matched against the guardrail files that exist. **L3:** `.claude/AGENTS.md` in `denyWrite`.
  - Dev container: `CLAUDE_CONFIG_DIR` points into the config volume, so Claude Code's `~/.claude.json` (login, preferences) survives a rebuild; found rebuilding it to test `--cap-drop=ALL`.
  - **L4:** `setup-repo` writes `.claude/TEMPLATE_VERSION` after the placeholders are replaced. **L5:** sync warns about old `.github/scanners` paths even once the folder is gone. **L6:** the macOS CI job runs the git hook tests; the bubblewrap check adds `--unshare-net`.
- **Why:** Fable's second final review: 8.5/10, no Critical, no regressions; these were its findings.
- **Rejected:** L7 (a read with a redirect that names AGENTS.md is blocked): the price of a strict guard. `--exclude-standard` for H1 (the agent could hide a file by adding it to `.gitignore`, which is not a guardrail).
- **Files:** .claude/hooks/guard.sh, .claude/settings.json, .devcontainer/devcontainer.json, .github/workflows/ci.yml, .github/workflows/devcontainer.yml, scripts/setup-repo.sh, scripts/sync-from-template.sh, scripts/test-guard.sh, scripts/test-scripts.sh, docs/SECURITY_GUIDE.md, README.md
- **Commits:** pending (the owner's)
- **Tested:** the four suites on /bin/bash 3.2 (guard 1313, git hooks 158, records 46, scripts 57). The container options only in CI (`--cap-drop=ALL` with the bubblewrap check).
- **Pending:** confirm in the rebuilt container that the login survives a second rebuild.

## 2026-11-16 — Release prep: CHANGELOG, legacy scanners folder in sync, README counts checked in CI
- **Phase / issue:** —
- **What:**
  - CHANGELOG brought up to date with the work recorded here since the guardrails review (`.scanners/`, dev container Node 22 and sandbox options, owner-only agent instructions, gh writes to origin only, the setup-repo rerun fix, the CI fixes).
  - `sync-from-template.sh` lists `.github/scanners` among the files to remove (the message now says "renamed or moved since") and warns while a project's `dependabot.yml` or `ci.yml` still read it. New test.
  - The Hook job keeps each suite's output and a final step checks the README's counts (badge and "What's verified") against the real ones; skipped in projects.
- **Why:** the CHANGELOG is what projects read when they sync; synced projects kept a stale `.github/scanners/` without being told; the README counts were updated by hand and could drift.
- **Rejected:** generating the README counts in CI (a workflow writing to the repo needs write permissions it doesn't have now).
- **Files:** CHANGELOG.md, scripts/sync-from-template.sh, scripts/test-scripts.sh, .github/workflows/ci.yml, README.md
- **Commits:** pending (the owner's)
- **Tested:** the four suites on /bin/bash 3.2 (guard 1302, git hooks 158, records 46, scripts 56); the count check run locally against their output, and it caught the README saying 156 git hook cases.
- **Pending:** —

## 2026-11-16 — The agent's instructions (AGENTS.md, CLAUDE.md) are owner-only
- **Phase / issue:** —
- **What:** `AGENTS.md`, `CLAUDE.md` and `CLAUDE.local.md`, in any folder, are guardrails in every layer: the hooks' path list (pre-commit, pre-push), the guard (files, shell paths; the tripwire for the first two), the settings `Edit()` denies (root and nested) and `denyWrite`, CODEOWNERS (now in any folder, not only the root), and the layer-consistency test. `/close-phase` proposes AGENTS.md changes as a diff for the owner. Docs: AGENTS, SECURITY_GUIDE.
- **Why:** they hold the rules the agent follows; a prompt injection could talk it into rewriting them (dropping "never push without asking"), and the change would arrive in an ordinary PR. `.claude/CLAUDE.md` was already owner-only; the root files were not.
- **Rejected:** `CLAUDE.local.md` in the tripwire (the owner's uncommitted file would block the agent for good); protecting only the root files (Claude Code loads nested CLAUDE.md files too).
- **Files:** .githooks/pre-commit, .githooks/pre-push, .claude/hooks/guard.sh, .claude/settings.json, .github/CODEOWNERS, .claude/commands/close-phase.md, scripts/test-guard.sh, scripts/test-githooks.sh, AGENTS.md, docs/SECURITY_GUIDE.md
- **Commits:** pending (the owner's)
- **Tested:** the four suites on /bin/bash 3.2 (guard 1302, git hooks 156, records 46, scripts 55 after merging development).
- **Pending:** —
## 2026-11-16 — setup-repo tested against GitHub; a second run no longer rewrites the project's docs
- **Phase / issue:** —
- **What:** `setup-repo.sh` replaces the `PROJECT_NAME` placeholder only on the first run (no `.claude/TEMPLATE_VERSION` yet). New test: a second run leaves the project's own mentions of `PROJECT_NAME` alone.
- **Why:** the first run against the real GitHub API (serbenda/template-smoke-test, private, GitHub Pro) re-ran step 2 on a project already set up, and rewrote the places its docs name the placeholder on purpose (README step 3, worklog). The same damage had once been repaired by hand there.
- **Tested against GitHub:** exit 0; squash merges off, merge commits only, development kept; "Protect main" updated in place (six required checks with `integration_id` 15368, strict; GitHub Actions' check runs on this repo report app 15368), "Protect development" (no deletion or force push) and "Protect tags" (creation, update, deletion; bypass for the repository admin role, actor 5) created. Not tested: that a non-admin is really refused a tag (needs a second account). Private vulnerability reporting and secret scanning warned as expected on a private repo.
- **Rejected:** excluding the docs from the replacement (the first run must replace their headings).
- **Files:** scripts/setup-repo.sh, scripts/test-scripts.sh, README.md
- **Commits:** pending (the owner's)
- **Tested:** test-scripts 55 on /bin/bash 3.2.
- **Pending:** template-smoke-test's main now requires SAST and Dependencies, which its older CI doesn't run: sync it from the template before its next PR.

## 2026-11-16 — Scanner images move to .scanners/ so Dependabot can update them
- **Phase / issue:** —
- **What:** `.github/scanners/{semgrep,osv-scanner}/Dockerfile` move to `.scanners/…`. The new folder is a guardrail in every layer: the hooks' path list, the guard (files, shell paths, tripwire), the settings deny and `denyWrite` lists, CODEOWNERS, and the layer-consistency test. ci.yml, dependabot.yml, sync-from-template, the tests and the docs follow the new path.
- **Why:** Dependabot's docker update for the scanners failed at `create_pull_request` with `400 "invalid or unauthorized changes"`. GitHub gives Dependabot the workflows permission only for the github-actions ecosystem, so another ecosystem can't open a PR that changes `.github/` (dependabot-core#15237, still open). The scanners were never updated automatically.
- **Rejected:** updating the images by hand (the cooldown and weekly check would be lost); `.devcontainer/` for them (it is the dev container's folder, built on every change).
- **Files:** .scanners/, .githooks/pre-commit, .githooks/pre-push, .claude/hooks/guard.sh, .claude/settings.json, .github/CODEOWNERS, .github/dependabot.yml, .github/workflows/ci.yml, scripts/sync-from-template.sh, scripts/test-guard.sh, scripts/test-githooks.sh, scripts/test-scripts.sh, AGENTS.md, README.es.md, docs/SECURITY_GUIDE.md
- **Commits:** pending (the owner's)
- **Tested:** the four suites on /bin/bash 3.2 (guard 1298, git hooks 150, records 46, scripts 54); Dependabot's PR only after the merge into development.
- **Pending:** projects already synced keep a stale `.github/scanners/`; sync copies the new files but doesn't delete the old ones.

## 2026-11-16 — CI fixes for PR #9: TMPDIR on Linux, Gitleaks before the tests, dev container sandbox
- **Phase / issue:** — · PR #9
- **What:**
  - `test-guard.sh` sets `TMPDIR` to `/tmp` when it is unset (Linux runners): the guard trusts `"$TMPDIR/…"` output paths only when it is set, so 8 cases failed there.
  - CI installs the pinned Gitleaks before the test steps on Linux, and on macOS too (darwin arm64 build, SHA-256 checked): setup-repo pushes through the new pre-push hook, which refuses every push without it (18 script cases failed on macOS). `test-scripts.sh` now says so up front, and shows the end of setup-repo's output when a run that should succeed fails.
  - Dev container: Node.js 22.23.4 from nodejs.org, checksum verified (Ubuntu's Node 18 is below Claude Code's minimum); seccomp and AppArmor unconfined so bubblewrap can create its namespaces, and `systempaths=unconfined` so it can mount `/proc` (the second CI run got past the namespaces and stopped there). The CI check showed the sandbox couldn't start, so every command would have been refused. The trade-off is documented in SECURITY_GUIDE.
- **Why:** the first CI run of PR #9 failed in Hook, Hook (macOS bash 3.2) and Devcontainer build.
- **Rejected:** turning Claude Code's sandbox off inside the container (it would lose the network allow-list and the OS-level write limits); a custom seccomp profile (a copy of Docker's to keep in step by hand).
- **Files:** scripts/test-guard.sh, scripts/test-scripts.sh, .github/workflows/ci.yml, .github/workflows/devcontainer.yml, .devcontainer/Dockerfile, .devcontainer/devcontainer.json, docs/SECURITY_GUIDE.md
- **Commits:** pending (the owner's)
- **Tested:** all four suites on /bin/bash 3.2, the guard also with TMPDIR unset; the container fixes only in CI.
- **Pending:** confirm in CI that bubblewrap starts in the runner's Docker with these options.

## 2026-11-15 — Final review (Fable): gh writes, settings deny list, layer consistency
- **Phase / issue:** —
- **What:**
  - **gh writes stay in the repository:**
    - The guard lets `gh` write only to the `origin` repository.
    - `gh api` with fields, `--input` or a method other than GET must name `repos/<origin>/…`, `repos/{owner}/{repo}/…` or `graphql` (queries only, as before). That covers `-XPOST` and attached-value bundles, and blocks gists, new repositories and other repositories.
    - `gh pr`/`gh issue` writes with `-R`/`--repo` (anywhere in the command) must name `origin`.
    - `GH_REPO` and `GH_HOST` can't be set.
  - **settings.json deny list:** the static `Edit()` denies now cover `.mcp.json`, the scanner configs, `.gitattributes`, the remaining `.claude/` folders and the editors' auto-run files, at the root and nested. It no longer relies on the guard alone.
  - **Layer consistency:** `test-githooks.sh` checks that pre-commit and pre-push share one path list, and that the hooks, the guard and CODEOWNERS name the same guardrails.
  - **Docs:** SECURITY_GUIDE now explains:
    - the guard (any folder) and the hooks (root for the directories) protect paths differently;
    - what `gh` writes to `origin` can still include project files.
- **Why:** Fable's final review, verdict 8/10, with no High. It found:
  - `gh api -X POST /gists` was allowed while `gh gist create` was blocked;
  - `gh issue create -R other/repo --body-file …` was an exfiltration channel;
  - the static deny list was narrower than the guard;
  - there was a risk that the layers' path lists drift apart.
- **Rejected:**
  - Anchoring the guard to the repository root (it gets absolute paths; stricter is safer).
  - Allowing `VAR=value git …` or `git -C` for writes (Fable listed them as friction; they guard real bypasses).
- **Files:**
  - `.claude/hooks/guard.sh`, `.claude/settings.json`
  - `scripts/test-guard.sh`, `scripts/test-githooks.sh`
  - `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:**
  - On `/bin/bash` 3.2: guard 1296 (also with python3 = 3.14), git hooks 148, records 46, scripts 54.
  - `git diff --check` clean.
  - Not run: bash 5, shellcheck, actionlint, CI, the real GitHub API, the dev container.
- **Pending:**
  - The owner reviews and commits everything with `GUARDRAILS_OWNER_CHANGE=1`, then pushes and opens the PR.
  - CI then runs shellcheck, actionlint, bash 5, the dev container build and the sandbox check.

## 2026-11-15 — Block C: setup-repo, sync, dev container and docs (Opus, Sonnet, Haiku, first round)
- **Phase / issue:** —
- **What:** Fixes from the first review round of block C.
  - **setup-repo.sh:**
    - Before changing anything, it checks the `owner/name` format, admin rights and that the default branch is `main`.
    - A run without `AGENT_BOT` is refused when main requires the owner's review now (`REMOVE_OWNER_REVIEW=1` to drop it on purpose).
    - The six required checks are tied to GitHub Actions (`integration_id` 15368), so a commit status can't stand in for them.
    - New rulesets: "Protect development" (no deletion or force-push) and "Protect tags" (only admins create, move or delete tags).
    - Rulesets are looked up without the org's parents and with pagination.
    - Anything asked for that fails (merge settings, secret scanning on public repos, signed commits, the agent's access, the new rulesets) is listed and exits 1.
    - It reads an org repo's plan, warns about missing python3 and jq, and passes file names NUL-separated.
    - The final message gives the owner's commit command.
  - **sync-from-template.sh:**
    - `--apply` copies only from the template's `main` (equal to `origin/main`) or a tag.
    - Template files must be regular files (no symlinks).
    - It writes through a temp file and `mv`, so hard links are replaced, not written through.
    - It refuses owned files the project ignores, uses `pwd -P` (a symlink to the template is the template) and runs the project's git with fsmonitor and hooks off.
    - The report never reads through a link.
    - `applypatch-msg` is now distributed, and `TEMPLATE_VERSION` records the ref.
  - **CI:** the setup/sync tests are skipped in projects made from the template (they test the template itself), and check-records compares the diagrams only when both files exist.
  - **Dev container:**
    - `gh` is installed and `SSH_AUTH_SOCK` emptied.
    - The name comes from the folder, so setup no longer edits `.devcontainer/`.
    - `postCreateCommand` quotes its path, and the Dockerfile comment says what isn't pinned.
    - The workflow's path is fixed, and it checks that bubblewrap really starts a sandbox and that jq and gh are there.
  - **Docs (English and Spanish):**
    - What the agent account can and can't do (it can merge a PR the owner approved).
    - Re-run setup with the same variables, and the owner's first commit.
    - SETUP Verify lists the CI suites, and the static-analysis item reflects that SAST already runs Semgrep.
    - The Spanish README's setup row is corrected.
- **Why:**
  - Opus and Haiku: re-running setup without `AGENT_BOT` silently dropped the owner's review (confirmed with the fake gh).
  - Haiku: the Hook check failed in every project, because test-scripts expects the template; the first commit after setup needs the owner's switch; deleting README.es.md broke Records.
  - Sonnet and Opus: forged commit statuses, hard links and symlinks in sync, syncing from an unreviewed template branch, and overstated docs.
- **Rejected:**
  - Taking the git identity from `gh api user` (this template is the owner's own: the hooks and CI expect that address).
  - `--cap-drop=ALL` and resource limits on the container (they could stop bubblewrap; the new CI check shows whether the sandbox starts).
  - Narrowing `.github/` for issue templates.
  - Reporting files the template deleted.
- **Files:**
  - `scripts/setup-repo.sh`, `scripts/sync-from-template.sh`, `scripts/check-records.sh`, the test scripts
  - `.github/workflows/ci.yml`, `.github/workflows/devcontainer.yml`, `.github/CODEOWNERS`
  - `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`
  - `README.md`, `README.es.md`, `docs/SECURITY_GUIDE.md`, `docs/SETUP.md`, `docs/WORKFLOWS.md`
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:**
  - On `/bin/bash` 3.2: scripts 54 (12 new), guard 1286 (also with python3 = 3.14), git hooks 125, records 46.
  - Diagrams match (13 each); `git diff --check` clean.
  - Not run: the real GitHub API (the rulesets, `integration_id`, the tag bypass), the dev container build and its sandbox check, CI.
- **Pending:** this round had a confirmed High (fixed), so the cutoff wasn't met. The owner chose to go straight to the final Fable review, which covers block C again.

## 2026-11-15 — Block B: git hooks, records check and CI (Opus, Sonnet, Haiku, fourth round)
- **Phase / issue:** —
- **What:** Fixes from the fourth review round of block B.
  - **Secrets:**
    - Commit messages are scanned (commit-msg, pre-push, CI), and so are branch names (pre-push, CI) and the PR's title and description (CI).
    - `GITLEAKS_*` variables are cleared in every hook and CI step; the guard refuses setting them.
    - `.gitleaks.toml` (`[[allowlists]]`) is the false-positive mechanism. `.gitleaksignore` fingerprints don't fit the text scan.
    - The test token in `test-githooks.sh` is now built at run time, so the file holds no token.
  - **Merges:** a protected file that differs from every parent counts as the merge's own change, whatever `git merge-tree` says. A local merge driver can no longer make the comparison agree.
  - **pre-push:**
    - The shallow-edge shortcut is gone: the fetched tips already reach a shallow clone's commits.
    - `main` can be created only while the remote has no branch.
    - `hotfix/` branches can be deleted.
  - **Suppressions:** NUL bytes become spaces before awk, so macOS awk can't cut a line and hide a suppression.
  - **Guardrail paths:** `.vscode/settings.json`, `tasks.json`, `launch.json`, `*.code-workspace`, `.envrc`, `.husky/` and `.pre-commit-config.yaml` are protected in any folder, in the hooks, the guard and CODEOWNERS. `.vscode/extensions.json` is no longer protected.
  - **Signature pattern:**
    - Added `Signed-off-by:` and `Authored-by:` naming an AI tool, and Claude Code session links.
    - "Built/Coded with" was dropped, and tool-like names (`openai-codegen`, `Copilot-style`) pass.
    - Only the exact Claude Code link alone on a line counts.
  - **commit-msg:**
    - It skips only from the first `diff --git` after the scissors and follows `core.commentChar`.
    - It accepts "Initial commit" and git's "Squashed commit of the following:".
  - **check-records:**
    - Code fences close as in CommonMark; an unclosed fence runs to the end of the file.
    - Tested needs two words or numbers.
    - The STATE byte limit is now 40000.
    - `CLAUDE.md` and `AGENTS.md` in any folder count as code.
- **Why:**
  - Sonnet and Opus: secrets in messages and branch names reached the remote (confirmed).
  - Sonnet: `GITLEAKS_CONFIG` switched the scan off.
  - Opus: the repo's own test token blocked the owner's commit, and `.gitleaksignore` couldn't clear it.
  - Both: merge drivers and the shallow edge.
  - Haiku: false positives in prose, `.vscode/extensions.json`, short Tested lines, "Initial commit" and the STATE size.
- **Rejected:**
  - Narrowing `.github/` (it stays wholly owner-only).
  - Allowing `deps:`/`security:` types.
  - Treating YAML/JSON under docs/ as documentation.
  - Widening the verb list further ("Powered by", "Developed with": too much ordinary prose).
- **Files:**
  - `.githooks/pre-commit`, `commit-msg`, `pre-push`
  - `scripts/check-records.sh`, `.github/workflows/ci.yml`, `.github/CODEOWNERS`
  - `.claude/hooks/guard.sh`, `.claude/settings.json`
  - the test scripts, `docs/SECURITY_GUIDE.md`, `AGENTS.md`, `README.md`
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:**
  - On `/bin/bash` 3.2: guard 1286 (also with python3 = 3.14), git hooks 125, records 46, scripts 42.
  - The changed files and the working diff give no gitleaks finding.
  - `git diff --check` clean.
  - Not run locally: bash 5, actionlint, shellcheck and the CI jobs.
- **Pending:** this round still found new Highs (all fixed), so the cutoff wasn't met. After four rounds the owner chose to move on to block C; the final Fable review covers block B again.

## 2026-11-15 — Block B: git hooks, records check and CI (Opus, Sonnet, Haiku, third round)
- **Phase / issue:** —
- **What:** Fixes from the third review round of block B.
  - **Secrets:** every scan (pre-commit, pre-push, CI) ignores `gitleaks:allow` and also scans the text of the changes on stdin. That covers binary files (a NUL byte), `-diff` attributes and the paths gitleaks skips by default. CI runs a pinned gitleaks instead of gitleaks-action.
  - **pre-push:**
    - It scans the commits it sends for secrets and for new `nosemgrep`/`osv-scanner:ignore` suppressions.
    - Only the remote's branches and tags count as known; `refs/pull/*` no longer does. Missing tips are fetched first, a shallow clone's edge counts as known, and the exclusions go through `rev-list --stdin`.
    - A merge's own changes are what differs from `git merge-tree` of its parents.
    - It allows deleting `dependabot/` and `release/` branches, and the owner can create `main` once in an empty repository.
    - It greps without `-q`, so pipefail can't hide a match.
  - **pre-commit:**
    - A merge finished with `git commit` is compared with `git merge-tree`.
    - pre-merge-commit only scans for secrets, because an automatic merge is git's own merge.
    - `nosem` is matched only as a whole word, and prose files may mention it.
    - `.vscode/`, `.envrc`, `.husky/` and `.pre-commit-config.yaml` are guardrails here and in pre-push. The guard and the sandbox's denyWrite also cover them.
  - **Signature pattern** (commit-msg, pre-push, CI): it matches the `Assisted-by`, `Co-developed-by` and `Generated-by` trailers, any line that starts by saying an AI tool made the change (no end-of-line anchor), Copilot/Windsurf/GPT, and a line that is only the Claude Code link. A link inside prose passes. Below `commit -v`'s scissors only git's diff is skipped.
  - **check-records:**
    - Submodule bumps count even with `ignore = all`.
    - `docs/requirements.txt`/`CMakeLists.txt` count as code; diagrams under docs/ and images under .github/ count as documentation.
    - Entries inside code fences don't count; a new entry counts anywhere in the file, with no date-order rule.
  - **CI Records:** on a push to development, the Dependabot exemption needs GitHub to say the tip is its merge of a PR Dependabot opened.
- **Why:** the third review round found new bypasses with repros:
  - Opus: `gitleaks:allow` in Markdown.
  - Sonnet: the NUL byte; a plumbing merge hiding a hook downgrade or a stranger's change through `refs/pull`; cherry-picked secrets passing pre-push; the Dependabot exemption on push not tied to a PR.
  - Haiku: false positives.
- **Rejected:**
  - Protecting `package.json` and `Makefile` (normal project files: review their scripts).
  - Making `.claude/launch.json` owner-only (the preview tool needs it; documented).
  - An Authorship job for direct pushes to development (pre-push plus Secrets/Records; documented).
  - Exempting release PRs that only carry Dependabot updates.
- **Files:**
  - `.githooks/pre-commit`, `pre-merge-commit`, `pre-push`, `commit-msg`
  - `scripts/check-records.sh`, `.github/workflows/ci.yml`
  - `.claude/hooks/guard.sh`, `.claude/settings.json`
  - the test scripts, `docs/SECURITY_GUIDE.md`, `AGENTS.md`, `README.md`
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:**
  - On this machine's `/bin/bash` 3.2: guard 1281 cases (also with python3 = 3.14), git hooks 105, records 43, scripts 42.
  - `git diff --check` clean.
  - Not run locally: bash 5, actionlint, shellcheck and the CI jobs themselves.
- **Pending:** a fourth review round of block B (this one found new Highs), then block C and the final Fable review.

## 2026-11-15 — Block B: git hooks, records check and CI (Opus, Sonnet, Haiku, second round)
- **Phase / issue:** —
- **What:**
  - pre-push: the commits checked are those the remote doesn't have, asked with `git ls-remote` (a forged remote-tracking ref can't hide one; a back-merge of `origin/main` with GitHub's merges works; pushes by URL work); `GIT_NO_REPLACE_OBJECTS`; a failing `rev-list` refuses; committer must be the owner too; guardrail paths are checked in every commit sent (plumbing, cherry-pick, rebase), owner's switch to push them; `Main` in any case refused.
  - commit-msg checks the raw message (comment lines too, only the `commit -v` diff is cut); the signature pattern (shared with pre-push and CI) allows `#`, `>`, `-`, `*` before it and treats a "Generated with X" line as a footer only when the tool name ends it, so prose such as "Created by Copilot review…" passes; types in any case. applypatch-msg refuses when the patch's author can't be read.
  - pre-commit: `.gitattributes` and the scanners' settings are protected in any folder; suppressions are found in every added line (also lines starting with `+`, at column 1, `nosem`), as text, outside Markdown.
  - check-records: CRLF counts once; `–`/`-` in headings; images under `docs/` and `README-dev.md` are documentation, READMEs under hidden folders (`.claude/`) are not; the "no more entries than before" count is replaced by "not an old entry's text" (archiving works); GitHub's merge of a Dependabot PR keeps the exemption.
  - CI: Authorship reads one field per call (no `|` trick) and accepts GitHub-made, verified commits by the owner's noreply address or Dependabot (release PRs, web merges); Records' Dependabot exemption needs Dependabot as last pusher (`sender`) on PRs and also covers the push of its merge to development; pushes to development no longer cancel each other; commit listing fails closed.
  - `.gitattributes` protected in the guard, `denyWrite` and CODEOWNERS (scanner settings in any folder too); the test harnesses run the scripts with their own `$BASH`, so the macOS job really uses 3.2.
- **Why:** second round on block B. Sonnet: six Highs (hidden `#` signatures, forged remote refs, `git replace`, `.gitattributes -diff`, narrow suppression regex, guardrails only in pre-commit). Opus: broken back-merge, release-PR and Dependabot flows, cancelled Records runs, CRLF. Haiku: fourteen false positives (noreply merges, prose, docs images, archiving…).
- **Rejected:** accepting the owner's noreply address in pre-push (commits already on the remote aren't checked, which covers it); protecting all of `.claude/` in the guard (agents write their memory there; commits are refused anyway); treating author emails as authentication (documented).
- **Files:** `.githooks/*`, `scripts/check-records.sh`, `scripts/test-githooks.sh`, `scripts/test-check-records.sh`, `scripts/test-scripts.sh`, `scripts/test-guard.sh`, `.github/workflows/ci.yml`, `.github/CODEOWNERS`, `.claude/hooks/guard.sh`, `.claude/settings.json`, `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** git hooks 74/74, records 39/39, scripts 42/42 and the guard 1274/1274 with `/bin/bash` 3.2 (guard also with python3 = 3.14); `git diff --check` clean. This machine has no bash 5: it runs in CI (Linux). Not run here: actionlint, shellcheck, the CI jobs and the GitHub-side checks (`gh api` verification, `sender`).
- **Pending:** third round on block B; then block C; Fable last; `.claude/settings.local.json` (owner).

## 2026-11-15 — Block B: git hooks, records check and CI (Opus, Sonnet, Haiku, first round)
- **Phase / issue:** —
- **What:**
  - pre-commit: guardrails are everything under `.claude/` but `launch.json`, plus `.mcp.json` and the scanners' settings (`.gitleaks.toml`, `.gitleaksignore`, `.semgrepignore`, `.semgrep/`, `osv-scanner.toml`), matched without case and with submodules shown; inline suppressions (`gitleaks:allow`, `nosemgrep`) are the owner's; the gitleaks message no longer tells the agent to edit `.gitleaksignore`.
  - commit-msg refuses (instead of silently stripping) AI signatures with one pattern shared with CI and pre-push (trailers and footers at the start of a line, any `Co-authored-by:`, `Made with…`, bold/extra spaces, C locale); Conventional Commits subjects enforced (merges, reverts, fixup! allowed); author email compared without case. New `applypatch-msg` gives `git am` the same checks and reads the patch's author.
  - pre-push: only branches and (with the owner's switch) tags; deletions only of work branches; every commit sent must be the owner's (or Dependabot's) and signature-free, which covers cherry-pick/revert/rebase commits.
  - check-records: Why/Tested need three distinct real words (wrapped lines and `**Why**:` accepted); valid, not future dates; only Markdown under `docs/` and READMEs anywhere (any locale) are documentation; non-ASCII paths read correctly; STATE.md must not be a link, is limited in bytes and counts `\r` lines; a missing diagram twin fails.
  - CI: a Dependabot commit is accepted only in a PR Dependabot opened and with a signature GitHub verified (Authorship and Records); Records also runs on pushes to development; `timeout-minutes` everywhere; a macOS job runs the suites with `/bin/bash` 3.2; the devcontainer workflow also triggers on `.devcontainer.json` and itself.
  - Consistency: the guard, the sandbox `denyWrite` and CODEOWNERS protect the same new paths.
- **Why:** Opus, Sonnet and Haiku on block B. Two Highs: the scan could be switched off in the same commit (`.gitleaksignore`), and the hooks don't run where `.githooks/` is absent (documented; the guard covers the agent).
- **Rejected:** letting a merge bring the owner's already-committed guardrail change without the switch (the guard keeps that merge the owner's anyway); making AGENTS.md/CLAUDE.md owner-only (not in the policy; they are in CODEOWNERS).
- **Files:** `.githooks/*` (new `applypatch-msg`), `scripts/check-records.sh`, `scripts/test-githooks.sh`, `scripts/test-check-records.sh`, `scripts/test-scripts.sh`, `.github/workflows/*.yml`, `.github/CODEOWNERS`, `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** git hooks 47/47, records 32/32, scripts 42/42 and the guard 1271/1271 on bash 5 and `/bin/bash` 3.2 (guard also with python3 = 3.14); `git diff --check` clean. Not run here: actionlint, shellcheck (not installed) and the new CI jobs; first checked by CI on the PR.
- **Pending:** second round on block B; then block C; Fable last; `.claude/settings.local.json` (owner).

## 2026-11-15 — Guard, round 8p: extra verification round on block A (owner's request), block A closed
- **Phase / issue:** —
- **What:**
  - Tokenizer (Opus, compared with bash 5 traces): `[[` opens after `time -p`, right before `(`, across newlines, and never in a case-pattern position; `(`/`)` inside `[[ ]]` are words of their own; a case depth is tracked, so `;;` outside a `case` (`${x/;;/}`) and multi-word "patterns" fail closed instead of dropping words; `a|b)` is one pattern; `case` after `if`/`{`/`!`; a `case` inside `$( )` fails closed; `\bash -c` and `"bash" -c` are re-scanned as shells.
  - Sonnet (3 High): inside "…" a backslash before an ordinary character is kept, as bash does (`bash -c "g\it push …"` is git); path-qualified `/bin/rm`, `/bin/chmod`, `/usr/bin/chown`; absolute home paths (`/Users/<name>/.net*`) are matched as `~`. Medium/low: `..` itself and `find ~|/|.. -exec chmod|rm …` / `-delete`; `.GIT/` (case-insensitive disk) and `${HOME}` in gh files; more credential files (terraform, rclone, composer, yarnrc, oci, vercel, npm, m2); `timeout 5 ls python3` is no longer a false positive.
  - Haiku: false positives fixed (`sed s/…/…/` without e/w flags, `tee`, `yq`, `curl -d` text, `dist/*` and `services/*` globs now follow bash's rules (no `/`, no leading dot), `wc -l sales_history.csv`, `git-lfs version`, `git lfs pull/track/…`, `git sparse-checkout list`).
- **Why:** the owner asked for one more round after the third; it found two state-machine slips from round 2/3, both fixed.
- **Rejected:** a full bash parser; where the tokenizer can't be sure (unbalanced case state), it now refuses the command.
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh`, `/bin/bash scripts/test-guard.sh` and with python3 = 3.14: 1260 cases pass (76 new); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** block A closed; what is left goes to the final Fable review. Next: block B (.githooks, check-records, .github, their tests), then C. `.claude/settings.local.json` (owner).

## 2026-11-15 — Guard, round 8o: Opus, Sonnet and Haiku on block A (third round, last by the cutoff)
- **Phase / issue:** —
- **What:**
  - High (2): the `case` pattern state is now set only by `case … in` and `;;` and cleared at every other command end (after `esac`, a later `)` dropped a real command: `case x in a) true;; esac; (git push origin main)`); a backslash quotes the character, so `\[[` is not the `[[` keyword and no longer switches separators off.
  - Medium: a command string containing git or gh handed to anything but a shell, an interpreter or a text tool is refused (`tmux new -d '…'`, `ssh host '…'`, `watch`, `flock -c`, `su -c`, `parallel`, `sed e`, `rsync -e`, `zip -TT`); brace sequences and absolute globs are matched against credential paths (`.en{v..v}`, `/Users/*/.s?h/id_r*`); more credential files (`.pypirc`, `.pgpass`, `.cargo/credentials`, `.vault-token`, `.azure/`, `*_history`…); gh file checks read option bundles (`-iF`), leave `=@` references unnormalised and refuse `.git/` files; the interpreter behind any wrapper is found anywhere in the command (`uv run --with X python3`, `flock -w 5 F python3`, `bwrap --ro-bind / / python3`); `git-push` and `git-core/` paths refused; `git diff --no-i` (abbreviated) refused; recursive `chmod`/`chown` outside the project refused.
  - False positives fixed: `~/.gitconfig` reads, `[[ -f .env ]]` file tests, `--build-arg GIT_COMMIT=…`, `for tool in git gh jq`, `test "$(git rev-parse …)"`.
  - Opus's run stopped early (a classifier); its six code-reading leads were probed here: the `case` one was real (above), the rest held; `Read(./.env.test)` added to the permission deny list.
- **Why:** third round of the reviewers on block A.
- **Rejected:** blocking `curl -F @file` in the guard (the sandbox network allow-list limits curl's destinations).
- **Files:** `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh`, `/bin/bash scripts/test-guard.sh` and with python3 = 3.14: 1184 cases pass (63 new); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** block A closed by the cutoff (what is left goes to the final Fable review); `.claude/settings.local.json` (owner); blocks B and C.

## 2026-11-15 — Guard, round 8n: Opus, Sonnet and Haiku on block A (second round)
- **Phase / issue:** —
- **What:**
  - Sonnet (3 High): `[[ … ]]` state now ends at `]]` whatever follows it and at the end of every command (`if [[ -f x ]]; then git push origin main; fi` was unchecked); git or gh as an argument is refused for every command except those that only name things (`echo`, `grep`, `ls`, package managers…) and a script's own arguments, so unknown runners (`xcrun`, `fakeroot`, `uv run`, `firejail`, `bwrap`, `torsocks`) no longer hide them; credential paths extended (`.aws/`, `.npmrc`, `.kube/`, `.docker/config`, `.gnupg`, `.config/gcloud`, `.gitconfig`), `git diff/grep --no-index` refused, and gh body/field/input files must be in the project or the temp folder.
  - Sonnet (Medium): more wrappers for environment dumps (`setsid`, `watch`, `flock`, `script`…), interpreters that spawn `env`/`printenv`, `Bun.env`, `Deno.env`, `phpinfo`; git's `--no-pager`/`-P`/`--no-optional-locks` no longer hide destructive subcommands; whole-tree discards read from the parsed paths (`checkout .`, `checkout HEAD -- .`, `restore -s HEAD .`, `checkout -f`); `./../x` is `../x`; URL-looking words with `/..` refused; option bundles `-qenv`, `-iH`; more write verbs (`unlink`, `find -delete`, `curl -o`, `wget -O`, `sort -o`…) and publish commands with options in between.
  - Opus: unquoted patterns are expanded (braces) and matched against a list of credential paths (`.env.*`, `{.,}env`, `~/.ss*/config`, `~/.aw*/credentials`…); `.env.local/.production/.development/.test` added to the sandbox denyRead.
  - Haiku: false positives fixed (`pip install -e .[dev]`, `npx vitest run src/git`, `[ -f x ]`, read-only git inside `$(…)`, `case … esac` arms, `git submodule status`); `sudo`/`doas` refused.
- **Why:** second round of the three reviewers on block A.
- **Rejected:** blocking `curl -F @file` uploads in the guard (the sandbox's network allow-list already limits where curl can send).
- **Files:** `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh`, `/bin/bash scripts/test-guard.sh` and with python3 = 3.14: 1121 cases pass (99 new); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** third (last) round of the reviewers on block A; `.claude/settings.local.json` (owner); blocks B and C; Fable last.

## 2026-11-15 — Guard, round 8m: Opus, Sonnet and Haiku on block A (first round), and a test-file incident
- **Phase / issue:** —
- **What:** the reviewers changed: Opus (consistency audit), Sonnet (concrete gaps) and Haiku (false positives) instead of Codex, with a cutoff (a block is done when a round leaves no confirmed High of a new class; at most 3 rounds; Fable reviews last). Fixes:
  - Sonnet: `gh pr review` flags read one by one (`-ab -c` was an approval); paths normalised in the scanner (`.claude/./x`, `scripts//x`, `x/..`); `git -C` only for read-only subcommands; `jq`/`gh --jq` with `env`/`$ENV`; more `gh api` write endpoints (statuses, check-runs, deployments, merge-upstream, `*keys`) and the method-override header; `.env` through brace expansion; `./.env` in the sandbox denyRead; `git apply` checks renamed paths (`--numstat -z`).
  - Haiku: about twenty false positives fixed (git/gh as an argument only matters for commands that run their operand; destructive and download rules read the commands, not commit messages; `.env` globs only when the shell expands them; `.env.sample/.template/.dist` are templates; write words matched as words; `Env:` only in PowerShell; `printenv NAME`; `MAX_TOKENS`; `ENV=`; `importlib.metadata`; `Object.keys(…)`; `curl … | python3 -m json.tool`; long heredocs). Newly refused: recursive `rm` outside the project, `git checkout -- .`/`git restore .`, `git branch -D`, `npm/pnpm/yarn publish` and similar, `dd of=/dev/…`, `shutdown`.
  - Opus: brace expansion with quoted alternatives (`{"--no-verify",-q}`) counts as a pattern for git/gh; `git remote -v set-url`; long-option abbreviations for merge and commit; `coproc`; `git worktree move`; `git reset --h`; tripwire requires `core.hooksPath=.githooks` when the project has `.githooks/`, and refuses more keys that run programs (`diff.external`, `interactive.diffFilter`, browsers, `man.*.cmd`, `core.worktree`, `submodule.*.update`, `extensions.worktreeConfig`…); the `scripts` folder itself is protected; `[[ … ]]` is read as one test.
- **Incident:** cases were appended to `scripts/test-guard.sh` while a background run of that same script was executing. Bash reads scripts as it goes, so it resumed at a shifted offset and ran two probe lines for real: `git log` output overwrote `scripts/test-guard.sh` and `.claude/settings.local.json`. Nothing else changed (checked: settings.json, guard.sh, stash, branches, GitHub). The test file was rebuilt by replaying every recorded change onto the stash copy; its counts match every recorded checkpoint. Rule from now on: never edit a script while something runs it.
- **Rejected:** an allow-list of every gh api write endpoint (comments and issues must stay possible).
- **Files:** `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh`, `/bin/bash scripts/test-guard.sh` and with python3 = 3.14: 1022 cases pass; the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** second round of the three reviewers on block A; `.claude/settings.local.json` to restore (owner); blocks B and C; Fable last.

## 2026-11-15 — Guard, round 8l: Codex block A, twelfth pass (NOT APPROVED, 7 points; 5 fixes confirmed, 3 partly)
- **Phase / issue:** —
- **What:** bare GNU `xargs --replace` means `{}` and takes no value (`xargs --replace sh -c '{}'` refused); `eval` behind a wrapper (`builtin eval`, `command eval`) is re-scanned like `eval`; the `time` keyword's own `-p`/`--` are skipped, so `time -p env` is a dump; `source`/`.` are also checked on parsed tokens (no operand, `-`, `/dev/stdin`, `/dev/fd`, `<(…)`, `$`/backtick) and the raw-text rule ignores line continuations; more run-time name building in one-liners refused (`attrgetter`, `methodcaller`, `setattr`/`delattr`, `sys.modules`, `__builtins__`, `__class__`/`__subclasses__`/`__mro__`/`__globals__`, `posix.`/`nt.`, `Object.entries/keys/values/getOwnProperty…(`, `public_send`, `[::-1]`); `.env.example` is exempt only when the name ends at a space, quote, `;|&)<>` or the end (`.env.example:production` is protected); `ps` long options with a separate value (`--format etime`, `--pid 1`, `-C node`) no longer trip the BSD-bundle check.
- **Why:** Codex's twelfth read of block A.
- **Rejected:** treating the reflection list as complete: SECURITY_GUIDE now says plainly that one-liners are programs and the sandbox is their barrier.
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** superseded by round 8m (the suite was re-run there).
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-15 — Guard, round 8k: Codex block A, eleventh pass (NOT APPROVED, 8 points; 6 fixes confirmed, 2 partly)
- **Phase / issue:** —
- **What:** `xargs -I R` refused when R reaches what a shell or interpreter evaluates (`xargs -I R sh -c R`), not only the program word; `source`/`.` of `<(…)`, `/dev/stdin`, `/dev/fd`, `-` or a variable refused; `time -a` is a flag, not an option with a value; `ps` reads environments only with a dashed `E` or a BSD-style bundle containing `e` (`ps eww`), so `ps -e`/`ps -ef` (all processes) are allowed again; interpreter one-liners can't build names at run time (`vars()`, `getattr`, `globals()`, `__import__`, `eval`/`exec`/`compile`, `__dict__`, `Reflect.`, `process[…]`, `const_get`, `.send(`, `$GLOBALS`, Perl symbolic references); `.env.example` is exempt only as the whole name (`.env.example.production` is a credential file); PowerShell `[Type]::Member` is no longer taken for a shell glob; `.devcontainer`, `.github` and `.githooks` need a path boundary (`docs/.devcontainer-notes` is not protected).
- **Why:** Codex's eleventh read of block A.
- **Rejected:** refusing all interpreter one-liners (they are the documented way to run small code).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh`, `/bin/bash scripts/test-guard.sh` and with python3 = 3.14: 865 cases pass (44 new); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-15 — Guard, round 8j: Codex block A, tenth pass (NOT APPROVED, 8 points; 10 fixes confirmed)
- **Phase / issue:** —
- **What:** `gh api …/pulls/N/reviews` only with `-f event=COMMENT` (no APPROVE/REQUEST_CHANGES, no `--input`/`@file`; review `events`/`dismissals` likewise), matching the `gh pr review --comment` rule; `xargs -I R R …` (the replacement as the program) refused; `git cherry-pick/revert --stdin` refused (revisions must be named so they are checked); `git switch --orphan` refused (it removes every tracked file, guardrails included); wrapper option values extended (`arch -d/-e`, `env -a`, `sudo -R/-c…`, `time -a`); the command after `find -exec/-execdir/-ok/-okdir` is checked as a command of its own (`find … -exec env ';'` is a dump); inline PowerShell is also handed to the bash side as PowerShell, and code or paths built at run time (string concatenation, `iex`, `& (…)`, `[type]`, `-join`, `-f`, a cmdlet path from `(…)` or `$var`) are refused; `set` with options (`set -e`, `set -euo pipefail`) is no longer taken for an environment dump (bare `set` still is).
- **Why:** Codex's tenth read of block A.
- **Rejected:** an allow-list of every gh api write endpoint (it would break comments and issue updates the agent is meant to do); a PowerShell parser (refusing run-time construction is simpler and the agent rarely needs it).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh`, `/bin/bash scripts/test-guard.sh` and with python3 = 3.14: 821 cases pass (38 new); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-15 — Guard, round 8i: Codex block A, ninth pass (NOT APPROVED, 10 points; 6 fixes confirmed)
- **Phase / issue:** —
- **What:** what a wrapper runs is also checked as a command of its own (`command env`, `exec env`, `nice env`, `stdbuf -o L printenv` are environment dumps); wrapper options that take a value are known per wrapper (`stdbuf -o L`, `ionice -c 2`, `xargs -I {}`, `sudo -u`…), so the interpreter behind them is found; interpreter options that take a value are known per language (`python3 --check-hash-based-pycs always`), and an interpreter's first operand only counts as a script when it names a file (path, extension or existing file; deno/bun take subcommands), otherwise it reads stdin and is refused; PowerShell parameters are matched by any accepted prefix (`-CommandW`, `-comman`, `-Encodeda`, `-ea`, `-fil`); `Env:` provider reads (`Get-Content Env:GH_TOKEN`, `gc env:`) and `[Environment]::GetEnvironmentVariables()` count as environment reads; `gh api` attached/combined short options are read (`-Fquery=@file`, `-iFquery=@file`, `-XDELETE`, `-iXDELETE`); git long-option abbreviations are spelled out for checkout/switch/restore/reset/branch (`--sou=` is `--source`, `--forc` is `--force`) and ambiguous ones are refused; `git fetch --all` refused (fetches only from `origin`); `.git` itself is a protected path (`rm -r .git`); a regex with a global `(?i)` flag after an alternation, rejected by Python 3.11+, now uses a scoped `(?i:…)`.
- **Why:** Codex's ninth read of block A. The `(?i)` one mattered most: on Python 3.11+ every `bash -c`/`pwsh` re-scan failed closed.
- **Rejected:** a full model of every interpreter's options (the "operand must name a file" rule covers the unknown ones).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 783 cases pass (55 new), also with python3 = 3.14; the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-15 — Guard, round 8h: Codex block A, eighth pass (NOT APPROVED, 6 points; 10 fixes confirmed, 3 partly)
- **Phase / issue:** —
- **What:** `env -S`/`--split-string` refused (it re-splits a word into a command after the guard has read it); `env VAR=…` with no program counts as an environment dump; interpreters are found after wrappers (`env python3`, `nice -n 5 python3`, also for heredocs), and interpreter options (`-B`, `-W ignore`, node `-r mod`) no longer count as a script, so code piped into them is refused, while `node --test`, `-V`, `--version`, `--help` stay allowed; PowerShell is parsed on its own terms: any prefix of `-Command`/`-CommandWithArgs` is re-scanned, `-EncodedCommand` (any prefix) and `-File -` are refused, `powershell`'s first operand is treated as a command, and `gci env:` / `$env:NAME_TOKEN` count as environment reads; `gh api graphql` needs its query inline (no `--input`, `-F …=@file` or substitutions outside single quotes; GraphQL `$vars` inside '…' are fine); file commands (`ls`, `cp`, `cat`, `tar`…) no longer have `bash`/`gh` operands taken for programs.
- **Why:** Codex's eighth read of block A.
- **Rejected:** parsing `env -S` strings (refusing it is simpler and it's rarely needed).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 728 cases pass (44 new); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-15 — Guard, round 8g: Codex block A, seventh pass (NOT APPROVED, 10 points; 10 fixes confirmed)
- **Phase / issue:** —
- **What:** `git fetch` only as `git fetch [options] [origin [branch…]]` (no refspecs, other sources or `--update-head-ok`, which could move the checked-out branch and so the hook that runs from HEAD); `git config` reads take exactly one key (no value pattern); a shell or `gh` given as an argument to any command that runs its arguments (`arch -arm64 …`, `caffeinate …`) is checked, not only after known wrappers; `bash <(…)` and `/dev/fd/N` scripts count as inline input; `function f { …; }` bodies are checked; interpreter code from a heredoc or here-string is checked like `-c`, and an interpreter reading code from a pipe is refused; `gh api graphql` is queries only; credentials are detected after any URL scheme; the tripwire requires `branch.<name>.merge` to be `refs/heads/<name>`, and setting an upstream counts as a move (so a plain push must be its own command); owner-only gh rules read the parsed commands, so a PR body that mentions `gh pr merge` is no longer refused.
- **Why:** Codex's seventh read of block A.
- **Rejected:** a full allow-list of top-level commands (too many false positives for a template); instead commands that only name things (`brew install fish`, `which bash`, git and gh themselves) are exempt from the shell/gh-as-argument check.
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 684 cases pass (46 new inputs and false-positive checks, 3 history-repo cases); the other three suites pass on both shells; `git diff --check` clean.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-15 — Guard, round 8f: Codex block A, sixth pass (NOT APPROVED, 10 points; 9 fixes confirmed)
- **Phase / issue:** —
- **What:** URL removal stops at shell metacharacters, so `git ls-remote URL>.github/x` keeps its target; clone/init/worktree after a `cd` in the same command are refused; gh behind a wrapper (`env gh`, `command gh`, `timeout 5 gh`, `find -exec gh`) is refused; a shell that reads its commands from stdin is refused wherever it appears (`… | env bash`, `| busybox sh`, `bash -s`, `sh -`, `pwsh -Command -`, `env bash <<<…`); interpreter one-liners may read only one named environment variable (`ENV.entries`, `getenv( )`, `os.environ.__repr__()`, `$_ENV` are refused); `git config` reads one key at a time and not keys or values that hold credentials, `git var -l` is refused, and `git remote -v`/`get-url`/`show`/`ls-remote --get-url` are refused when a remote URL has a token in it; the `.git/config` tripwire adds `credential.*`, `url.*`, `pager.*` and branches whose remote isn't `origin`, and ignored untracked guardrail files now trip it; `rg --pre`, `ack/ag --pager`, `man -P/-H` are refused, a text command with `VAR=` in front is checked like any other, and pager/editor/browser variables can't be set (except `PAGER=cat`/`GH_PAGER=cat`) because gh would run them unsandboxed; message masking applies only to `git commit/tag/merge/stash -m` and `gh -b/-t`, so `git branch -m "main"` and `git checkout -B "main"` are seen.
- **Why:** Codex read each of these as a way past the text rules for git and gh, which run outside the sandbox, or as a way to print credentials.
- **Rejected:** checking `settings.local.json` by content (a git-ignored copy now trips the tripwire like any other guardrail: the owner commits it or removes it).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 635 cases pass (74 new inputs and false-positive checks, 13 history-repo cases: tripwire keys, ignored settings.local.json, credential URLs); the other three suites pass; `git diff --check` clean.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-14 — Guard, round 8e: Codex block A, fifth pass (NOT APPROVED, 9 points)
- **Phase / issue:** —
- **What:** gh is held to an allow-list of subcommands (it runs outside the sandbox): reading and commenting on PRs and issues, runs, workflows, releases, search and `api`; `gh repo clone/sync/fork`, `gh pr checkout`, `gh extension`, `gh run download` and approving reviews are refused, as is gh called by path; clone/init/worktree destinations are worked out with `-C`, the current directory and the folder clone names after the URL (only when no destination is given); the `gh api` method check also reads the normalised text; the `.git/config` tripwire covers push settings (`push.*`, `remote.pushdefault`, `branch.*.pushremote`, `remote.*.mirror`); code piped or fed through a heredoc into a shell, and `pwsh -Command`, are refused; environment dumps by path (`/usr/bin/env`), with `env -u VAR`, and from interpreters (`p ENV`, `….environ`, `process["env"]`) are refused; interpreter one-liners are matched with attached `-c'…'` and more APIs (Open3, passthru, osascript, awk `system`); environment and interpreter rules read only the commands that run (not `rg`, `grep` or `echo` text, nor masked messages); URLs no longer count as protected paths.
- **Why:** Codex read that `gh repo clone … .githooks/x` and `gh pr checkout` wrote through an unsandboxed tool, that `git clone --branch main URL .githooks/x` and `git -C .githooks init` checked the wrong folder, that `-X D\ELETE` and `push.default=matching` slipped past, plus shell-stdin, env-dump and interpreter spellings and three false positives (`rg environ docs`, a commit message mentioning `os.environ`, a clone source URL ending in `.github`).
- **Rejected:** a deny-list for gh (an allow-list doesn't depend on knowing every risky subcommand).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 552 cases pass, with each input from this pass and its false positives; the other suites pass on both shells.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-14 — Guard, round 8d: Codex block A, fourth pass (NOT APPROVED, 8 points; 7 fixes confirmed)
- **Phase / issue:** —
- **What:** more shells are re-scanned (`csh`, `tcsh`, `fish`, `ash`, `mksh`, `yash`, `pwsh`, `busybox`…), but only when the shell is what runs (the command word, or after wrappers, options, `VAR=…` or numbers; `echo bash -c …` is text); interpreter one-liners are recognised with any options before `-c`/`-e`/`--eval` and with git anywhere in the code; a secret-named variable anywhere in a command that reads the environment (`ENV.fetch("GH_TOKEN")`, `.get(    "GH_TOKEN")`) is refused; `git mv`'s destination is not resolved as a source (`git mv src/app.py .` is fine); for `clone`/`init`/`worktree add` only the destination is checked (a source URL like `…/acme/.github` is fine); escaped commas don't count as brace expansion; `python3 -m pytest -k git` is a test filter. The security guide now says where the guard stops: programs the agent writes and runs are covered by the sandbox (no writes to `.git/` or the guardrails, no access to `~/.config/gh` or the Keychain) and by the ruleset, CI and review, not by text checks.
- **Why:** Codex read that `python3 -W ignore -c …`, a long alias, `/bin/csh -c …` and `ENV.fetch(…)` slipped past, and found four false positives (`git mv … .`, a clone URL ending in `.github`, `echo bash -c …`, `{foo\,bar}`). Its fourth point (write a script, then run it) can't be closed by reading command text, so the guide states the boundary and the layers that cover it.
- **Rejected:** scanning written files for code patterns (any program can build the same calls at run time; the sandbox is the barrier there).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 513 cases pass, with each Codex input refused and each false positive allowed.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-14 — Guard, round 8c: Codex block A, third pass (NOT APPROVED, 7 points)
- **Phase / issue:** —
- **What:** unquoted `*`, `?`, `[` and brace expansions (`{a,b}`, `{x..y}`; not `stash@{0}` or `@{u}`) in a git command are refused, since bash expands them after the guard has looked; `"$TMPDIR/…"` is accepted only as the value of an output option, and global options (`-C …`) must be literal too; a NUL from `$'\0'` or `$'\c@'` makes the scan fail (it would split the scanner's output); `/bin/bash -c`, `env bash -c` and any shell word followed by `-c` are re-scanned; reading a secret by name from an interpreter (`os.environ["GH_TOKEN"]`, `.get(…)`, `process.env.…TOKEN`, `getenv`) and running git from an interpreter one-liner (`subprocess`, `execSync`…) are refused; `git rm` and `git mv` pathspecs are resolved with `git ls-files` and refused when they reach a guardrail file, and `clone`, `init` and `worktree add` can't target a guardrail folder; `tag --verify`/`-v` and `stash create` no longer count as ref changes. AGENTS.md lists the new git rules.
- **Why:** Codex read that `git commit --no-{v..v}erify` becomes `--no-verify` after the check, that `TMPDIR=refs/heads; git reset --soft $TMPDIR/main` used the output exception to hide a revision, that `g$'\0'it` split into two harmless-looking records, that `/bin/bash -c '…'` wasn't re-scanned, that `os.environ["GH_TOKEN"]` was allowed, and that `git rm -r <pattern>` could reach guardrail files without naming them.
- **Rejected:** expanding globs in the guard (the result depends on the files at run time; quoting is simple and git matches pathspecs itself).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `AGENTS.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 495 cases pass, each Codex input refused and the ordinary forms allowed (`git stash show stash@{0}`, `git log @{u}..HEAD`, `git add '*.py'`, `os.environ["HOME"]`, `import gitlab`, `git clone … /tmp/r`, `git tag --verify v1 && git switch …`); a history repo with a real guard for `git rm -r '*.sh'` and `git mv .claude x`.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-14 — Guard, round 8b: Codex block A re-review (NOT APPROVED, 10 points)
- **Phase / issue:** —
- **What:** the scanner keeps each quoted word whole (whitespace inside a word no longer splits it into several arguments for the checks); every git argument must be written out: a revision, option or path taken from a variable or substitution is refused, except `"$TMPDIR/…"` for git output; git output into the temp folder (real path outside the repo) is not counted as a change, so a push after it is fine; `branch` and `tag` also count as revision consumers after a fetch in the same command; only `branch`/`tag`/`stash`/`worktree`/`remote` that really create or move something mark refs as changed (`git branch --show-current`, `git tag --list` don't); `git branch -m`/`-c` (rename or copy, no overwrite) are allowed and the force check is case-sensitive; `NAME=git` values (`docker build --build-arg VCS=git`) aren't taken for git calls; trailing whitespace removed.
- **Why:** Codex read that `r=ahead; git reset --soft "$r"` and `o=--output=…; git log "$o"` skipped the revision and option checks (they saw the text `$r`), that a quoted output path with spaces was checked only up to the first space, and that `git fetch && git branch x FETCH_HEAD` slipped past the same-command rule; plus four false positives.
- **Rejected:** blocking `branch -m`/`-c` in general (they can't overwrite a branch or bring in unchecked commits; `-M`/`-C`/`-f` can and stay blocked).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 459 cases pass, with each of Codex's inputs (variables, spaces in a quoted path, fetch then branch/tag, `$msg` as a message) refused and its false positives allowed (`pytest -k "unit and git"`, `--build-arg VCS=git`, `git branch --show-current && git switch …`, `git tag --list && git merge --no-ff …`, `format-patch -o /tmp/p && git push …`, `git add "my file.txt"`).
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-14 — Guard, round 8: Codex block A (guard and settings, NOT APPROVED, 10 findings)
- **Phase / issue:** —
- **What:** the text rules also read the decoded commands, so paths, `.env` and gh words written in ANSI-C quoting (`$'\x2eclaude'`, `$'\x2eenv'`, `gh pr $'\x6derge'`) are seen as what they are; `git … --pathspec-from-file` is refused; a command that changes tracked files with git and then commits, pushes or merges in the same line is refused (the tripwire must see the result first: `git rm .githooks && git commit` would otherwise commit with the hooks already gone); `git reset` only to HEAD or an ancestor of it; `git merge` always needs `--no-ff` (`--no-commit` alone can still fast-forward) and `--ff`/`--ff-only` are refused; `git branch -f/-C/-M` is refused on any branch; a bare `environ`, `__dict__` and `getattr(os…` count as environment reflection; `-o`/`--output` are allowed into the temp folder (`$TMPDIR`, `/tmp`, no `..`), and a "git" right after an option of a test runner (`pytest -k git`, `go test -run git`) is a filter, not a command. After a git fetch, branch, tag or commit, a later reset, merge, checkout, switch, restore, cherry-pick, revert, worktree or stash in the same command is refused (revisions are checked as they are before the command runs); `$TMPDIR` written as text is trusted only when the command mentions TMPDIR in no other way, the real output folder (symlinks resolved) must be outside the repository, and git output counts as a change, so a commit or push after it must be its own command. The guide now says plainly what the guard can't do.
- **Why:** Codex traced each one (and, before its re-review was cut off, the fetch-then-reset and `read TMPDIR` routes): one command removing `.claude`, `.githooks` and `.github` via ANSI-C paths, committing (with the hooks just deleted) and pushing; the same with paths read from a file; `reset --soft` or a fast-forward `merge --no-commit` putting fetched commits on the branch with no hook; `.env` and `gh auth token` reached through ANSI-C words; `vars(os)["environ"]`.
- **Rejected:** refusing ANSI-C quoting altogether (`IFS=$'\n'`, `printf $'a\tb'` are ordinary); trying to list every way a program can read its environment (documented as a limit instead).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh`: 436 cases, every Codex input blocked and its false positives allowed (`pytest -k git`, `go test -run git`, `format-patch -o "$TMPDIR/…"`, `git log --output=$TMPDIR/…`, `printf $'a\tb\n'`, `os.environ["HOME"]`); history-repo cases for reset onto a descendant ref and merge `--no-commit` fast-forward.
- **Pending:** Codex re-review of block A, then blocks B and C.

## 2026-11-14 — Guard, round 7: third independent review (NOT APPROVED, 9 findings) while Codex is out of quota
- **Phase / issue:** —
- **What:** git options that write a file or run a program are refused for every subcommand (`--output`, `--output-directory`, `archive`/`format-patch -o`, `--upload-pack`, `clone`/`ls-remote -u`, `--receive-pack`, `--exec`, `grep -O`/`--open-files-in-pager`, `clone`/`init --template`, `-c`/`--config`, `--separate-git-dir`, also abbreviated); `git bisect` is off the allow-list; the allow-list matches words at line ends (`git reset`, `clone`, `gc`, `worktree` were refused by mistake); the tripwire runs in `$CLAUDE_PROJECT_DIR` and also checks `.git/config` (`core.hooksPath` other than `.githooks`, push redirects, aliases, includes, and settings that make git run a program); gh owner-only rules allow flags between gh's words and add `gh variable`, `release create|edit|delete|upload`, `workflow run|enable|disable`, `ruleset`, `pr edit --base`, `config get …token`, and gh api writes to merge/ref/settings endpoints, methods held in variables and GraphQL merge/ref mutations; `git clean` with `--force` or a later `-f`, and `reset … --hard` anywhere, are destructive; CI Authorship and the Dependabot exemption no longer skip merge commits.
- **Why:** the reviewer reproduced `git log --output=.git/config` rewriting the repo config (`core.hooksPath=/dev/null`, a push refspec to main), `git grep -O` and `git ls-remote --upload-pack` running a script outside the sandbox, `gh pr --repo o/r merge 1` passing, and `git clean --force -x -d` deleting `.env`; a merge commit could carry changes by any author past CI.
- **Rejected:** taking git and gh out of the sandbox exclusions (they need the owner's credentials and network; noted as the remaining structural gap, covered server-side by the ruleset and CODEOWNERS); making the owner identity configurable (the template is the owner's own; setup-repo already names the code owner).
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `scripts/check-records.sh`, `.github/workflows/ci.yml`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-guard.sh` and `/bin/bash scripts/test-guard.sh` (399 cases: every reproduced command blocked for the intended reason; `git reset HEAD app.py`, `git clone`, `git gc`, `git worktree list`, `git ls-files -o`, `gh pr edit --body`, `gh api …/releases/latest` and comment POSTs allowed; tripwire cases for `.git/config` and for a session in another directory); the other three suites pass on both shells; the real repo's `.git/config` has none of the refused settings; gitleaks and Semgrep `p/default` find nothing.
- **Pending:** Codex review in three blocks (its quota resets at 20:44).

## 2026-11-14 — Guard, round 6: Codex (one finding before its usage limit) and a second independent review (NOT APPROVED)
- **Phase / issue:** —
- **What:** the scanner decodes `$'…'` like bash, blocks anything it can't parse (no fallback), understands `#` comments and heredoc bodies (quoted delimiter: text; unquoted: its `$( )` are checked), checks what `$( )`, backticks, `<( )` and `trap` run as commands of their own, and treats `>|` as a redirection; `git` must be the literal, lowercase command word (no wrappers, prefixes, functions, aliases, `=git`, variables or patterns) and its subcommand must be on an allow-list (no `send-pack`, `subtree`, `http-push`…); abbreviated `--no-verify`/`--author` are caught; `checkout`/`switch`/`restore`/`reset`/`worktree`/`merge`/`cherry-pick`/`revert`/`stash`/`apply` are refused when they would rewrite guardrail files from another revision, a stash or a patch (asked to git itself, limited to the named paths); `.git/` is protected (hook, Edit deny, sandbox); Write/Edit paths are normalised; writes to patterns that could reach a guardrail (`.c?aude/…`, `.claude/{hooks,}`) and more write tools are refused; environment dumps are checked per command (bare `env`/`export`/`declare -p`/`set`, `printenv`, `${!…}`, secrets by name, `%ENV`, `ENVIRON`, `ps e`, `gh auth status -t`, `git credential`, `.env.*`, `.en?`); the hook now runs the guard **from HEAD**, and a **tripwire** refuses everything but reading while any guardrail file differs from HEAD.
- **Why:** Codex reproduced `$'g\x69t' push origin main` (the parse failure fell back to a lax check). The second review reproduced comment/heredoc quote desyncs that disabled every rule, git hidden behind a dozen prefixes or variables, `git send-pack` pushing to main without the pre-push hook, `--no-veri` skipping hooks for real, and git (outside the sandbox) overwriting `.claude/hooks/guard.sh` with `git checkout HEAD~1 …` or `git apply`, after which a weakened guard would run. Running the committed guard plus the tripwire means a guardrail changed on disk by any route the rules missed stops the agent at its next action instead of disabling the checks.
- **Rejected:** more spelling-by-spelling patterns (each round found new ones; allow-lists and asking git for the real effect don't depend on spelling); taking git out of the sandbox exclusions (it needs the owner's credentials to push).
- **Files:** `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`; the hook runs from HEAD, so the new guard takes effect once committed).
- **Tested:** `bash scripts/test-guard.sh`, all cases from both reviews (blocked) and their false positives (allowed: heredoc commit message mentioning a push, `npm test -- -t "env set"`), plus a history repo for the git-write checks and the tripwire, and the hook command running HEAD's guard (a changed copy on disk is ignored; a missing or crashing one blocks).
- **Pending:** Codex's full review (its usage limit resets at 20:44).

## 2026-11-14 — Parts 2–6: fixes from the independent review (NOT APPROVED, 14 findings)
- **Phase / issue:** —
- **What:** the guard refuses commands over 20,000 characters or 150 separators before parsing; `builtin cd`/`command cd` count as moving; a root `.devcontainer.json` is a guardrail everywhere; `dod-reviewer` checks sections 1–5 when called from `/close-phase` (the phase's Result, ✅ and CHANGELOG come after it); Records compares from the merge base, exempts only real documentation (AGENTS.md, CLAUDE.md and `LICENSES/…` count as code), requires a new entry on top that adds to the count, dated no earlier than the newest, outside HTML comments, with a Why and a Tested of real words, and exempts Dependabot PRs only when every commit is Dependabot's (Authorship too); the dev container creates its `.claude` volume path as `vscode`, passes the agent's token as `GH_TOKEN`, and the guide says plainly that VS Code forwards SSH agent and git credentials, and how to stop it; `setup-repo.sh` compares logins case-insensitively and names the person running it as code owner (an organisation can't be one); `sync --apply` refuses a detached HEAD; the symlink test now plants the link on a late path so only the pre-copy check can stop it.
- **Why:** each was reproduced or reasoned by the reviewer: a 1,100-part command made the guard hit Claude Code's 10 s hook timeout, after which the action runs; `/close-phase` could never pass its own reviewer in full mode; the worklog check was satisfied by retitling an old entry, a commented-out entry or `-` placeholders, and failed docs-only PRs whose base had moved on; anyone with write access could add commits to a Dependabot branch and skip Authorship and Records.
- **Rejected:** raising the hook timeout (moves the limit, doesn't remove it); checking every worklog field.
- **Files:** `.claude/hooks/guard.sh`, `.claude/settings.json`, `.githooks/pre-commit`, `.claude/commands/close-phase.md`, `.claude/agents/dod-reviewer.md`, `scripts/check-records.sh`, `scripts/setup-repo.sh`, `scripts/sync-from-template.sh`, the four test scripts, `.github/workflows/ci.yml`, `.devcontainer/*`, `docs/SECURITY_GUIDE.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** all four suites pass on bash 5 and 3.2, with new cases for every finding (records: retitled, commented, bottom, placeholder, AGENTS.md, LICENSES/, merge base, Dependabot plus another commit; guard: long command, builtin cd, root `.devcontainer.json`; scripts: case, organisation, detached HEAD, late symlink). A 74-part command takes 1 s; anything over the limit is refused in 0.05 s.
- **Pending:** Codex review of parts 1–6.

## 2026-11-14 — Part 6 of the 10/10 plan: an identity of its own for the agent, CODEOWNERS, dev container
- **Phase / issue:** —
- **What:** `AGENT_BOT=<login> ./scripts/setup-repo.sh` gives a separate agent account write access only and turns on code-owner review (1 approval, re-approval after new pushes) in the main ruleset; new `.github/CODEOWNERS` (setup points it at the repository's owner); new `.devcontainer/` (base image by digest, Gitleaks by checksum for x64 and arm64, Claude Code 2.1.319, no Docker socket or home mounts) with a `Devcontainer` build workflow and Dependabot for its base image; `.devcontainer/` is a guardrail like `.github/`; `/status` warns in full mode when not in the container; SECURITY_GUIDE explains the agent account step by step (fine-grained token in the Keychain, HTTPS remote, `GH_TOKEN` at launch). Signed commits were already an option (`SIGNED_COMMITS=1`); the guide now says how it combines with the others.
- **Why:** Claude and Codex agreed that local controls that read command text can't be the authoritative boundary while the agent acts as the owner on GitHub. With its own write-only account and required code-owner approval, GitHub enforces that the agent can't merge, approve, change rulesets or secrets, even if the guard, the sandbox and the hooks were all bypassed. The dev container takes the rest of the Mac (keys, keychain, other repos) out of the agent's reach.
- **Rejected:** requiring the review without an agent account (GitHub doesn't let anyone approve their own PR, so every merge would be blocked); making the bot account or the container mandatory from setup (they need the owner to create an account and install Docker; full mode recommends both and `/status` reminds); a GitHub App instead of a bot account (more setup for one person, same effect here); installing Claude Code with the `curl | bash` installer (the template blocks that pattern).
- **Owner decisions taken as defaults (can be changed):** the bot account is optional and recommended in full mode; the dev container is recommended, not enforced; signing stays optional (`SIGNED_COMMITS=1`).
- **Files:** `scripts/setup-repo.sh`, `scripts/test-scripts.sh`, `.github/CODEOWNERS`, `.github/workflows/devcontainer.yml`, `.github/dependabot.yml`, `.devcontainer/{Dockerfile,devcontainer.json}`, `.claude/settings.json`, `.claude/hooks/guard.sh`, `.githooks/pre-commit`, `scripts/test-guard.sh`, `scripts/test-githooks.sh`, `scripts/sync-from-template.sh`, `.claude/commands/status.md`, `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`, `README.es.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-scripts.sh` (agent account: write access and code-owner review; no account: no review; invalid login and the owner's own login refused; CODEOWNERS rewritten), guard and git hook tests for `.devcontainer/`. The image was **not built here** (that would run downloaded code on this Mac): the `Devcontainer` workflow builds it on the PR. Claude Code's Linux sandbox inside an unprivileged container (bubblewrap) is untested and may need `enableWeakerNestedSandbox`; the agent-account flow is untested end to end (needs the account).
- **Pending:** the owner creates the agent account and tries the flow; first `Devcontainer` build on the PR; Codex review.

## 2026-11-14 — Part 5 of the 10/10 plan: simpler to keep up to date
- **Phase / issue:** —
- **What:** one worklog entry per piece of work (follow-up commits update it) instead of one per change; light mode removes `ROADMAP.md`, `RISKS.md` and `docs/phases/` at setup (switching to full brings them back); the Records check keeps the Spanish diagrams in step with `docs/WORKFLOWS.md` (same number, type and arrows per diagram); exact test counts removed from the Spanish guide and the diagrams, where they kept going stale.
- **Why:** per-change entries for review fixes buried the reasons that matter (this very worklog grew five "round" entries for one piece of work); light-mode projects carried files they were told not to use, which the agent still read and sometimes updated; the 13 diagrams exist twice (English source, Spanish copy for the owner) and had already drifted once while editing part 3; every test added made several docs wrong.
- **Rejected:** removing the Spanish diagrams (the owner asked for a Spanish guide with diagrams); generating one from the other (a translation isn't mechanical); keeping the counts in sync with a script (more machinery than the counts are worth: the README badge and *How it was tested* keep them).
- **Files:** `AGENTS.md`, `.claude/skills/record-changes/SKILL.md`, `scripts/setup-repo.sh`, `scripts/check-records.sh`, `scripts/test-check-records.sh`, `scripts/test-scripts.sh`, `README.md`, `README.es.md`, `docs/WORKFLOWS.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-check-records.sh` (matching and differing diagrams), `bash scripts/test-scripts.sh` (light mode removes the three, keeps the five), `bash scripts/check-records.sh` on the template (13 diagrams each).
- **Pending:** Codex review.

## 2026-11-14 — Part 4 of the 10/10 plan: script tests, actionlint, safe sync, scanner updates
- **Phase / issue:** —
- **What:** new `scripts/test-scripts.sh` (33 cases) runs `setup-repo.sh` and `sync-from-template.sh` for real on throwaway copies with a fake `gh` that records the API calls; `sync --apply` refuses uncommitted template files, symlinks anywhere on the way (checked before copying anything) and unknown options; the Hook job runs actionlint 1.7.12 (pinned, SHA-256 checked) and the new tests; the scanner images move to `.github/scanners/*/Dockerfile` (tag and digest) so Dependabot's docker ecosystem keeps them current with the same cooldown; the new script is a guardrail like the other tests.
- **Why:** the two scripts that configure GitHub and update old projects had no tests; the first test run found a real bug: a second `setup-repo.sh` run stopped silently at the placeholder step (`grep` finding nothing under `set -e -o pipefail`), although the script says it can be run more than once. `sync --apply` copied whatever was on disk in the template (unreviewed work) and followed symlinks, so a planted `.claude/hooks -> elsewhere` would make it write outside the project. The scanner digests were pinned but nothing would ever propose updating them.
- **Rejected:** a real GitHub repo for the setup tests (slow, needs credentials, and was already done once by hand); building the scanner images (they are only read for their FROM line); actionlint's shellcheck integration (it would depend on the runner's shellcheck version; scripts are already checked; the inline `exit $failed` was quoted anyway).
- **Files:** `scripts/test-scripts.sh`, `scripts/setup-repo.sh`, `scripts/sync-from-template.sh`, `.github/workflows/ci.yml`, `.github/dependabot.yml`, `.github/scanners/{semgrep,osv-scanner}/Dockerfile`, `.claude/settings.json`, `.claude/hooks/guard.sh`, `.githooks/pre-commit`, `README.md`, `README.es.md`, `docs/SECURITY_GUIDE.md`, `docs/WORKFLOWS.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** `bash scripts/test-scripts.sh` 33/33 with bash 5 and macOS bash 3.2; the other suites still pass. actionlint, the Semgrep/OSV changes and the Dependabot docker ecosystem are untested locally (not run here, so no downloaded code is executed): first verified by CI on the PR.
- **Pending:** CI run on the PR; Codex review.

## 2026-11-14 — Part 3 of the 10/10 plan: the method's order
- **Phase / issue:** —
- **What:** the Definition of Done is split into sections 1–6 (before the PR) and 7 (after the merge, the owner's); `/close-phase` runs first and stops on uncommitted work; `/prepare-pr` stops unless the phases are closed and `development` already has all of `main`, fills in a new `.github/pull_request_template.md`, and pushes as its own command; `dod-reviewer` treats section 7 as after-merge and checks `origin/main` is an ancestor; `/status` spots a merged PR and proposes bringing `development` up to date; AGENTS.md states the order.
- **Why:** the reviewer was asked to verify, before the PR, things that only exist after the merge (deployment working, issue closed), so it either failed for the wrong reason or was told to ignore items; the DoD required "the PR template filled in" but there was no template; nothing stopped a PR from a `development` that lacked `main`'s commits, so the checks ran on something other than what would be merged; and nothing said what to do after a merge.
- **Rejected:** a separate `/after-merge` command (one more thing to remember; `/status` already runs at the start of every session); letting `/prepare-pr` close the phase itself (closing writes Result and CHANGELOG and deserves its own review).
- **Files:** `docs/DEFINITION_OF_DONE.md`, `.claude/commands/{close-phase,prepare-pr,status}.md`, `.claude/agents/dod-reviewer.md`, `.github/pull_request_template.md`, `AGENTS.md`, `docs/WORKFLOWS.md`, `README.md`, `README.es.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`).
- **Tested:** read through the commands in order against the DoD sections; diagrams in WORKFLOWS and README.es updated with the new steps. Untested in a live Claude session yet.
- **Pending:** a live run of `/close-phase` → `/prepare-pr` in a throwaway project; Codex review.

## 2026-11-14 — Part 2 of the 10/10 plan: fail closed, real worklog entries
- **Phase / issue:** —
- **What:** the guard hook command fails closed (`bash …/guard.sh || exit 2`); `check-records.sh` requires a real worklog entry (dated heading, filled-in Why and Tested in the added lines), counts Markdown under `.claude/` as code, exempts only PRs that GitHub says Dependabot opened, and fails on a missing STATE or an unreadable range.
- **Why:** Claude Code treats any hook exit other than 2 as "allow", so a missing, unreadable or crashing guard silently let everything through. The Records check passed if `docs/WORKLOG.md` changed at all (a typo was enough), exempted every `.md` file (including the agent's own commands and skills, which change its behaviour), and trusted the commit author email, which anyone can set, for the Dependabot exemption.
- **Rejected:** requiring a CHANGELOG line per PR (in full mode it is written once per phase on purpose); checking every worklog field (What/Rejected/Files are often legitimately short; Why and Tested are the ones that matter).
- **Files:** `.claude/settings.json`, `scripts/check-records.sh`, `scripts/test-check-records.sh`, `scripts/test-guard.sh`, `.github/workflows/ci.yml`, `.claude/skills/record-changes/SKILL.md`, `docs/SECURITY_GUIDE.md`, `README.md`, `README.es.md`.
- **Commits:** pending (owner commit with `GUARDRAILS_OWNER_CHANGE=1`, together with part 1).
- **Tested:** `bash scripts/test-check-records.sh` 12/12 (entry without heading, empty Tested, `.claude/` Markdown, fake Dependabot author, bad range and missing STATE all fail); `bash scripts/test-guard.sh` 235/235, including the settings hook command blocking with a missing guard and a crashing one.
- **Pending:** Codex review.

## 2026-11-14 — Part 1, round 2: fixes from the Codex re-review
- **Phase / issue:** —
- **What:** the commit-time guardrail in `pre-commit` (any staged change to protected files is refused unless the owner sets `GUARDRAILS_OWNER_CHANGE=1`); Gitleaks fail-closed; guard: read-only `git config`, no `git -c`, `GIT_*`, plumbing or `gh alias`, more env-dump forms; `scripts/test-githooks.sh` in CI.
- **Why:** the Codex re-review of `fdc4c31` reproduced bypasses through git plumbing (staging a rewritten workflow with `hash-object` + `update-index` without touching the working tree, so the sandbox never sees it), push aliases, `GIT_CONFIG_*` environment and other env-dump forms. Patterns alone can't close that class; checking what is staged at commit time can.
- **Rejected:** relying only on more guard patterns; a CI check on protected paths (the PR could change the check itself; the real fix for that is a separate bot identity with CODEOWNERS, part 6).
- **Files:** `.githooks/pre-commit`, `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `scripts/test-githooks.sh`, `scripts/sync-from-template.sh`, `scripts/setup-repo.sh`, `.github/workflows/ci.yml`, `AGENTS.md`, `docs/SECURITY_GUIDE.md`, `README.md`, `README.es.md`, `docs/WORKFLOWS.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit, made by the owner with `GUARDRAILS_OWNER_CHANGE=1` (the agent was blocked from using the switch, as designed).
- **Tested:** guard 125/125, git hooks 8/8 (guardrail commits refused for `.github/`, an enforcement script and `.claude/hooks`; refused without Gitleaks; clean commit accepted; owner switch accepted; token refused; wrong author refused), records 6/6.
- **Incident:** the first version of `test-githooks.sh` mixed git's output into the temp repo path, created a folder with that name inside this repository and ran `git commit` there with the owner switch, committing work in progress (`f75a3fa`, never pushed). Undone with a soft reset (no work lost); the test now silences setup output and refuses to commit anywhere outside its own temp dir.
- **Round 3 (Codex re-review of round 2, verdict CHANGES NEEDED):** path-qualified or wrapped git (`/usr/bin/git`, `command git`, `PATH=…`, `BASH_ENV=…`) skipped every git rule; merges, `am`, cherry-pick/revert/rebase can create commits without `pre-commit`; a protected directory replaced by a symlink escaped the matcher; the hook tests could write outside their temp dir if setup failed and silently skipped half their cases without Gitleaks; false positives on words in commit messages. Fixed: the guard parses the real git subcommand; new `pre-merge-commit` and `pre-applypatch` hooks; `($|/)` matching with `-z`; `safe()` checks and fatal-without-Gitleaks-in-CI in the tests; Gitleaks installed in CI. Guard 147/147, git hooks 11/11 (merge refused and owner merge accepted, symlink refused), records 6/6.
- **Conclusion shared with Codex:** a local guard that reads command text can't be an authoritative boundary while the agent runs with the owner's identity; it stops mistakes and most prompt injection. The authoritative barriers are the OS sandbox (files and network) and a separate GitHub identity for the agent with CODEOWNERS (part 6).
- **Round 4 (Codex re-review of round 3, CHANGES NEEDED):** config values weren't bound to their keys (`git config core.hooksPath serbenda@gmail.com` disabled hooks); `command -- git` and git inside `$( )` escaped; `git pull --no-verify` and fast-forward merges skipped `pre-merge-commit`; `git -C other-repo commit` checked the wrong branch; no `git am` test; and a commit message mentioning `/usr/bin/git` was a false positive. Fixed: key-bound values; substitution and wrapper rules on a message-stripped copy of the command (escape-aware, so a quote can't hide code); `pull` blocked, merges need `--no-ff`/`--no-commit`; `-C` only for reading; `git am` tests. Guard 165/165, git hooks 13/13, records 6/6.
- **Round 4, follow-up:** the round-4 review stopped at Codex's usage limit, after flagging a hypothesis that turned out right: replacing double-quoted messages by MSG hid `$( )` and backticks, which the shell still runs inside double quotes (`git commit -m "$(git push …)"` passed). Fixed: only single-quoted messages and double-quoted ones without `$` or backticks are treated as text. Guard 168/168.
- **Round 5 (independent review while Codex was at its usage limit, NOT APPROVED):** the message-stripping `sed` didn't know where quotes were: a `-m '` inside one quoted string and the closing quote in a later one swallowed the real commands in between (`echo " -m 'x" ; git push origin main ; echo "'"` passed, and so did `--no-verify`, config, remote, plumbing and guardrail writes hidden that way), and `" -m '$(git push …)'"` hid a substitution. Older gaps: a branch change earlier in the same command (`git switch main && git commit`), `git branch -M/-f … main`, worktrees on main, and, found while testing, subshells, `if/then`, `{ }`, `!`, `&`, leading redirections, `eval`, `sh -c` and `find -exec` hid git entirely. Fixed: a small quote-aware scanner (python3, already required by the hook) splits commands the way the shell does and only treats truly literal message operands as text, failing closed on anything it can't parse; moves of main refused; commit or plain push after a branch or directory change refused; `GIT_*`/`PATH=` rules on the scanned commands (no false positive on a message mentioning `PATH=`). New `.githooks/pre-push` refuses pushes to `main`/`master` and force pushes whatever produced them, the backstop that doesn't depend on reading the command. Guard 232/232 (bash 3.2 and 5), git hooks 19/19, records 6/6.
- **Rejected:** more sed patterns (each fix opened a new spelling); `shlex` (it doesn't model `$( )`, backticks or `$'…'`).
- **Pending:** Codex re-review of rounds 4–5 (usage limit until 15:41); owner commit with `GUARDRAILS_OWNER_CHANGE=1`.

## 2026-11-14 — Challenge: independent second opinion on any decision
- **Phase / issue:** —
- **What:** `/challenge` command and read-only `challenger` subagent; `/decision` challenges every recommendation before showing it, ADRs gain a *Challenge* section, and AGENTS.md makes it a rule for any proposed decision and for whenever the owner says "challenge".
- **Why:** the owner used a second AI to challenge Claude's proposals and wants the same without it. In the same conversation an agent tends to agree with its own reasoning, so the challenger gets only a brief of the proposal (never the reasoning), argues from an assigned lens, ideally on another model, and must give at least 3 real objections or say it found fewer. The owner asked for it to cover any decision, not only code.
- **Rejected:** a single challenger (one lens repeats the agent's blind spots; two opposing lenses give a real comparison); asking the same session to "play devil's advocate" (it has seen and is anchored on its own reasoning); forcing a fixed number of objections (invites made-up ones); challenging every phase plan automatically (cost on every phase; plans are challenged on request).
- **Files:** `.claude/agents/challenger.md`, `.claude/commands/challenge.md`, `.claude/commands/decision.md`, `docs/decisions/_template.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `README.es.md`, `docs/WORKFLOWS.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** frontmatter of the new agent and command checked against the existing ones; `scripts/sync-from-template.sh` picks both files up through its `ls .claude/commands/*.md .claude/agents/*.md`; hook and records tests pass. Not yet run in a real Claude Code session; the edited Mermaid diagram (decisions) was not rendered.
- **Pending:** owner: try `/challenge` on a real decision and see the diagram on GitHub.

## 2026-11-14 — Part 1 of the 10/10 plan: real barriers
- **Phase / issue:** —
- **What:** `.github/` and the enforcement scripts become owner-only (deny rules, hook, sandbox `denyWrite`); pushes are an allow-list; `--config-env` and interpreter env dumps blocked; Docker inside the sandbox; strict required checks and no squash in `setup-repo.sh`.
- **Why:** the Codex review showed the agent could rewrite the CI it is checked by (the ruleset only trusts job names), and found guard bypasses (`+HEAD:development`, `b=main; … $b`, `--config-env`, `os.environ`) and Docker escaping the sandbox. The fix moves the important protection to the sandbox, which the operating system enforces, and keeps the hook as a second net.
- **Rejected:** more deny patterns for pushes (an allow-list can't be dodged by new spellings); keeping Docker excluded from the sandbox (it can mount the host).
- **Files:** `.claude/hooks/guard.sh`, `.claude/settings.json`, `scripts/test-guard.sh`, `scripts/setup-repo.sh`, `docs/SETUP.md`, `docs/SECURITY_GUIDE.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `README.es.md`, `docs/WORKFLOWS.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** 107/107 hook tests (all Codex bypasses as must-block cases). Real headless Claude session with the sandbox: a Python script the hook cannot recognise was denied writing to `.github/workflows/ci.yml`, `scripts/check-records.sh`, `.claude/settings.json` and `.githooks/pre-commit` (Operation not permitted), and allowed to write `docs/STATE.md`; Docker could not read `~/.docker` nor reach the daemon.
- **Pending:** Codex re-review of this part.

## 2026-11-14 — Workflow diagrams, showcase README, Spanish guide
- **Phase / issue:** —
- **What:** 13 Mermaid diagrams in `docs/WORKFLOWS.md` (and translated in `README.es.md`), a showcase `README.md` with an SVG banner and badges, the project README skeleton moved to `docs/templates/README.project.md`, and `setup-repo.sh` swapping it in on the first run.
- **Why:** the owner wanted every option of the template documented as flows, a README that presents the template well, and the Spanish guide up to date. A template banner would be wrong in the projects created from it, so the showcase and the project README are now separate files.
- **Rejected:** keeping one README with a template section to delete by hand (the old approach, error-prone); diagrams only in English (the owner reads the Spanish guide).
- **Files:** `README.md`, `README.es.md`, `docs/WORKFLOWS.md`, `docs/templates/README.project.md`, `.github/assets/banner.svg`, `scripts/setup-repo.sh`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** all 28 diagrams parsed and rendered with Mermaid 11.4.1 in the browser; that found labels starting with "2." rendered as "Unsupported markdown: list", fixed. Banner checked in the browser at full width. `setup-repo.sh` with a fake `gh`: a new project gets the skeleton README with its name and no banner; the template itself is left unchanged.
- **Pending:** see the diagrams and badges on GitHub after the push.

## 2026-11-14 — Security hardening: SAST, dependency scanning, sandbox, threat model
- **Phase / issue:** —
- **What:** CI jobs SAST (Semgrep) and Dependencies (OSV-Scanner), required on `main`; Claude Code sandbox in the project settings; `docs/THREAT_MODEL.md`, *Security impact* per phase and a concrete security DoD; extended global settings, installed on the owner's Mac (backup `~/.claude/settings.json.bak.2026-11-14`).
- **Why:** the owner asked for apps built with Claude to be as hard to hack as possible. The template protected the workflow (secrets, authorship, branches) but nothing checked the application code or its dependencies, and nothing forced thinking about threats before writing sensitive code.
- **Rejected:** CodeQL (needs a build per language and is free only on public repos; Semgrep covers any language without a build); a global sandbox (would break folders that need other tools); allowing `dangerouslyDisableSandbox` (it would make the sandbox optional for the agent); scanning `.claude/skills` (third-party example code and a lower-bound `requirements.txt` gave false positives; excluded in both jobs).
- **Files:** `.github/workflows/ci.yml`, `.github/dependabot.yml`, `.claude/settings.json`, `scripts/setup-repo.sh`, `scripts/test-guard.sh`, `scripts/test-check-records.sh`, `docs/THREAT_MODEL.md`, `docs/DEFINITION_OF_DONE.md`, `docs/phases/_template.md`, `docs/SECURITY_GUIDE.md`, `.claude/commands/new-phase.md`, `.claude/agents/security-reviewer.md`, `AGENTS.md`, `README.md`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** Semgrep and OSV-Scanner run locally from the pinned digests: Semgrep found a real issue in the template (Dependabot without cooldown, fixed) and flagged SQL and command injection and `debug=True` in a vulnerable sample; OSV flagged a vulnerable `requirements.txt` and passes with no lockfiles. Sandbox in a headless Claude session: PyPI reachable, `example.com` blocked, writing to `$HOME` blocked, writing in the project allowed, tests pass inside it. Global settings in a plain folder: reading `.env`, `printenv` and editing `~/.zshrc` blocked. `setup-repo.sh` ruleset create/update/refuse with a fake `gh`. Hook tests 85/85 also from a checkout on `main`.
- **Pending:** see the SAST and Dependencies jobs run on GitHub; owner: run `./scripts/setup-repo.sh` again on project-template (and later on other repos) so their rulesets require the two new checks.

## 2026-11-14 — Fewer skills, global settings moved into the security guide
- **Phase / issue:** —
- **What:** removed `claude-api`, `skill-creator`, `doc-coauthoring` and the Anthropic third-party notices; `docs/claude-settings-global.json` moved into `docs/SECURITY_GUIDE.md` as a JSON block. 6 skills remain (~0.7 MB instead of 3.1 MB).
- **Why:** `claude-api` and `skill-creator` already ship with Claude Code and the account, and a pinned `claude-api` inside the repo takes precedence and goes stale (models, prices); `doc-coauthoring` competed with the template's own method for VISION, phase files and ADRs; the notices only covered components of skills removed earlier; the global settings are installed once per Mac, not copied into every project.
- **Rejected:** removing `repo-security-posture` (the only way to check later that the repo protection still holds), `README.es.md`, `RISKS`/`ARCHITECTURE`/`ROADMAP` (light mode already ignores them) and `SECURITY.md` (needed as soon as a repo goes public).
- **Files:** `.claude/skills/{claude-api,skill-creator,doc-coauthoring}/`, `.claude/skills/ANTHROPIC_THIRD_PARTY_NOTICES.md`, `docs/claude-settings-global.json` (removed); `.claude/skills/UPSTREAM.md`, `docs/SECURITY_GUIDE.md`, `AGENTS.md`, `CLAUDE.md`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** the JSON block in the guide parses; no remaining skill references imageio, FFmpeg, Pillow or font files; no references left to the removed files; links checked; hook and records tests pass.
- **Pending:** owner: copy the block to `~/.claude/settings.json` if not done yet.

## 2026-11-14 — setup-repo.sh is safe to run on the template itself
- **Phase / issue:** —
- **What:** `setup-repo.sh` skips the placeholder replacement and the project mode when the repo is `project-template` (the history reset already skipped it).
- **Why:** about to run it on the template to protect its `main`: step 2 would have replaced every `PROJECT_NAME` placeholder with "project-template".
- **Rejected:** applying the ruleset by hand with `gh api` (the script is the single source of truth for repo settings).
- **Files:** `scripts/setup-repo.sh`.
- **Commits:** this entry's commit.
- **Tested:** with a fake `gh`: on `serbenda/demo` it still replaces the placeholder and resets the history; on `serbenda/project-template` it changes no file.
- **Pending:** —

## 2026-11-14 — Light mode tested; GitHub Actions bumped
- **Phase / issue:** —
- **What:** light mode run end to end in a real Claude Code session; `actions/checkout` → v7.0.1 and `gitleaks-action` → v3.0.0 in `ci.yml`, superseding Dependabot PR #4 (opened against the old Spanish `ci.yml`, it no longer applies).
- **Why:** light mode was the only untested part; gitleaks-action v2 runs on Node 20, which GitHub has removed from its runners.
- **Rejected:** merging PR #4 as is (conflicts with the current `ci.yml`); staying on the old versions.
- **Files:** `.github/workflows/ci.yml`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** light mode in `template-smoke-test` (branch `light-test`): `/new-phase` stopped a request that went against VISION and wrote no phase file; after approval Claude recorded the plan under *Current work*, wrote ADR 0002, `greet.py` and 6 tests, filled in SETUP; `/close-phase` moved it to *Recently done* with no CHANGELOG. `greet.py` and its tests checked by hand. Actions: release notes read (no input changes; checkout's credential change doesn't apply, `persist-credentials: false`), tags resolved to the pinned SHAs. CI on GitHub not seen yet (not pushed).
- **Pending:** owner: merge `development → main`, mark project-template as a template repository and protect its `main`, delete the smoke repo.

## 2026-11-13 — Claude commands tested end to end; fixes from the test
- **Phase / issue:** —
- **What:** ran Claude Code headless (`claude -p`) in `serbenda/template-smoke-test` through `/status` → `/new-phase` → approval → implementation → `/close-phase` → reviewers → `/prepare-pr`, and fixed what it found in the template: guard false positives (and the bypasses the first fix opened), ineffective `Write(...)` deny rules, the example High risk in RISKS, the README template section on setup, and a place to record owner approvals.
- **Why:** the commands and the guard had never run in a real Claude session; every finding came from actual use.
- **Rejected:** keeping the first per-subcommand guard fix: the security-reviewer showed it could be bypassed (`cd --`, `pushd`, `for`, `find | xargs`); the guard is now strict by default and relaxes only for simple commands.
- **Files:** `.claude/hooks/guard.sh`, `scripts/test-guard.sh`, `.claude/settings.json`, `docs/RISKS.md`, `scripts/setup-repo.sh`, `docs/phases/_template.md`, `.claude/commands/new-phase.md`, `.claude/commands/close-phase.md`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** `e598da0`, `90a78ef` and this entry's commit.
- **Tested:** in the smoke repo, `/status` read the state and flagged real issues; `/new-phase` created the phase file and waited for approval; after approval Claude made two commits, a worklog entry and passed Verify; `/close-phase` stopped on an unrecorded owner approval, then closed with dod-reviewer OK; `/prepare-pr` ran the three reviewers (security-reviewer found the guard regression, fixed here). Guard: 83/83 tests, including the reviewer's bypass cases. README trimming tested with a fake `gh`. `sync-from-template.sh` used twice for real on the smoke repo.
- **Pending:** light mode not exercised in a real session; owner: delete the smoke repo, merge `development → main`, mark project-template as a template.

## 2026-11-13 — End-to-end test on GitHub
- **Phase / issue:** —
- **What:** private throwaway repo `serbenda/template-smoke-test` created with the content of `development`, `setup-repo.sh` run for real, and the protections exercised. Fix found by the test: `setup-repo.sh` now starts CHANGELOG and WORKLOG empty on the first run.
- **Why:** nothing had been verified on GitHub itself; the CI and the ruleset only existed on paper.
- **Rejected:** running the Claude commands (`/status`, `/new-phase`…) from here: they need a Claude Code session opened in that repo, left to the owner.
- **Files:** `scripts/setup-repo.sh`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** on GitHub (account on Pro, private repo): `setup-repo.sh` created `development`, the "Protect main" ruleset and the labels (private vulnerability reporting and secret scanning need GitHub Advanced Security: warned, as expected); a direct push to `main` was rejected (GH013); PR #1 with code and no worklog → Records failed, merge BLOCKED; with a worklog entry → Secrets, Authorship, Hook and Records passed, CLEAN; an AI signature in the PR body → Authorship failed, BLOCKED. The history reset was tested locally with a fake `gh` (first run resets, second run doesn't).
- **Pending:** owner: delete `serbenda/template-smoke-test`; merge `development → main` in project-template (until then "Use this template" copies the old web template); mark project-template as a template repository and protect its `main`; try `/status` → `/new-phase` → `/close-phase` → `/prepare-pr` in a Claude Code session.

## 2026-11-13 — Enforce the records, scan secrets before commit, sync existing projects
- **Phase / issue:** —
- **What:** `Records` CI job and `scripts/check-records.sh` (worklog entry required when a PR changes more than docs; STATE ≤150 lines); `.githooks/pre-commit` with Gitleaks; `.github/dependabot.yml` for GitHub Actions; `scripts/sync-from-template.sh` for projects created from older versions.
- **Why:** skills trigger probabilistically, so the worklog rule needed a deterministic check; Gitleaks only in CI meant secrets reached GitHub before being caught; dropping Dependabot as "stack-specific" was a mistake, since the pinned actions never got updates; existing projects (Faro, Everskope…) had no way to get fixes such as the macOS hook fix.
- **Rejected:** a Claude Code Stop hook to force the worklog (it would fire on every turn, not per change); requiring CHANGELOG in CI (only full mode uses it, once per phase); copying `settings.json`/`ci.yml` in the sync script (projects adapt them, so it only reports them).
- **Files:** `scripts/check-records.sh`, `scripts/test-check-records.sh`, `scripts/sync-from-template.sh`, `.githooks/pre-commit`, `.github/dependabot.yml`, `.github/workflows/ci.yml`, `scripts/setup-repo.sh`, `docs/SETUP.md`, `docs/SECURITY_GUIDE.md`, `AGENTS.md`, `README.md`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** `test-check-records.sh` 6/6; `check-records.sh origin/main HEAD` on this repo passes; pre-commit without Gitleaks warns and lets the commit through; with Gitleaks 8.30.1 a clean commit passes silently and a commit with a fake `ghp_` token is blocked (tested 2026-11-13, corrected); sync script on a clone at `e8484d9` (old Spanish template): dry run lists new/changed/legacy files and the stale `guardia.sh` hook, `--apply` copies 16 files and the project's tests pass, a second run is clean, and it refuses to apply on `main`; YAML of `ci.yml` and `dependabot.yml` parses.
- **Pending:** see the Records job and Dependabot run on GitHub; run the sync script on Faro and Everskope (owner's call, repo by repo).

## 2026-11-13 — Leaner template: 9 skills, light/full mode, no duplicated records
- **Phase / issue:** —
- **What:** 9 Anthropic skills removed (6 kept for software work); project mode light/full in `AGENTS.md`, `STATE.md`, the commands, the reviewers, the DoD and `setup-repo.sh` (`MODE=light`); CHANGELOG now written once per phase, worklog after every change.
- **Why:** review of the template: unused skills cost context in every session and compete to trigger; the full process is too heavy for experiments and would end up skipped; writing every change twice (CHANGELOG and worklog) was friction with no extra information.
- **Rejected:** dropping CHANGELOG entirely (useful once others use the project); removing the PR flow (it is the control over the agent, kept in both modes); a third "medium" mode (two are easier to reason about).
- **Files:** `.claude/skills/` (9 folders removed), `.claude/skills/UPSTREAM.md`, `.claude/skills/record-changes/SKILL.md`, `.claude/commands/{status,new-phase,close-phase,prepare-pr}.md`, `.claude/agents/{architecture,dod}-reviewer.md`, `AGENTS.md`, `CLAUDE.md`, `docs/STATE.md`, `docs/DEFINITION_OF_DONE.md`, `docs/WORKLOG.md`, `scripts/setup-repo.sh`, `README.md`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** hook tests; `setup-repo.sh` with a fake `gh` in both modes (light sets *Mode: light* in STATE, default keeps full); skill frontmatter; links; every remaining skill listed in the guide and UPSTREAM.
- **Pending:** real end-to-end run on GitHub (needs `gh auth login`), in both modes.

## 2026-11-13 — Gaps for starting a project from scratch
- **Phase / issue:** —
- **What:** (1) deny rules narrowed so Claude can edit `.claude/launch.json` in P03; (2) stack checklist in `docs/SETUP.md`, linked from ROADMAP and copied by `/new-phase` into P03; (3) `setup-repo.sh` warns on private repos with GitHub Free, is idempotent and no longer stops halfway; (4) placeholder replacement no longer touches skills or `README.es.md`.
- **Why:** review of whether the template is complete for any new project: the P03 plan was blocked by our own permissions, removing CodeQL/Dependabot left the project's code and dependencies unchecked unless P03 restores them, and private repos on GitHub Free silently got no protection.
- **Rejected:** adding Dependabot/CodeQL back to the template (they need the stack); release/deploy guidance (left for each project's S3).
- **Files:** `.claude/settings.json`, `scripts/setup-repo.sh`, `scripts/test-guard.sh`, `docs/SETUP.md`, `docs/ROADMAP.md`, `.claude/commands/new-phase.md`, `docs/SECURITY_GUIDE.md`, `README.md`, `README.es.md`, `CLAUDE.md`, `.github/workflows/ci.yml`.
- **Commits:** this entry's commit.
- **Tested:** `test-guard.sh` 64/64; `setup-repo.sh` run against a fake `gh` in a local clone for three cases (private+Free → warns and exits 1 with the rest configured; public → protects main; second run → no duplicate rulesets) and the placeholder no longer changes skills; `.githooks/commit-msg` strips `Co-Authored-By` and rejects another author.
- **Pending:** a real end-to-end run on GitHub (needs `gh`, not installed): create a repo from the template, run `setup-repo.sh`, `/status` → `/new-phase` → `/close-phase` → `/prepare-pr`, and see CI pass.

## 2026-11-13 — Remove the Office and PDF skills
- **Phase / issue:** —
- **What:** `docx`, `xlsx`, `pptx` and `pdf` removed from `.claude/skills/`; `UPSTREAM.md`, `AGENTS.md`, `CLAUDE.md`, `README.es.md` and `CHANGELOG.md` updated. 18 skills remain.
- **Why:** the owner asked for it; they already ship with the account (`anthropic-skills:`), so the copies were duplicates, and they were the skills with the most scripts (~4 MB).
- **Rejected:** —
- **Files:** `.claude/skills/{docx,xlsx,pptx,pdf}/` (removed), `.claude/skills/UPSTREAM.md`, `AGENTS.md`, `CLAUDE.md`, `README.es.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** links checked; every skill folder is listed in `README.es.md` and `UPSTREAM.md`; `bash scripts/test-guard.sh` passes.
- **Pending:** —

## 2026-11-13 — Spanish guide to the template
- **Phase / issue:** —
- **What:** `README.es.md` explains in Spanish what the template is for, how to start a project, the day-to-day commands, every file and folder, the three reviewer subagents and all 22 skills. Linked from `README.md`.
- **Why:** the owner wants a Spanish explanation of everything while the template itself stays in English.
- **Rejected:** a full Spanish copy of every doc (two versions drift apart); translating the skills (done and reverted earlier).
- **Files:** `README.es.md`, `README.md`, `AGENTS.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** relative links checked; skill list matches `.claude/skills/` (22 folders).
- **Pending:** keep the guide in sync when files, commands or skills change (rule added to `AGENTS.md`).

## 2026-11-13 — Anthropic skills
- **Phase / issue:** —
- **What:** the 19 skills from anthropics/skills (commit `2c5958e`) copied unchanged into `.claude/skills/` and registered in `UPSTREAM.md`, with the source repo's third-party notices.
- **Why:** the owner wants all of them available in every project created from the template.
- **Rejected:** copying only the 5 useful ones that don't already ship with the account; translating the skills into Spanish (done and then reverted: the whole template stays in English, and untouched copies are easier to update and verify against upstream).
- **Files:** `.claude/skills/*`, `.claude/skills/UPSTREAM.md`, `.claude/skills/ANTHROPIC_THIRD_PARTY_NOTICES.md`, `AGENTS.md`, `CLAUDE.md`, `CHANGELOG.md`.
- **Commits:** this entry's commit.
- **Tested:** `diff -r` against the upstream clone shows the folders are identical; every `SKILL.md` frontmatter parses and its `name` matches the folder; `bash scripts/test-guard.sh` passes.
- **Pending:** check in a new project that the skills trigger; the template is now ~13 MB; review the `docx`/`pptx`/`xlsx`/`pdf` scripts before first use.

## 2026-11-13 — Template fully in English
- **Phase / issue:** —
- **What:** all files, folders, commands, subagents, the skill and the hook translated/renamed to English (`docs/fases` → `docs/phases`, `decisiones` → `decisions`, `RIESGOS` → `RISKS`, `ARQUITECTURA` → `ARCHITECTURE`, `SEGURIDAD` → `SECURITY_GUIDE`, `BITACORA` → `WORKLOG`, `/estado` → `/status`, `/nueva-fase` → `/new-phase`, `/cerrar-fase` → `/close-phase`, `/preparar-pr` → `/prepare-pr`, `guardia.sh` → `guard.sh`, `registro-cambios` → `record-changes`; stages `S0…`, phases `P01…`; CI checks Secrets/Authorship/Hook; `FIRMAS=1` → `SIGNED_COMMITS=1` in setup-repo.sh).
- **Why:** one language for everything, reusable by anyone, and consistent with third-party skills, which are in English.
- **Rejected:** bilingual (README.es + a per-project docs language), because it doubles maintenance and the copies drift apart.
- **Files:** the whole repo.
- **Commits:** this commit.
- **Tested:** `bash scripts/test-guard.sh` (63 cases) on macOS (bash 3.2).
- **Pending:** check CI on GitHub (the required checks were renamed: repos already configured with the old "Calidad"/"Secretos"/"Autoría" names must be updated by hand); PR `development → main`.

## 2026-11-13 — Claude-and-security-only template, with worklog
- **Phase / issue:** —
- **What:** removed everything that is not about Claude or security (Makefile, VS Code, formatting, CodeQL, Dependabot, GitHub templates) and added the `record-changes` skill with this worklog.
- **Why:** the template must work for any kind of development; the stack and its tooling are chosen per project. And with no memory between sessions, the context of each change has to be written down.
- **Rejected:** keeping only `.claude/` and `docs/` (no `setup-repo.sh` or CI), because nothing would prevent AI signatures or pushes to `main`.
- **Files:** `.claude/skills/record-changes/SKILL.md`, `docs/WORKLOG.md`, `docs/SETUP.md`, `.github/workflows/ci.yml`, `scripts/setup-repo.sh`.
- **Commits:** the one for this entry.
- **Tested:** `bash scripts/test-guard.sh` on macOS (bash 3.2).
- **Pending:** check CI on GitHub; PR `development → main`.
