# CLAUDE.md

This repository's rules live in AGENTS.md and apply to any agent. They are imported here:

@AGENTS.md

## Specific to Claude Code

- **Project configuration:** `.claude/settings.json` disables attribution in commits and PRs, defines permissions (deny / ask / allow) and enables the `.claude/hooks/guard.sh` hook. Do not modify them: changes are made by the owner.
- **Skills:** `.claude/skills/` (`security-audit`, `repo-security-posture`, the 19 Anthropic skills and our own `record-changes`, which maintains CHANGELOG and `docs/WORKLOG.md` after every change). Global skills in `~/.claude/skills` are also available. They are pinned to a commit; see `.claude/skills/UPSTREAM.md`.
- **Subagents:** `security-reviewer`, `dod-reviewer` and `architecture-reviewer` in `.claude/agents/`. Run them before opening a PR. They are read-only.
- **Commands** (`.claude/commands/`):
  - `/status`: at the start of every session. Summarizes STATE and says what's next.
  - `/new-phase <what>`: creates the phase file and proposes the plan. Writes no code until it is approved.
  - `/close-phase`: checks criteria and DoD, fills in the result and updates STATE, ROADMAP and CHANGELOG.
  - `/decision <what>`: records an ADR in `docs/decisions/`.
  - `/prepare-pr`: verification, reviewers and a `development → main` PR without attribution.
- **Preview:** `.claude/launch.json` is empty. If the project has a local server, it is added in phase P03.
- For tasks spanning more than one phase or with design doubts, use plan mode before touching code.
- If a hook blocks an action, **do not try to work around it** with another command: explain to the owner what you were trying to do and why.
