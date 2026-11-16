# PROJECT_NAME

> One sentence explaining what it is and who it is for.

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
│   ├── THREAT_MODEL.md  # what we protect, from whom, entry points and controls
│   ├── RISKS.md         # risk register
│   ├── SETUP.md         # start and verify (filled in in phase P03)
│   ├── WORKFLOWS.md     # every way of working with this repo, as diagrams
│   ├── DEFINITION_OF_DONE.md
│   └── SECURITY_GUIDE.md
├── scripts/       # setup-repo.sh, sync-from-template.sh, check-records.sh and tests
├── .claude/       # permissions, hook, skills, subagents, commands and launch.json
├── .github/       # CI: secrets, authorship and hook tests
├── .githooks/     # git hooks: secrets scan before commit, AI attribution and author check
├── CHANGELOG.md   # visible changes, Keep a Changelog format
├── README.es.md   # Spanish guide to the template: every file and skill explained
├── AGENTS.md      # rules for any AI agent
└── CLAUDE.md      # imports AGENTS.md and adds what is specific to Claude Code
```

## How to work with Claude
Every flow, as diagrams: [docs/WORKFLOWS.md](docs/WORKFLOWS.md).

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
No license: © OWNER_NAME. All rights reserved.
The code may be viewed, but not copied, modified or redistributed without the author's written permission.
