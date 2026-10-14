---
name: rename-term
description: Rename a product/UI term across a project — update its glossary entry and every spec, UI string, and doc that uses it — after showing the planned edits for approval. Use when the user renames a product concept or standardizes on one word ("call Projects Workspaces everywhere", "use Delete instead of Remove"), or after glossary-check finds many uses of an avoided synonym.
---

# Rename a glossary term everywhere

Renames a product/UI term consistently across the glossary, specs, UI
strings, and docs. The glossary covers product language only, so this skill
**never renames code identifiers** (classes, functions, DB columns, test
function names). A blind find-and-replace would hit those and ordinary
words, which is why this skill plans first and edits second. Related:
[[define-term]] (glossary format and entry upkeep), [[glossary-check]]
(finds the usages), [[new-spec]].

## Discovery

1. Find the glossary and `specsDir` the same way [[glossary-check]] does.
2. Identify the surfaces to update, confirming scope with the user if
   unclear: spec files; the glossary; UI string resources / string literals
   in UI code; docs (README, `docs/`); and any specs listing the term in
   `terms:` front matter.
3. Note which specs reference the term via `terms:` — those are the
   certain dependents. Body mentions of the term (or of the old word) in
   other specs are the likely ones; the grep in Step 2 finds both.

## Step 1: Pin down the change

Establish exactly: the old term(s), the new term, and whether the old terms
become `Avoid` entries on the new one (usually yes) or the entry is being
removed outright. **Several old wordings can fold into one new term** (the
usual case when settling a `Status: proposed` entry — e.g. `Login`, `Log in`
and `Log In` all becoming `Sign in`): take the list, not a single old term,
and run every step below for each. If the entry being applied is still
`proposed`, confirm the user wants to settle it first, and remove its
`Status: proposed` line once the rename lands. If the new term collides with an existing entry or sits in
another entry's `Avoid` list, stop and resolve that with the user first
(see [[define-term]] collision rules).

## Step 2: Build the edit plan (no writes yet)

Search the scope for the old term (case-insensitive, whole word, plus
plural/inflected forms), and sort every hit into:

- **Rename** — a product-language use of the term. Include grammatical
  fixes the swap forces (a/an agreement, plural, capitalization).
- **Leave alone** — code identifiers, inline `` `code` `` spans, file
  paths, URLs, test function names, and ordinary-English uses of the word
  unrelated to the concept (e.g. "project" meaning a build project).
  Anything on a line marked `glossary-ok`.
- **Needs a decision** — ambiguous hits, or a spec bullet quoting the old
  term as part of a test reference.

Present the plan as a table or per-file list: `file:line` with before →
after for every Rename, **counts per old wording** (`Login: 4 renames, Log
in: 5 renames`), a count for Leave alone, and each Needs-a-decision
item with a question. Also surface test impact: UI-test code that asserts
on an on-screen string (e.g. `onNodeWithText("Delete")`) will break when
the string changes. List those as required companion edits — they must move
with the UI string or the suite fails.

## Step 3: Get approval, then apply

Wait for the user's go-ahead on the plan (they may strike items). Then
apply: update the glossary entry (heading, definition, `Avoid`, `UI
label`; keep headings alphabetized), then the specs, UI strings, tests that
assert on changed strings, and docs.

A renamed spec bullet that has an inline test reference
(`` (`File.kt`: `test name`) ``) keeps its reference unchanged — test
function names are identifiers and aren't renamed. If a spec file itself is
being renamed because its filename contains the old term, that changes its
`@Spec` id; list it in the plan as its own item and update every `@Spec`
referencing it and every inline path reference, then rerun
`verifySpecCoverage`.

## Step 4: Verify

- Re-run the [[glossary-check]] search for the old term: remaining hits
  should be exactly the Leave-alone set.
- Run the project's `verifySpecCoverage` task.
- Run the tests that were touched, and the project's normal test task if UI
  strings changed — confirm they pass rather than assuming.

## Report

State what was renamed (counts by surface), what was deliberately left
alone and why, any Needs-a-decision items still open, and the verification
results with the actual pass/fail output. Don't commit anything yourself
unless asked.
