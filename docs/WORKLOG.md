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
