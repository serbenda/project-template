# Definition of Done (DoD)

A change is **done** only when it meets everything on this list. If something does not apply, say so in the PR with the reason.

## 1. Code
- [ ] Does what the issue and the phase file ask for, and nothing more (no unrequested side changes).
- [ ] Meets the acceptance criteria in the phase file.
- [ ] Readable: clear names, no dead code, no debug output (`print`, `console.log`…).
- [ ] Follows the project style (`docs/ARCHITECTURE.md` → Code conventions).
- [ ] No unnecessary new dependencies; any new ones are justified in the PR.

## 2. Tests
- [ ] Tested locally (see `docs/SETUP.md`) against the acceptance criteria.
- [ ] Automated tests added or updated for what changes.
- [ ] The *Verify* commands in `docs/SETUP.md` pass locally and CI is green.

## 3. Security
- [ ] No secrets, tokens, keys or personal data in the code or in the history.
- [ ] User input and external data are treated as untrusted and validated before reaching queries, commands, paths or HTML.
- [ ] Calls to external APIs use HTTPS and their failures are handled (timeouts, clear message, no crash).
- [ ] Secret scanning reports nothing new.
- [ ] If the change touches authentication, external data, workflows or dependencies: reviewed with the `security-audit` skill (guidance mode).
- [ ] Before each major release: full audit with `security-audit`, with no open `confirmed` findings.
- [ ] Before each major release: `repo-security-posture` with no Critical or High findings.

## 4. By project type (delete what does not apply)
**Web or mobile UI**
- [ ] Accessible: alt text, sufficient contrast, keyboard navigable.
- [ ] Tested on desktop and mobile, no console errors.
- [ ] External data via `textContent`, never `innerHTML`.

**API or backend**
- [ ] Every endpoint validates input and checks authorization.
- [ ] Errors don't leak internal details; logs contain no secrets or personal data.
- [ ] Database migrations are reversible or have a rollback plan.

**CLI or library**
- [ ] `--help` and README reflect the change; consistent exit codes.

## 5. Documentation
- [ ] README updated if usage, configuration or data sources change.
- [ ] Entry in `docs/WORKLOG.md` (what, why, commits, how it was tested) and, if the change is visible, in `CHANGELOG.md` → *Unreleased*.
- [ ] Phase file with *Result* filled in and `docs/STATE.md` updated (`/close-phase`).
- [ ] If a hard-to-reverse decision was made, it has its ADR in `docs/decisions/`.
- [ ] Public data sources used are cited with their license.

## 6. Integration
- [ ] Work on `development` (or a branch off it), never directly on `main`.
- [ ] Commits follow Conventional Commits with the correct author.
- [ ] PR from `development` → `main` with the template filled in and reviewed.
- [ ] After the merge, what is deployed (if anything) works.
- [ ] Issue closed and card moved to *Done* in GitHub Projects.
