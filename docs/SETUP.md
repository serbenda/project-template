# Local environment

> Filled in during phase P03, after the stack decision. Claude reads it to know how to run and verify the project.

## Requirements
- git and python3 (for the security hook)
- Whatever the project stack needs: <!-- e.g.: Node.js 22, Python 3.13 with uv… -->

## First time
```bash
git clone https://github.com/serbenda/PROJECT_NAME.git
cd PROJECT_NAME
git switch development
git config core.hooksPath .githooks
```

## Daily use
| To | Command |
|---|---|
| Run locally | <!-- e.g.: npm run dev --> |
| Run the tests | <!-- e.g.: pytest --> |

If the project has a local server, also define it in `.claude/launch.json` for the Claude Code preview.

## Verify
Same as CI's Hook job (plus the stack's own job). Must pass before anything is considered done:
```bash
shellcheck --severity=error scripts/*.sh .claude/hooks/*.sh .githooks/*
bash scripts/test-guard.sh           # the Claude guard hook
bash scripts/test-check-records.sh   # the worklog and STATE check
bash scripts/test-githooks.sh        # the git hooks (needs gitleaks)
# + stack tests and lint, e.g.: npm test && npm run lint
```

## Stack checklist (phase P03)
The template ships no stack-specific tooling. Phase P03 is not done until every item below is done or marked "not applicable" with a reason. `/new-phase` copies this list into the P03 acceptance criteria.

- [ ] **Requirements, Daily use and Verify** in this file filled in with real commands, and `Verify` passes locally.
- [ ] **`.claude/launch.json`** defines the local server, if there is one (Claude may edit this file; the rest of `.claude/` is owner-only).
- [ ] **CI job** (owner applies it: `.github/` is protected from the agent; Claude writes the exact job in the phase file and you paste it) in `.github/workflows/ci.yml` running the same tests and lint as `Verify`, with actions pinned to a full commit SHA and `permissions: contents: read`.
- [ ] **Dependabot** (owner applies it, same as the CI job): add the stack's ecosystem (`npm`, `pip`, `gomod`, `cargo`, `pub`…) to `.github/dependabot.yml`, next to the `github-actions` entry the template already has.
- [ ] **Static analysis**: Semgrep already runs on every repo (the SAST job). Optionally, a CodeQL workflow for the project's language if the repo is public (code scanning is free only on public repos).
- [ ] **`.gitignore`** extended with the stack's build output, caches and virtual environments.
- [ ] **Environment variables** documented in the section below; real values only in `.env`.
- [ ] **Definition of Done**: delete the project-type blocks in `docs/DEFINITION_OF_DONE.md` that don't apply.
- [ ] **Owner:** add the new CI job's name to the required checks of the "Protect main" ruleset (GitHub → Settings → Rules). The agent can't do this: the hook blocks ruleset changes.

## Environment variables
Real values go in `.env`, which is never committed. Document each variable here: what it is for and where to get it, never its value.
