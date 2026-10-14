---
name: update-spec
description: Edit an existing markdown spec in a project using the gradle-plugins "spec-coverage" convention — add, change or remove behavior bullets — while keeping it consistent with the project's product/UI glossary and its test links. Knows that the glossary check reads only quoted and bold text. Use when the user asks to update, revise, extend or fix an existing spec, or says the product behavior it describes has changed.
---

# Update an existing spec

Pairs with [[new-spec]] (which scaffolds a spec from scratch),
[[reconcile-e2e-specs]] (which keeps specs and tests in step) and the
glossary skills ([[define-term]], [[glossary-check]], [[rename-term]]). Use
this skill to change a spec that already exists; the same wording rules
apply as in [[new-spec]].

**Don't hardcode layout.** Find `specsDir` and the `@Spec` id format from the
`specCoverage { }` block and a few neighboring specs, as [[new-spec]]
describes. Then read the **whole** target spec first — its front matter
(`targets:`, `terms:`), bullets, inline test references and any
`Variants/states` section — before changing a line.

## The displayed-wording convention

If the project has a glossary (see [[define-term]] "Discovery"; read it in
full), the build check (`verifySpecCoverage` with `glossaryFile` set) judges
a spec by its **displayed wording only**:

- **"Double-quoted"** text (straight or curly quotes) — an on-screen label,
  message, placeholder or other literal.
- **Bold** text — a named control, option or tab.
- Nothing else. Plain prose, front matter, inline `` `code` `` spans and any
  line containing `glossary-ok` are not checked.

So when writing or changing a bullet:

1. Mark up what the user sees: `shows "Sign in"`, `taps **Archive**`. Spell
   it exactly as the glossary entry's `UI label` (heading if there is none).
2. Never put an `Avoid` word inside quotes or bold. If the real UI string is
   an avoided word, don't hide it in plain text — say so and suggest fixing
   the string first (see [[glossary-check]] "UI label quoted in spec" and
   [[rename-term]]), or add `glossary-ok` / an `Allow` phrase for a genuine
   exception.
3. Don't quote or bold a word for emphasis or as a technical term — it
   becomes subject to the check. Use plain prose for behavior and internals,
   still choosing the canonical term for the concept.
4. Beware that a `Variants/states` bullet's id (`- **wide** — ...`) is bold
   and so is checked; choose ids that aren't avoided words.
5. If the project uses `terms:`, keep it accurate: add each glossary term
   the edited spec now relies on and drop one no longer used, spelled as the
   glossary headings. Don't list a term the glossary lacks.
6. A concept the glossary doesn't have: use the most natural wording, don't
   coin a term quietly, report it, and offer [[define-term]]. Entries marked
   `Status: proposed` aren't enforced — follow the wording the project's
   specs use most and name the open entry in the report.

## Steps

1. **Read** the spec and the glossary (above) and clarify what is changing
   in product terms. If the request is only a word swap across many specs,
   that's [[rename-term]], not this skill.
2. **Edit** the spec in its existing style: one bullet per distinct piece of
   behavior, same voice and structure as its neighbors. Keep bullets about
   what the product does, not how it's implemented.
3. **Keep test links honest.** A bullet whose behavior changed keeps its
   inline test reference (`` (`File.kt`: `test name`) ``) only if that test
   still plausibly covers it; otherwise mark it `(unimplemented)` rather than
   leave a link that now lies. Never rename the spec file or change its id
   here — `@Spec` ids elsewhere depend on it. Removing a bullet whose test
   exists, or a `Variants/states` id with `@Spec(..., variant = ...)` tests,
   leaves orphaned tests: list them for the user rather than deleting.
4. **Verify.** Run the project's `verifySpecCoverage` task if it's cheap to
   do so. Glossary failures mean a quoted/bold word is avoided or a `terms:`
   entry is unknown — fix as above. New or changed behavior with no
   implementing test is the cue to run [[reconcile-e2e-specs]].

## Report

Summarize the edit, list bullets now without a passing test link, any
glossary issues found or resolved (terms needed but missing, places where
the spec had to diverge from a glossary term and why, open `proposed`
entries), and any orphaned tests. Don't commit anything yourself unless
asked.
