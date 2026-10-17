# Roles

The one list of who can use <the product> and what each can do, so specs, plans and security reviews start from the same people.
<Say whether roles are exclusive or additive, and what the default role of every account is.> Detail lives in the ADRs, specs and the
product overview; this file names each role and how it differs.

<One section per role, in the order a person meets them: signed-out visitor first, then the default signed-in role, then the added
roles. Keep every section to these same headings so they can be compared.>

## <Role name>

### Overview

<Who this is and what they come to do, in two or three sentences.>

### How a person has it

<How the role is granted or revoked: automatic, self-service, approved by someone, or set by an operator. Name the column, table or
check that records it.>

### What they can do

- <Capability, linking the spec or ADR that defines it.>

### What they cannot do

- <Limits that matter: what is hidden from them, and what they see instead of a denied thing.>

### Relationships

<How this role relates to other roles and to other people's data: for example "related to a student through a booking". Say who
creates the relationship and who can end it.>

## Where roles are enforced

<The real authorization boundary (row level security, server checks) and the helper functions or policies that implement it. A check
in the UI is a convenience, never the protection.>

## Keeping this current

Change this file in the same change that adds or alters a role, a relationship between roles, or what a role can do. A planned new
role or relationship is a decision to make in a plan before it appears here.
