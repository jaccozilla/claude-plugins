---
name: define-term
description: Add or update an entry in a project's product/UI glossary (the canonical nouns, verbs, and labels specs and UI strings must use consistently), checking for collisions with existing terms first. Use when the user introduces, names, or renames a product concept ("call this a Workspace", "add 'Archive' to the glossary"), when a new spec coins a term that isn't listed, or when asked to set up or bootstrap a glossary for a project (including surveying existing specs and strings for inconsistent wording).
---

# Define a glossary term

A project's glossary is one markdown file of canonical product/UI language —
the nouns, verbs, and on-screen labels that specs, UI strings, and docs
must use consistently. It is **not** for code identifiers. This skill is
the intake path: it adds or amends entries without creating duplicates or
near-synonyms. [[glossary-check]] audits usage against the glossary,
[[rename-term]] propagates a rename, and [[new-spec]] reads the glossary
before drafting.

## Discovery

**Don't hardcode the glossary's location.** Find it:

1. Look for an existing glossary: a file named `glossary.md` (or similar —
   `terminology.md`, `vocabulary.md`) under `docs/` or the project root, and
   any mention in the project's top-level agent-instructions file (e.g.
   `CLAUDE.md`). If the project's `specCoverage { }` block sets
   `glossaryFile`, that is the answer.
2. If none exists and the user wants one, create it from
   `templates/glossary.md`. Default location: `docs/glossary.md`. **Never
   place it under the project's `specsDir`** — `verifySpecCoverage` treats
   every `.md` there as a spec and would fail demanding a test. Tell the
   user to set `glossaryFile` in `specCoverage { }` if they want mechanical
   enforcement (see "Enforcement" below).

## Entry format

Every `## ` heading is one term, and the heading text is the canonical
form. Fields are bold-labelled bullets directly under it (the Gradle check
parses `Avoid` with a regex, so keep the exact `- **Avoid:** a, b` shape):

```
## Workspace

- **Type:** noun
- **Status:** settled
- **Definition:** The top-level container a group of users shares.
- **Avoid:** Project, Org, Team
- **Allow:** project plan
- **UI label:** Workspace
- **Notes:** Optional — nuance, reversibility, where not to use it.
```

- **Type** — `noun`, `verb`, `adjective`, or `status`. Verbs matter as
  much as nouns: one user intent should map to one verb everywhere
  (delete vs. remove vs. archive differ in meaning, so say which is which
  in Definition/Notes).
- **Status** — `settled` (the default when omitted) or `proposed`. A
  `proposed` entry records an open decision — the project currently uses
  several wordings and this is the suggested winner. Proposed entries are
  **not enforced** (the Gradle check and [[glossary-check]] skip their
  `Avoid` lists), so a glossary can be adopted before every conflict is
  decided. Promote an entry to `settled` once the user confirms it.
- **Definition** — one line, in product terms.
- **Avoid** — comma-separated banned synonyms. Matching is case-insensitive
  and whole-word, with an optional trailing `s`; list other inflections
  (`Removed`, `Removing`) explicitly if they matter. In specs the check
  looks only at **displayed wording** — "quoted" or **bold** text — not
  surrounding prose, so an `Avoid` word is judged where a reader would see
  it as UI text. In UI string resource files the whole string is checked.
- **Allow** — optional comma-separated phrases exempt from this entry's
  `Avoid` check, for legitimate uses of an otherwise-banned word
  (`meet in person` on an entry that avoids `In person`). Prefer this over
  scattering `glossary-ok` markers when the same exception recurs.

**Don't put generic actor words in `Avoid`.** `user`, `person`, `people`,
`someone`, `anyone` and similar words describe who is acting in a spec
("the user enters the weight") and are correct in prose even when the
project has a more specific noun for a role (Member, Customer). Matching
them mechanically floods the report with false positives and trains people
to ignore it. Define the specific noun (`Member`) with a Notes line saying
when to prefer it (a role-specific capability or permission, an on-screen
label) and leave the generic word out of `Avoid`; [[glossary-check]] raises
misuse as a judgment suggestion instead.
- **UI label** — the exact on-screen string when it differs from the
  heading (e.g. heading `Archive`, button label `Archive item`). Omit when
  identical.
