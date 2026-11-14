# Threat model

> What we protect, from whom, where the attacks come in and what stops them. It is written **before the first
> code** that handles user input, accounts, personal data, money or anything reachable from the network, and
> reviewed in every phase that touches one of those. `security-reviewer` checks each change against it.
> Keep it short and concrete: a threat without a control is a risk and also goes in [RISKS.md](RISKS.md).

Last reviewed: YYYY-MM-DD

## What we protect (assets)
<!-- The things whose loss or leak would hurt: user accounts and passwords, personal data, payment data,
     API keys, the database, availability of the service, the owner's reputation… Mark the sensitive ones. -->
| Asset | Why it matters | Sensitive? |
|---|---|---|
| | | |

## Who could attack (actors)
<!-- Anonymous internet user, a logged-in user going after other users' data, a malicious dependency,
     a compromised CI or AI agent (prompt injection through issues, web pages or files)… -->
-

## Where attacks come in (entry points and trust boundaries)
<!-- Everything that receives data from outside: HTTP endpoints, forms, file uploads, webhooks, CLI arguments,
     environment variables, messages from queues, third-party APIs, content the AI agent reads. -->
| Entry point | Who can reach it | Data it receives | Authenticated? |
|---|---|---|---|
| | | | |

## Threats and controls
<!-- One row per realistic threat. Think STRIDE: Spoofing (pretending to be someone), Tampering (changing data),
     Repudiation (denying an action), Information disclosure (leaks), Denial of service, Elevation of privilege.
     Every control should be checkable: a test, a CI job, a setting. -->
| Threat | Entry point | Control | How it is checked |
|---|---|---|---|
| Injection (SQL, shell, path, template) | | Parameterised queries / no shell with user input | SAST job + tests |
| Broken access control (user A reads B's data) | | Authorisation on every request, server side | Tests per endpoint |
| Leaked secrets | | Secrets only in env / secret store | Gitleaks pre-commit + CI |
| Vulnerable dependency | | Lockfiles, Dependabot with cooldown | Dependencies job |
| | | | |

## Out of scope
<!-- What we consciously don't defend against yet, and why. Revisit before each release. -->
-
