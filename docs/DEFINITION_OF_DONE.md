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
- [ ] `docs/THREAT_MODEL.md` exists before the first code that handles input, accounts, personal data, money or network exposure, and is updated if this change adds an entry point, an asset or a threat.
- [ ] No secrets, tokens, keys or personal data in the code or in the history; real values only in `.env` or a secret store.
- [ ] User input and external data are treated as untrusted and validated (type, length, format, allow-lists) before reaching queries, commands, paths, templates or HTML.
- [ ] Queries are parameterised; no shell command or `eval` is built from user input.
- [ ] Every request that reads or changes data checks **authorisation on the server**, for that user and that object (not only "is logged in").
- [ ] Passwords hashed with a modern algorithm (argon2id, scrypt or bcrypt), never stored or logged in clear; sessions and tokens expire and are revocable.
- [ ] Calls to external APIs use HTTPS, have timeouts and handle failures without crashing or leaking details.
- [ ] Errors shown to users reveal nothing internal; logs contain no secrets, tokens or personal data.
- [ ] New dependencies are justified, come from the official registry and are pinned in a lockfile.
- [ ] CI is green, including **SAST** (Semgrep) and **Dependencies** (OSV-Scanner); a silenced finding has a `nosemgrep` comment with its reason.
- [ ] Secret scanning reports nothing new.
- [ ] If the change touches authentication, external data, workflows or dependencies: reviewed with the `security-audit` skill (guidance mode).
- [ ] Before each major release: full audit with `security-audit`, with no open `confirmed` findings.
- [ ] Before each major release: `repo-security-posture` with no Critical or High findings.

## 4. By project type (delete what does not apply)
**Web or mobile UI**
- [ ] Accessible: alt text, sufficient contrast, keyboard navigable.
- [ ] Tested on desktop and mobile, no console errors.
- [ ] External data via `textContent` (or the framework's escaping), never `innerHTML` / `dangerouslySetInnerHTML` with untrusted data.
- [ ] Security headers: a strict `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, and `frame-ancestors` or `X-Frame-Options`.
- [ ] Cookies with `Secure`, `HttpOnly` and `SameSite`; state-changing requests protected against CSRF.
- [ ] No secrets in the frontend bundle: only public keys meant to be public (and, with Supabase or similar, RLS on every table).

**API or backend**
- [ ] Every endpoint validates input and checks authorisation; deny by default.
- [ ] Rate limiting on login, sign-up, password reset and any expensive endpoint.
- [ ] CORS limited to the known origins; no `*` with credentials.
- [ ] Uploads: size and type limits, stored outside the web root, never executed.
- [ ] The database user has only the permissions it needs; no admin credentials in the app.
- [ ] Errors don't leak internal details; logs contain no secrets or personal data.
- [ ] Database migrations are reversible or have a rollback plan; backups exist and a restore has been tested before release.

**CLI or library**
- [ ] `--help` and README reflect the change; consistent exit codes.

## 5. Documentation
- [ ] README updated if usage, configuration or data sources change.
- [ ] Entry in `docs/WORKLOG.md` (why, what was rejected, how it was tested, pending).
- [ ] `docs/STATE.md` updated (`/close-phase`). Full mode: phase file with *Result* filled in and the phase's user-visible changes in `CHANGELOG.md` → *Unreleased*.
- [ ] If a hard-to-reverse decision was made, it has its ADR in `docs/decisions/` (light mode: only irreversible ones).
- [ ] Public data sources used are cited with their license.

## 6. Integration
- [ ] Work on `development` (or a branch off it), never directly on `main`.
- [ ] Commits follow Conventional Commits with the correct author.
- [ ] PR from `development` → `main` with the template filled in and reviewed.
- [ ] After the merge, what is deployed (if anything) works.
- [ ] Issue closed and card moved to *Done* in GitHub Projects.
