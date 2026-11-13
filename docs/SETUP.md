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

## Environment variables
Real values go in `.env`, which is never committed. Document each variable here: what it is for and where to get it, never its value.
