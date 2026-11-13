# Worklog

> The **context** of each change: what, why, what was rejected, commits, how it was tested and what is pending.
> Maintained by the agent with the `record-changes` skill. New entries **on top**.
> What is visible to users of the project also goes in [CHANGELOG.md](../CHANGELOG.md); the current status, in [STATE.md](STATE.md).

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
