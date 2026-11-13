---
description: Goes through the Definition of Done, runs the reviewers and opens the development → main PR without AI signatures.
---

1. Check that you are on `development` and there are no uncommitted changes (`git status`).
2. Run the *Verify* commands in `docs/SETUP.md`. If anything fails, **stop** and show me the error.
3. Launch the `dod-reviewer`, `security-reviewer` and `architecture-reviewer` subagents in parallel.
4. If any returns Critical or High findings, or the verdict is MISSING or REVIEW: **stop**, show me the summary and do not open the PR.
5. If all is well, draft the PR text: what changes, a link to the phase file, how it was tested and the DoD checked off (anything not applicable, with its reason). **No** "Generated with" lines, no session links and no AI tool signatures.
6. Show me the title and text, and open the PR (`development` → `main`) once I confirm.
7. Never merge the PR: I merge it.

$ARGUMENTS
