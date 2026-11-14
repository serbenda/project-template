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
