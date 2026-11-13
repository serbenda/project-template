# Risk register

> The bar for release is not "everything is coded" but "no High risks open".
> States: `OPEN` → `MITIGATED` (fixed and covered by tests) → `CLOSED` (validated in the real world).

| ID | Risk | Impact | Probability | State | Mitigation | Phase |
|---|---|---|---|---|---|---|
<!-- Example row (copy it, don't leave it as is):
| R-001 | Personal data leaks into the logs | High | Medium | OPEN | Redact emails in the logger; test in tests/test_logging.py | P04 |
-->

## How to use it
- Any phase that touches data, authentication, dependencies or deployment reviews this table.
- A `MITIGATED` risk needs a test or check that proves it, linked in *Mitigation*.
- Security risks are cross-checked with the `security-audit` skill (see [SECURITY_GUIDE.md](SECURITY_GUIDE.md)).
