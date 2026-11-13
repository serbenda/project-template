---
description: Closes the current phase. Checks acceptance criteria and the Definition of Done, fills in the result and updates STATE, ROADMAP and CHANGELOG.
argument-hint: "[PNN]"
---

Phase to close: $ARGUMENTS (if empty, the "Current phase" in `docs/STATE.md`).

**Light mode:** run the *Verify* commands, check the plan under *Current work* in STATE is met, move it to *Recently done*, update *Next*, make sure WORKLOG has its entries, and commit `docs: close <short title>`. Skip the steps below.

**Full mode:**

1. Read the phase file and `docs/DEFINITION_OF_DONE.md`.
2. Run the *Verify* commands in `docs/SETUP.md`. If anything fails, **stop** and show me the error.
3. Go through each acceptance criterion: ✅ met (with the evidence: test, command or manual step) or ❌ not met. If there is any ❌, **stop**: the phase is not closed.
4. Launch the `dod-reviewer` subagent. If its verdict is MISSING, stop and show me what is missing.
5. Fill in the phase file's **Result** section: what was done, how it was tested, what was left out and why, and lessons learned. Status ✅ and end date.
6. Update:
   - `docs/STATE.md`: "Recently done" (at most 5 entries; drop the oldest), "Next", blockers and risks. Keep it under 150 lines.
   - `docs/ROADMAP.md` and `docs/phases/README.md`: the phase status (and the stage's, if its exit criterion is met).
   - `CHANGELOG.md`: one line per user-visible change of the whole phase, under *Unreleased* (this is the only moment CHANGELOG is written). Write it from the phase's *Result*, not by copying WORKLOG.
   - `docs/WORKLOG.md`: with the `record-changes` skill, an entry that closes the phase and cites its commits.
   - `docs/RISKS.md`: mitigated or new risks.
   - `docs/ARCHITECTURE.md`: only if a component or flow has changed.
7. If "Lessons learned" changes how work is done in this repo, propose the change to `AGENTS.md` (do not apply it without my approval).
8. Make a `docs: close PNN` commit with those changes and tell me whether it is time for `/prepare-pr`.
