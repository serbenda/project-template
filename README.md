# PROJECT_NAME

> One sentence explaining what it is and who it is for.

🇪🇸 Guía de la plantilla en castellano: [README.es.md](README.es.md)

## What it does
- Main feature 1
- Main feature 2

## Data sources
| Source | What it provides | License |
|---|---|---|
| _E.g.: OpenStreetMap_ | _Map data_ | _ODbL, attribution required_ |

## Running locally
```bash
git clone https://github.com/serbenda/PROJECT_NAME.git
cd PROJECT_NAME
git switch development
```
How to start and verify it: [docs/SETUP.md](docs/SETUP.md).

## Structure
```
.
├── docs/
│   ├── VISION.md        # what it is, who it is for and what NOT to do
│   ├── STATE.md         # living state (≤150 lines): the first thing the agent reads
│   ├── WORKLOG.md       # context of every change: what, why, commits, pending
│   ├── ROADMAP.md       # stages S0… with exit criteria
│   ├── phases/          # one phase file per block of work (P01…)
│   ├── decisions/       # numbered ADRs
│   ├── ARCHITECTURE.md  # components, data flow, external sources
│   ├── RISKS.md         # risk register
│   ├── SETUP.md         # start and verify (filled in in phase P03)
│   ├── DEFINITION_OF_DONE.md
│   └── SECURITY_GUIDE.md
├── scripts/       # setup-repo.sh (configures GitHub) and hook tests
├── .claude/       # permissions, hook, skills, subagents, commands and launch.json
├── .github/       # CI: secrets, authorship and hook tests
├── .githooks/     # git hook: strips AI attribution and checks the author
├── CHANGELOG.md   # visible changes, Keep a Changelog format
├── README.es.md   # Spanish guide to the template: every file and skill explained
├── AGENTS.md      # rules for any AI agent
└── CLAUDE.md      # imports AGENTS.md and adds what is specific to Claude Code
```

## How to work with Claude

```
/status                      at the start of every session
/new-phase <what>            phase file + plan → you approve → Claude implements on development
(automatic)                  record-changes skill: WORKLOG after every change
/close-phase                 criteria + DoD + updates STATE, ROADMAP and CHANGELOG (once per phase)
/prepare-pr                  reviewers + development → main PR (you merge it)
/decision <what>             when something hard to undo has to be chosen
```

## Contributing
Read [AGENTS.md](AGENTS.md) and the [Definition of Done](docs/DEFINITION_OF_DONE.md).

## License
No license: © Sergio Santiago Bendaña Quesada. All rights reserved.
The code may be viewed, but not copied, modified or redistributed without the author's written permission.

---

<details>
<summary>📦 How to use this template (delete this section in the new project)</summary>

1. On GitHub: **Use this template → Create a new repository**.
2. Clone the new repo and run:
   ```bash
   ./scripts/setup-repo.sh
   ```
   It creates the `development` branch, protects `main` and enables security alerts and the git hook.
   With signed commits: `SIGNED_COMMITS=1 ./scripts/setup-repo.sh`. For an experiment or small tool: `MODE=light ./scripts/setup-repo.sh` (see `AGENTS.md` → Project mode).
3. Replace `PROJECT_NAME` in this README (the script already replaces it everywhere else).
4. Write [docs/VISION.md](docs/VISION.md) (or dictate it to Claude and review it).
5. With Claude: `/decision project stack`, then `/new-phase` for the first phase of Stage S0.
6. In phase P03, Claude works through the *Stack checklist* in `docs/SETUP.md`: run and verify commands, `.claude/launch.json`, CI job, Dependabot, static analysis and `.gitignore`.
7. Delete this section.
8. Once on your Mac: follow [docs/SECURITY_GUIDE.md](docs/SECURITY_GUIDE.md) → "What you have to do yourself".

</details>
