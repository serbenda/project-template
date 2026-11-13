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
Same as CI. Must pass before anything is considered done:
```bash
bash scripts/test-guard.sh   # security hook
# + stack tests and lint, e.g.: npm test && npm run lint
```

## Stack checklist (phase P03)
The template ships no stack-specific tooling. Phase P03 is not done until every item below is done or marked "not applicable" with a reason. `/new-phase` copies this list into the P03 acceptance criteria.

- [ ] **Requirements, Daily use and Verify** in this file filled in with real commands, and `Verify` passes locally.
- [ ] **`.claude/launch.json`** defines the local server, if there is one (Claude may edit this file; the rest of `.claude/` is owner-only).
- [ ] **CI job** in `.github/workflows/ci.yml` running the same tests and lint as `Verify`, with actions pinned to a full commit SHA and `permissions: contents: read`.
- [ ] **Dependabot** in `.github/dependabot.yml`: the `github-actions` ecosystem plus the stack's (`npm`, `pip`, `gomod`, `cargo`, `pub`…), `target-branch: development`, weekly.
- [ ] **Static analysis**: a CodeQL workflow for the project's language if the repo is public (code scanning is free only on public repos); if it is private, a Semgrep step in the CI job instead.
- [ ] **`.gitignore`** extended with the stack's build output, caches and virtual environments.
- [ ] **Environment variables** documented in the section below; real values only in `.env`.
- [ ] **Definition of Done**: delete the project-type blocks in `docs/DEFINITION_OF_DONE.md` that don't apply.
- [ ] **Owner:** add the new CI job's name to the required checks of the "Protect main" ruleset (GitHub → Settings → Rules). The agent can't do this: the hook blocks ruleset changes.

## Environment variables
Real values go in `.env`, which is never committed. Document each variable here: what it is for and where to get it, never its value.
