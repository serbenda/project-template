# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned with [SemVer](https://semver.org/).

## [Unreleased]
### Added
- `/challenge` and the read-only `challenger` subagent: an independent second opinion on any decision, plan, idea or text. Two challengers get only a brief (never the agent's reasoning), attack it from two lenses, ideally on another model, and the owner gets a side-by-side comparison with the agent's view. Every proposed decision is challenged first; ADRs gain a *Challenge* section.
- `docs/WORKFLOWS.md`: every way of using the template as 13 Mermaid diagrams (what to do, new project, modes, sessions, full and light work, decisions, from a change to `main`, security layers, blocks, release, syncing old projects, updating skills); the same diagrams in Spanish in `README.es.md`.
- A showcase `README.md` for the template, with banner and badges. New projects start from `docs/templates/README.project.md`, which `setup-repo.sh` moves into place on the first run (removing the banner).
- **SAST** and **Dependencies** CI jobs, required on `main`: Semgrep (`p/default`, any language) and OSV-Scanner (any lockfile), both pinned by image digest. `setup-repo.sh` now updates an existing "Protect main" ruleset, so older repos get the new checks.
- Claude Code **sandbox** in `.claude/settings.json`: shell commands write only inside the project, reach only an allow-list of package and GitHub domains, and can't read SSH/AWS/gh credentials or the keychain; no escape hatch (`allowUnsandboxedCommands: false`).
- `docs/THREAT_MODEL.md`, a *Security impact* section in every phase file, and a concrete security Definition of Done (server-side authorisation per object, password hashing, rate limits, CORS, security headers, cookies, uploads, least-privilege database, tested backups). `security-reviewer` checks changes against the threat model.
- Global Claude Code settings in `SECURITY_GUIDE.md` extended: no editing its own settings, shell profiles, git config or SSH keys; no reading GPG, 1Password or browser data; bypass-permissions mode disabled; project MCP servers need approval.
- *Owner approvals* in the phase file: `/new-phase` records each approval with its date and `/close-phase` checks owner-dependent criteria against it.
- **Records** CI check (`scripts/check-records.sh`, 6 tests): PRs that change more than documentation need a worklog entry, and `docs/STATE.md` can't exceed 150 lines. Added to the required checks of `main`.
- `.githooks/pre-commit`: Gitleaks scans staged changes before the commit exists.
- `.github/dependabot.yml` for the pinned GitHub Actions (stack-independent).
- `scripts/sync-from-template.sh`: reports and applies template improvements to existing projects, never on `main`, never overwriting project-adapted files, and records the template version in `.claude/TEMPLATE_VERSION`.
- Project mode, light or full (`docs/STATE.md` → *Mode*, `MODE=light ./scripts/setup-repo.sh`): light keeps only VISION, STATE, WORKLOG and SETUP and plans in chat; full uses phases, roadmap, ADRs, risks and CHANGELOG. Claude proposes switching to full when the project grows.
- Stack checklist for phase P03 in `docs/SETUP.md` (run/verify commands, `launch.json`, CI job, Dependabot, CodeQL or Semgrep, `.gitignore`, required check); `/new-phase` copies it into the P03 acceptance criteria.
- `README.es.md`: Spanish guide explaining the structure, the workflow, the subagents and every skill.
- 6 skills from [anthropics/skills](https://github.com/anthropics/skills) (commit `2c5958e`) for software work: `mcp-builder`, `claude-api`, `skill-creator`, `webapp-testing`, `frontend-design` and `doc-coauthoring`, registered in `UPSTREAM.md` with the reasons the other 13 are left out.
- Own `record-changes` skill and `docs/WORKLOG.md`: after every change, the agent records what, why, what was discarded, commits, how it was tested and what is pending, and updates `CHANGELOG.md` if the change is visible.
- Work organization with agents ([decision 0001](docs/decisions/0001-working-with-ai-agents.md)): `docs/VISION.md`, `docs/STATE.md`, `docs/ROADMAP.md` (stages `S0…`, phases `P01…`), phase files in `docs/phases/`, ADRs in `docs/decisions/`, `docs/RISKS.md`, `docs/ARCHITECTURE.md` and `docs/SETUP.md`.
- Commands `/status`, `/new-phase`, `/close-phase` and `/decision`, and the `architecture-reviewer` subagent. `/prepare-pr` runs `make verify` and the three reviewers.
- `Makefile` with `make dev`, `make test`, `make lint`, `make links` and `make verify` (reproduces CI locally).
- `.claude/launch.json` for preview, `.vscode/` with recommended extensions and settings, and `.env.example`.

- Initial structure: Definition of Done, development → main flow, CI (Gitleaks, formatting, HTML, links), CodeQL, Dependabot, GitHub Pages publishing and setup script.
- Cloudflare's `security-audit` skill in `.claude/skills/`, pinned to commit `c1c8a8c`.
- Skills `web-perf` (Cloudflare, `cbf893b`) and `repo-security-posture` (superagent-ai, `0da315b`).
- Claude Code configuration in `.claude/`: no attribution in commits and PRs, deny/ask/allow permissions, `guard.sh` hook with tests, `security-reviewer` and `dod-reviewer` subagents, and the `/prepare-pr` command. `CLAUDE.md` imports `AGENTS.md`.
- Skills move from `.agents/skills/` to `.claude/skills/`.
- Git hook `.githooks/commit-msg` and CI **Authorship** job against AI attribution and wrong authors.
- GitHub Actions pinned to a SHA, and shellcheck in CI.
- `docs/SECURITY_GUIDE.md` and `docs/claude-settings-global.json`.
- Independent security review applied: the agent cannot modify `.claude/` or `.githooks/`; `--no-verify`, remote changes, making the repo public, `--author`, reading `.env` by any means, push-to-main variants and the "Generated by" attribution are blocked; CI also checks the committer and PR edits; lint tools pinned to exact versions. 62 hook tests.

### Changed
- CHANGELOG is written once per phase by `/close-phase` (full mode only) and the worklog after every change, so the two no longer repeat each other.
- Everything translated to English, including file, folder, command, subagent, skill and hook names (`docs/phases/`, `docs/decisions/`, `RISKS.md`, `ARCHITECTURE.md`, `SECURITY_GUIDE.md`, `WORKLOG.md`, `/status`, `/new-phase`, `/close-phase`, `/prepare-pr`, `guard.sh`, `record-changes`). Stages are now `S0…` and phases `P01…`. CI checks renamed to Secrets, Authorship and Hook.
- Template reduced to Claude and security: `Makefile`, `.vscode/`, `.editorconfig`, `.gitattributes`, `.env.example`, `CONTRIBUTING.md`, CodeQL, Dependabot, CODEOWNERS and the issue and PR templates are removed. CI is down to three jobs: Secrets, Authorship and Hook. How to start and verify each project is written in `docs/SETUP.md` (phase P03).
- Claude template for any kind of development, no longer a website: `index.html`, `css/`, `js/`, GitHub Pages publishing and the `web-perf` skill are removed (still available as a global skill). `make test` and `make lint` detect the stack (npm, Python, Flutter, Go, Rust); `make dev`, `.claude/launch.json`, the CI setup and CodeQL's language are defined in phase P03. Definition of Done, rules and docs free of web assumptions.
- No license: `LICENSE` (MIT) is removed and the README states "all rights reserved". If a project goes public and reuse should be allowed, a license is chosen through an ADR.

### Removed
- Skills `claude-api`, `skill-creator` and `doc-coauthoring` (the first two ship with Claude Code and the account, and a pinned `claude-api` would go stale; `doc-coauthoring` overlapped with the template's own docs method), and `ANTHROPIC_THIRD_PARTY_NOTICES.md`, which no remaining skill needs.
- `docs/claude-settings-global.json`: its content is now a block in `docs/SECURITY_GUIDE.md` → *Global Claude Code settings*, since it is installed once per Mac, not per project.

### Security
- Guardrails extended to `.github/` and the enforcement scripts (deny rules, hook and sandbox `denyWrite`): the agent can no longer weaken the CI or the checks that constrain it.
- Pushes are an allow-list: only `git push [-u] origin development` or a work branch; refspecs (`+HEAD:x`, `HEAD:main`), variables, other remotes and `--config-env` are blocked. Environment dumps from interpreters (`os.environ`, `process.env`) blocked. 107 hook tests, including the bypasses found by the Codex review.
- Docker no longer bypasses the sandbox; `main` requires up-to-date checks and squash merges are disabled.
- GitHub Actions bumped: `actions/checkout` v4.4.0 → v7.0.1 and `gitleaks/gitleaks-action` v2.3.9 → v3.0.0 (Node 20 is gone from GitHub runners; v3 only moves to Node 24). Pinned by SHA.

### Fixed
- Hook and records tests depended on the current branch and on the system temp folder: they failed on `main` and inside the sandbox. They now run in throwaway repos under `$TMPDIR` and stop if `mktemp` fails.
- Dependabot had no cooldown (flagged by the new SAST job): new versions now wait 7 days.
- Guard: read-only commands that only mention `.claude/` (`... 2>/dev/null`, `git grep -- ':!.claude/skills'`) and reading `git config user.email` were blocked. Writes to protected paths are now checked per subcommand only for simple commands; anything with `cd`/`pushd`, loops, `find`/`xargs`, variables or command substitution stays strict. Also covers a bare `.claude` path, `dd of=`, `git checkout/restore --`, `patch`, `tar`, `unzip`, `rsync` and `git config --unset/--add`. 83 hook tests.
- `.claude/settings.json` had `Write(...)` deny rules, which Claude Code ignores (only `Edit(...)` rules apply to file tools); removed.
- `docs/RISKS.md` shipped an example risk marked High/OPEN, so every new project started with an open High risk; it is now a commented example.
- `setup-repo.sh` replaced `PROJECT_NAME` inside the README's "How to use this template" section; it now removes that section on the first run.
- New projects inherited the template's own CHANGELOG and WORKLOG history: `setup-repo.sh` now starts both empty on its first run and records the origin in `.claude/TEMPLATE_VERSION`.
- Claude could not fill in `.claude/launch.json` in phase P03: the deny rules covered all of `.claude/`. They now cover only settings, hooks, agents, commands and skills, matching the hook (new hook test).
- `setup-repo.sh` aborted halfway on private repos with GitHub Free (rulesets refused) and on a second run (duplicate ruleset). It now warns up front, skips existing rulesets, configures everything else and exits with an error if `main` could not be protected.
- `setup-repo.sh` replaced `PROJECT_NAME` inside a third-party skill script (`web-artifacts-builder`); skills and `README.es.md` are now excluded.
- `guard.sh` failed with macOS's bash 3.2 (`mapfile` does not exist and BSD `sed` does not understand `\n`): it exited with code 1, which Claude Code does not treat as a block, so **it blocked no shell command on Mac**. It is now bash 3.2 compatible and the tests pass on macOS.

<!--
Possible sections: Added, Changed, Deprecated, Removed, Fixed, Security
## [1.0.0] - YYYY-MM-DD
-->