- **Notes** — optional. When two entries are easy to confuse (Request vs.
  Application, Listing vs. Profile), each entry's Notes should name the
  other and say how they differ.

Keep headings alphabetized.

## Bootstrap: no glossary yet

When the project has specs and UI strings but no glossary, don't add terms
one by one. Survey first:

1. Read `docs/overview.md`-style product docs, the specs under `specsDir`,
   and the string resource file(s) to learn the project's nouns, verbs, and
   roles.
2. Count candidate clusters — groups of wordings for one concept (sign in /
   log in / login; lesson / session; online / virtual / video) — across
   specs and strings separately, e.g. `Sign in: 39 specs, 3 strings | Log
   in: 5 / 2 | Login: 0 / 1`. Include verb pairs for the same user intent
   and product-name variants.
3. Draft the whole file from `templates/glossary.md`. A concept with one
   consistent wording becomes a `settled` entry; a cluster becomes a
   `proposed` entry whose heading is the most-used or clearest form, with
   the others in `Avoid`, and a Notes line saying what the codebase uses
   today. Don't invent a winner silently — the Notes line is how the user
   sees the conflict.
4. Present the file plus a short list of the `proposed` conflicts for the
   user to confirm. Nothing is rewritten in specs or strings at this point;
   that is [[rename-term]] once an entry is settled.

## Step 1: Understand what's being defined

Get from the user (or from the spec that coined it): the term, whether it's
a noun/verb/etc., what it means, and which existing words it replaces or
could be confused with. Don't invent a definition — ask if the meaning isn't
clear.

## Step 2: Check for collisions

Before writing, search the glossary (case-insensitively, including every
`Avoid` list and `UI label`) for:

- The proposed term already existing as a heading → this is an **update**,
  not an add. Show the current entry and propose the change.
- The proposed term appearing in another entry's `Avoid` list → direct
  conflict. The user must decide which entry wins; don't resolve it
  silently.
- A near-synonym heading (e.g. proposing "Space" when "Workspace" exists,
  or "Remove" when "Delete" exists) → ask whether it's a genuinely distinct
  concept or an alias that belongs in the existing entry's `Avoid` list.
- A proposed `Avoid` word that is itself a heading → conflict, same as above.

If a proposed `Avoid` word is a generic actor word (see above), don't add
it; put the guidance in the noun's Notes instead.

For every word going into `Avoid`, grep the specs and UI strings for its
current usage and look at the hits. If many are ordinary English that isn't
the concept (`Confirm`, `Pass`, `Events`, an adverbial `in person`), say so
and ask whether to drop the word, narrow it, or cover the legitimate uses
with `Allow` phrases — a noisy avoid-list gets ignored.

Also grep the specs and UI strings for how the concept is **currently**
written. If the project already uses a different word widely, say so — the
new canonical term implies a [[rename-term]] pass, and the user should know
the size of it up front.

## Step 3: Write the entry

Add or amend the entry in the format above, in alphabetical position. When
adding an `Avoid` word that existing specs or UI strings still use, don't
fix those here — report them and offer [[rename-term]] (or
[[glossary-check]] for the full list).

## Enforcement

The glossary is only guidance until something checks it. Two levels:

- **Skill-level:** [[glossary-check]] reports usage of avoided words; run it
  on demand.
- **Build-level:** on a `spec-coverage` Gradle plugin version that supports
  it (check `SpecCoverageExtension` for a `glossaryFile` property — don't
  assume), setting `specCoverage { glossaryFile.set(...) }` makes
  `verifySpecCoverage` fail when a spec uses an avoided word of a settled
  entry, or lists a term in its `terms:` front matter that has no glossary
  entry. Only a spec's quoted and bold spans are checked, not its plain
  prose (see [[update-spec]] for the convention specs follow). If the
  property `glossaryScan` also exists, pointing it at the string resource
  file(s) extends the same check to UI strings, where every string's full
  text is checked.

## Report

Show the entry as written, list any collisions resolved, note how many
existing usages of newly-avoided words remain (and that nothing was
rewritten), and mention whether enforcement is configured. Don't commit
anything yourself unless asked.
