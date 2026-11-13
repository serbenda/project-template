---
name: record-changes
description: Records every repo change in CHANGELOG.md and docs/WORKLOG.md (what was done, why, files, commits, how it was tested and what is pending). Use it ALWAYS after finishing any change (code, configuration, CI, documentation) and before committing, even if nobody asks for it. Also when the owner asks what changed, when or why.
---

# Recording changes

You remember nothing between sessions. Whatever is not written down here is lost. There are two records with different purposes:

| File | For whom | What it holds |
|---|---|---|
| `CHANGELOG.md` | Whoever uses the project | **Visible** changes, one line each, [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format |
| `docs/WORKLOG.md` | The owner and the next agent | The **context** of each change: why, alternatives, files, commits, tests, pending |

`docs/STATE.md` is something else: the current state in ≤150 lines. Do not copy the worklog into STATE; at most, link the entry.

## When

- When a change is finished, **before the commit**, so the record and the change go in the same commit.
- If the change took several commits, a single entry at the end citing all of them.
- Do not record intermediate steps or discarded attempts as entries of their own: they go inside the entry, under *Rejected*.

## 1. CHANGELOG.md

Only if something changes that the project's users notice (functionality, configuration, behaviour, security, dependencies). An internal refactor or a typo fix does **not** go in.

- `## [Unreleased]` section, in the matching subsection, in this order: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- One line per change, in English, in the past tense or as a fact: "Province filter on the map", not "I have added…".
- If there is a phase file or ADR, link it.
- Do not rewrite entries of already released versions.

## 2. docs/WORKLOG.md

**Always**, also for internal changes. New entry **at the top** (reverse chronological order), in this format:

```markdown
## YYYY-MM-DD — Short title of the change
- **Phase / issue:** P03 · #12 (or "—")
- **What:** what changes, in 1-3 sentences.
- **Why:** the reason or the problem it solves. This is the most important part: the what shows in the diff, the why does not.
- **Rejected:** alternatives that were considered and why not (if any).
- **Files:** the main ones, with path.
- **Commits:** `abc1234` (fill it in after the commit with a `docs: worklog` commit if needed, or in the next entry).
- **Tested:** command or steps that show it works.
- **Pending:** what is left open, or "nothing".
```

Rules:
- Today's real date (`date +%F`), never made up.
- Verifiable facts: if you have not tested it, write "untested", not "works".
- No secrets, tokens, passwords or personal data, even if they appear in the change.
- Do not edit old entries except to correct a wrong fact; in that case, add "(corrected YYYY-MM-DD)".
- If a decision is hard to undo, the entry links the ADR in `docs/decisions/` instead of repeating the reasoning.

## 3. Final check

Before the commit, go over:
- [ ] Is there an entry in `docs/WORKLOG.md` with *Why* and *Tested*?
- [ ] Is the change visible? Then it has a line in `CHANGELOG.md`.
- [ ] Has the state or the next step changed? Then update `docs/STATE.md`.
