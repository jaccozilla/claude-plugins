---
name: define-roles
description: Create or update a project's roles document (who can use the product, how a person gets each role, what each can and cannot do, how roles relate), one section per role with the same headings. Use when the project has no roles document and work needs one, when the user asks to document, list, add, remove, rename or change a role or a relationship between roles (a new kind of user, a changed permission, a new "related to" rule), or when a spec, plan or migration is about to change who can see or do something and the roles document may be out of date.
---

# Define and maintain roles

A project's roles document is the one authoritative answer to "who can use
this and what can each do". Specs, plans ([[plan-work]]), security reviews and
the glossary ([[define-term]]) all start from it, so it must stay current. This
skill creates it and keeps it true when roles change. It describes roles in
product terms; the code, schema and policies are where roles are *enforced*,
and the document points at them rather than copying them.

## Find the document

Don't hardcode a path. Check, in order:

1. The project's agent-instructions file (`CLAUDE.md` or similar) for a
   roles document it names.
2. `docs/roles.md`, then similar names (`docs/personas.md`, `docs/users.md`,
   `docs/permissions.md`).

If there is none, you are creating it: default to `docs/roles.md`, and add a
line about it to the agent-instructions file's docs list so later work finds
it.

## Format

One section per role, all with the same headings, from
`templates/roles.md`: **Overview**, **How a person has it**, **What they can
do**, **What they cannot do**, **Relationships**. After the roles, a shared
**Where roles are enforced** section and a **Keeping this current** note.
Order roles the way a person meets them: the signed-out visitor first (if the
product allows signed-out use), the default signed-in role, then added roles.
State at the top whether roles are exclusive or additive and what every
account is by default. Link to the specs and ADRs that define each capability
instead of restating them.

## Creating it

1. Survey, and cite where each fact came from: the agent-instructions file
   and product overview; ADRs and docs about roles, permissions,
   authentication and anonymous access; the glossary's nouns for people; the
   specs' "only reachable by" statements; and the code that actually
   distinguishes people (role columns, policy names and helper functions,
   route guards).
2. List the roles you found, whether they are exclusive or additive, and the
   relationships that matter (for example a coach being related to a student
   through a booking). Show the user this list *before* drafting prose, and
   ask about anything the sources disagree on or leave out. Batch the
   questions.
3. Draft every section from the template, with real links. Leave nothing as a
   placeholder; if a fact is unknown, ask rather than guess.
4. Check each "What they can do" and "cannot do" claim against a spec, ADR or
   policy. A claim you cannot back up comes out or becomes a question.
5. Add the pointer to the agent-instructions file. Don't commit unless asked.

## Updating it

Run this whenever a role, a relationship between roles, or what a role can
do is added, removed or changed, including when another skill or task is
about to do that (a plan that introduces a kind of user; a migration that
changes who may read a table).

1. Say what is changing and which sections it touches: a new role (a new
   section), a removed role (delete the section and every reference), a
   renamed role, a changed capability or limit, a new or ended relationship.
2. Make the edit in the roles document in the same change as the work that
   causes it, never later.
3. Propagate. Search for the role's name and the changed capability in:
   - the glossary ([[define-term]], [[rename-term]] for a rename), including
     its definition and avoided words;
   - specs: page and workflow specs carry a `roles:` front matter line
     naming the roles they are valid for (the role headings of this
     document, or `any`). A rename updates every such line; a removal drops
     the role from each and re-checks whether the page or flow is still valid
     for anyone; a new role means reading every page and workflow spec to see
     which it applies to; a changed capability means re-checking the specs
     that depend on it. Also update "only reachable by" lines, role-specific
     bullets and their tests ([[update-spec]], [[reconcile-e2e-specs]]);
   - ADRs: a decision about roles or access that the change overturns needs
     a new or superseding ADR, which the user must confirm first if the
     project requires it;
   - the product overview and the agent-instructions file;
   - policies, role helper functions and seeds the change relies on.
   Report each place you updated and each you left for the user.
4. Re-check the "Where roles are enforced" section still matches the code.
5. For a removal, say what happens to existing people who held the role.

## Checking it

When asked to verify the document, or when you notice drift, compare it with
the code: every role column, role helper and role-specific policy should map
to a section, and every section's "How a person has it" should name something
real. Also check the specs: every page and workflow spec has `roles:`, each
value is a role heading in this document (or `any`), and a page that a role
can reach in the code is listed for that role. Report mismatches; fix the document when the code is right and ask the
user when the document describes intended behavior the code lacks.
