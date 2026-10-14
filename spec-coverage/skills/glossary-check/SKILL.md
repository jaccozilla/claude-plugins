---
name: glossary-check
description: Audit a project's specs (and optionally UI strings and docs) against its product/UI glossary — report uses of avoided synonyms, near-variants of canonical terms, specs whose `terms:` front matter names an unlisted term, and recurring terms missing from the glossary. Report-only unless asked to fix. Use when the user asks to check terminology, language consistency, or glossary drift, after adding several specs, or when `verifySpecCoverage` fails on a glossary violation.
---

# Check usage against the glossary

The glossary is a markdown file of canonical product/UI terms (format:
see [[define-term]]). This skill audits the project's written language
against it. It **reports**; it does not rewrite — specs and UI strings are
product documentation. To apply a fix, use [[rename-term]] for a
project-wide change or edit the single spec after the user agrees.

## Discovery

1. Find the glossary (see [[define-term]] "Discovery"): the
   `specCoverage { glossaryFile }` setting if present, else a
   `glossary.md`-style file under `docs/` or named in `CLAUDE.md`. If the
   project has none, say so and offer to start one with [[define-term]] —
   don't invent term lists.
2. Find `specsDir` (the `specCoverage { }` block in the module's
   `build.gradle.kts`).
3. Find where UI strings live. **Scan the string resource files by default**
   (e.g. Compose `strings.xml`, `.properties`, i18n JSON) alongside the
   specs — that's where most of an app's actual wording lives. Only ask
   before scanning string literals in UI code, which is noisier. When
   scanning `strings.xml`-style files, check only the text content of each
   string/item: skip XML comments (the `<!-- Screen (docs/specs/...) -->`
   headers), attribute values and resource names, and format placeholders
   such as `%1$s` and `%d`; decode `&amp;` and friends first.
4. Check whether the project's `spec-coverage` plugin supports
   `glossaryFile`. If so, run `verifySpecCoverage` first — it already
   mechanically catches avoided words and unknown `terms:` entries in specs;
   this skill then covers what a regex can't. That check reads only a spec's
   **displayed wording** (see Step 1), so keep this skill's mechanical scope
   identical to it — otherwise the two disagree about what a violation is.

## Step 1: Avoided-synonym hits (mechanical)

**Generic actor words are never mechanical hits.** If an `Avoid` list
contains `user`, `person`, `people`, `someone`, `anyone` or a similar word
naming who is acting, don't scan for it: it is correct in spec prose
("the user enters the weight"). List it once under "generic words in
`Avoid`" and suggest removing it from the entry (the specific noun's Notes
should say when to prefer it); check misuse in Step 2 instead.

**What counts as a spec's wording.** A spec's glossary terms are its
**displayed wording** only — text a reader would see on screen: "double-
quoted" literals (a label, a message; straight or curly quotes) and
**bold** terms (a control or option the spec names). Everything else in a
spec is prose about the product or its internals ("keyboard events", "Enter
confirms it"), which a synonym list can't tell apart from UI wording, so
it is **not** a mechanical hit. This matches the Gradle `spec-coverage`
check. Note that a Variants/states bullet's bold id (`- **wide** — ...`) is
a bold span, so it is scanned like any other. String resource files are
different: they are UI wording throughout, so scan all of each string's
text (Discovery step 3).

For each **settled** entry's `Avoid` list (entries with `Status: proposed`
are open decisions — see Step 1b), search the scope case-insensitively as
whole words (optional trailing `s`) — in specs, only within the quoted and
bold spans above. Skip front matter, inline `` `code` `` spans (test
references and ids live there), and any line carrying a `glossary-ok`
marker (an intentional exception, e.g. quoting a competitor). Before
counting a hit, remove the entry's `Allow` phrases from the line, and
skip a hit that is clearly ordinary English for a different sense of the
word (`Confirm`, `Pass`) — list those separately as "probable false
positives" so the user can add an `Allow` phrase or drop the word. Report
each hit as `file:line — "<found>" → use "<canonical>"` with the line's
text. Group by canonical term.

**A UI label quoted in a spec is a different fix.** When a spec puts a
word inside double quotes as the literal on-screen text (`labelled
"Login"`), the spec is accurately describing a string that is itself wrong.
Report these in their own "UI label quoted in spec" group, naming the
string resource that holds the label, and fix order: change the string
first, then the spec's quote (see [[rename-term]]) — otherwise the spec
stops matching the app.

## Step 1b: Proposed entries — which wording is winning

For each `Status: proposed` entry, don't report violations; report the
cluster instead: every competing wording (the heading plus its `Avoid`
words) with its count in specs and in strings, e.g. `Sign in: 39 specs, 3
strings | Log in: 5 / 2 | Login: 0 / 1`. Say which wording the codebase
leans toward, and whether that agrees with the entry's heading. This is the
input for the user's decision to settle the entry.

## Step 2: Near-variants (judgment)

Things a banned list can't catch. This is also where **unquoted, unbolded
spec prose** gets checked, since Step 1 doesn't look there: read it for an
avoided word used in the product's sense ("tap Log in" written in plain
text, an unquoted "Project" meaning the glossary's Workspace) and report it
as a suggestion. Prose that merely mentions a concept in ordinary English
isn't a finding. If such a term is meant to appear on screen, the fix is to
quote or bold it in the spec — then the build check covers it from then on.

- Inflections and compounds not listed in `Avoid` (e.g. "Removing" when
  only "Remove" is listed; "Team space" for "Workspace").
- A canonical term used in the wrong sense — a verb like "Archive" used to
  mean permanent deletion.
- Capitalization or label drift against an entry's `UI label` (heading
  `Archive`, label `Archive item` — but a spec says "Archive button").
- A glossary term a spec names as on-screen text but leaves unquoted and
  unbolded (`taps Archive` rather than `taps **Archive**`), so the build
  check can't see it. Suggest marking it up — see [[update-spec]].
- A generic actor word (`user`, `person`) where the bullet describes a
  capability or permission of a specific role that has its own glossary noun
  (e.g. "the user can edit only their own profile" when `Member` is the
  defined role). Plain actor use ("the user taps Save") is fine; list only
  the role-specific cases.
- Two different verbs for the same user intent in different specs, where
  neither is listed (the glossary has a gap, not a violation).

Mark these as **suggestions**, not violations — each needs a human call.

## Step 3: Missing terms

Find words or short phrases that recur across three or more specs (or UI
strings), look like product nouns or action verbs, and have no glossary
entry. List them as candidates for [[define-term]]. Don't pad this: only
report ones that plausibly carry product meaning, not ordinary vocabulary.

## Step 4: `terms:` front matter

If specs use the optional `terms: [A, B]` front matter (see [[new-spec]]),
check each listed term exists as a heading. Also flag a spec whose body
prominently uses a glossary term that its `terms:` list omits — only when
the project's specs use `terms:` consistently; otherwise skip this.

## Report

Lead with counts: avoided-synonym hits in displayed wording (specs vs.
strings), prose-only suggestions (specs, unquoted), probable false
positives, quoted-UI-label cases, near-variant suggestions, candidate
missing terms, unknown `terms:` entries, and open `proposed` entries. Then
the details grouped by canonical term, with the proposed-entry clusters
last. Offer next steps — [[rename-term]] for a term with many hits,
[[define-term]] for missing terms — but don't apply any change without the
user's go-ahead. Don't commit anything yourself unless asked.
