# Security and privacy review

Pass run: <date>. Read: <plan files, the roles document, the product review, the project's security and access ADRs, the policies and code the plan touches>.

## Who can see or change what

| Data or action | Role | Allowed? | Enforced by (policy, server check; not the UI) |
|---|---|---|---|
| <...> | <role> | <yes / no / only if related> | <...> |

## Personal data

<What personal data the plan stores, shows or moves; who sees it; whether it is cached, logged or sent elsewhere.>

## Abuse and misuse

<How someone could misuse each new capability: guessing identifiers, replaying requests, sharing with a stranger, reading what was
shared with someone else, scraping. What stops it.>

## Findings

- **[blocking | should-fix | note]** <Finding.> Decision: <...>.

## Result

<Is the authorization boundary sound? Which questions did this pass add?>
