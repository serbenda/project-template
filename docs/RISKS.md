# Risk register

> The bar for release is not "everything is coded" but "no High risks open".
> States: `OPEN` → `MITIGATED` (fixed and covered by tests) → `CLOSED` (validated in the real world).

| ID | Risk | Impact | Probability | State | Mitigation | Phase |
|---|---|---|---|---|---|---|
| R-001 | <!-- e.g.: personal data leaks into the logs --> | High | Medium | OPEN | <!-- what is or will be done --> | |

## How to use it
- Any phase that touches data, authentication, dependencies or deployment reviews this table.
- A `MITIGATED` risk needs a test or check that proves it, linked in *Mitigation*.
- Security risks are cross-checked with the `security-audit` skill (see [SECURITY_GUIDE.md](SECURITY_GUIDE.md)).
