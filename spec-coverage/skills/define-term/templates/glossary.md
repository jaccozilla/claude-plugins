<!--
Template for a project's product/UI glossary. Replace the example entries
and delete this comment block before writing the file.

- This file is for product and UI language only — the nouns, verbs, and
  labels a user sees. Never code identifiers (class, function, table
  names); those follow the code's own conventions.
- Keep it OUTSIDE the project's specsDir — every .md under specsDir is
  treated as a spec by verifySpecCoverage and would demand a test.
- Every `## ` heading is one term; the heading is the canonical form. Keep
  headings sorted alphabetically so collisions are easy to spot.
- `Status: proposed` marks an open decision (several wordings in use today)
  and is not enforced; drop the field (or write `settled`) once confirmed.
- `Allow:` lists phrases exempt from that entry's `Avoid` check.
-->
# Glossary

Canonical product/UI terms. Specs, UI strings, and docs use these forms and
avoid the listed synonyms.

## Delete

- **Type:** verb
- **Definition:** Permanently removes something. Not recoverable.
- **Avoid:** Remove, Trash, Erase
- **UI label:** Delete
- **Status:** proposed
- **Notes:** The app currently says "Remove" on some screens. Use "Archive" for the reversible version.

## Workspace

- **Type:** noun
- **Definition:** The top-level container a group of users shares.
- **Avoid:** Project, Org, Team
- **Allow:** project plan
- **UI label:** Workspace
- **Notes:** Distinct from a Profile (one person's account details) — a workspace holds many.
