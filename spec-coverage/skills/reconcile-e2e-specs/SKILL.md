---
name: reconcile-e2e-specs
description: Reconcile markdown spec files against their implementing @Spec-annotated Kotlin tests, in a project using the gradle-plugins "spec-coverage" convention plugin (registers a verifySpecCoverage task) — draft a missing test for a spec, draft a missing spec for a test, and flag specs whose plain-language description has drifted from what the test actually does. Use when the user asks to reconcile, sync, or check drift between spec files and their tests, after adding a new spec or a new spec-linked test, or when a verifySpecCoverage task fails and needs a fix rather than just a report.
---

# Reconcile specs and tests

This skill pairs with the `spec-coverage` Gradle convention plugin
(`gradle-plugins/spec-coverage`): a project applying `id("spec-coverage")`
configures a `specCoverage { specsDir; testSourceDirs }` block and gets a
`verifySpecCoverage` task that fails if a markdown spec has no implementing
`@Spec`-annotated Kotlin test, an `@Spec` names a nonexistent spec file, (if
a spec declares `targets:` front matter) the declared targets disagree with
which `testSourceDirs` entry the test actually lives in, or (on a plugin
version new enough to support it — check, don't assume) a spec's `##
Variants/states` section declares a variant id with no `@Spec("<id>",
variant = "<variant-id>")` test covering it, or a test names a `variant =`
its spec doesn't declare.

**This skill doesn't hardcode any project's directory layout.** Different
projects configure `specsDir`/`testSourceDirs` differently (e.g. one repo's
specs might live at `docs/specs/`, another's at `e2e/specs/`; one might split
`pages/`/`workflows/`, another might not). Before doing anything else,
find the actual configuration:

1. Search the project for `id("spec-coverage")` (usually in a module's
   `build.gradle.kts`) and read that module's `specCoverage { }` block —
   this tells you the real `specsDir` and `testSourceDirs` paths, and the
   Gradle task's full name (`:<module>:verifySpecCoverage`).
2. Read a couple of existing spec files under `specsDir` (if any exist) to
   learn the project's actual conventions: how specs are organized into
   subdirectories, what the `@Spec` id format looks like (usually the
   spec's path relative to `specsDir`, minus `.md`), whether specs use
   `targets:` front matter, and how they cite their implementing test(s).
   If specs already use inline per-bullet test references (a trailing
   `` (`<TestFile.kt>`: `<test function name>`) `` after each sentence/
   bullet, rather than one list at the end) — the format this skill
   defaults to when drafting new specs, see below — follow that; if a
   project has established a different convention, follow it instead.
3. Read a couple of the `@Spec`-annotated Kotlin test files to learn the
   project's actual test-writing conventions (test framework/UI-testing
   library in use, how fixtures/seeded data are referenced, any shared test
   utilities) — don't assume a specific framework.
4. Check whether the project's `@Spec` annotation has a `variant` parameter
   (usually defined near `specsDir`'s consuming test source set, e.g.
   `Spec.kt`) and whether any spec files actually have a `##
   Variants/states` section with bold-id bullets (`- **narrow** — ...`).
   Both must be true for variant coverage checking to be live in this
   project — an older `spec-coverage` plugin version, or a project that
   hasn't adopted the convention yet, won't have either.
5. Check whether the project keeps a directory of reusable UI/behavior
   pattern docs (e.g. a `docs/patterns/` folder — name varies by project;
   a top-level agent-instructions file like `CLAUDE.md` often names its
   doc directories). If one exists, keep it in mind for Step 3, where a
   freshly-drafted spec should be checked against it.

## Specs read like product requirements, not test transcripts

A workflow-style spec (a multi-step/cross-screen user flow) is a title plus
a 1-2 sentence capability statement (e.g. "A user can submit a rating for an
attribute with no existing data, and see the results reflect a real score
afterward.") plus, optionally, a short bullet list of further plain-language
acceptance criteria — never a click-by-click Given/When/Then walkthrough,
never button-label-exact step numbering. A page/screen-style spec (what a
single view shows for a given state) is a content inventory — bullets
naming what it includes — plus, if the project keeps design mockups
somewhere, an optional link to the matching one. A component-style spec (a
reusable piece of UI shared across more than one page or workflow) is a
content inventory like a page spec, but scoped to the component in
isolation — its bullets (including any distinct interactive states, e.g.
empty/loading/error) must each be checkable by mounting the component on
its own, not just observable through a page test that happens to embed it.
A page or workflow spec that embeds a shared component references that
component's spec inline from the bullet describing where it appears, rather
than duplicating the component's own content inventory.

Any of the three may have a `## Variants/states` section when the behavior
genuinely diverges between distinct situations (narrow vs wide layout,
empty/loading/error, open vs closed) — not for every screen size or a
transient loading flicker. Each bullet there starts with a short bold id
(`- **narrow** — ...`); on a project with variant checking live (see the
discovery step above), that id is what `variant = "<id>"` in a covering
`@Spec(...)` names.

**Prefer inline test references over a single list at the end.** Attach
`` (`<TestFile.kt>`: `<test function name>`) `` directly after the
sentence/bullet it backs, rather than a separate "implemented by" section —
this makes it obvious *which specific claim* a given test actually covers,
and surfaces real gaps a single end-of-file list can hide (a bullet backed
by a test in a *different* file than the one implementing the rest of the
spec, or a bullet with no real coverage at all). One spec can — and often
does — have more than one implementing test, each backing a different
bullet; `@Spec` goes on the individual `@Test fun` in that case (never on
the class), even when there's only one implementing test, so every inline
reference names something mechanically checkable.

## Step 1: Run the mechanical check first

Run the project's `verifySpecCoverage` task (found in step 1 above). Its
failure message (if any) already lists exactly what's missing, in up to
five categories:

- **`spec(s) with no implementing test`** — go to Step 2.
- **`test(s) referencing a nonexistent spec`** — go to Step 3.
- **`spec(s) with a targets: mismatch`** (only if the project uses
  `targets:` front matter) — go to Step 4.
- **`spec(s) with an uncovered Variants/states entry`** (only on a plugin
  version with variant checking) — go to Step 5.
- **`test(s) referencing a nonexistent variant`** (same) — go to Step 5.

If it passes cleanly, skip straight to Step 6 (drift reconciliation) — the
mechanical gaps are the cheap, unambiguous half of this skill's job; drift
is the judgment-based half, and worth checking on every run, not just when
something is broken.

## Step 2: Spec with no implementing test — draft the test

For each such spec, read it fully (front matter, capability statement/
content inventory, acceptance bullets and their inline test references) and:

1. Decide which of the project's `testSourceDirs` it belongs in — if the
   spec declares `targets:` scoping it to less than every target the
   project builds, it belongs in whichever source set implements that
   target; otherwise it belongs in whichever source set the project treats
   as "runs on every target" (if the project has such a shared source set —
   see what you learned in the discovery step above).
2. Write the test following the conventions already established in that
   directory (test framework, how fixtures/seeded data are referenced,
   shared test utilities). The spec's capability statement is a one-sentence
   summary of the whole test, not a literal step to transcribe — invent the
   concrete mechanics the same way the existing tests do. A workflow spec's
   acceptance bullets each usually map to one `@Test fun`; a page or
   component spec's content-inventory bullets usually map to assertions
   within a single test — for a component spec, that test mounts the
   component standalone rather than the full page/app it's normally
   embedded in, if the project's test setup supports that.
3. Add `@Spec("<id>")` on the specific `@Test fun` (never on the class), and
   add or fix the inline reference on whichever sentence/bullet this test
   backs — don't leave a bullet with no reference, or a stale one pointing
   at a different test.
4. Actually run the test (via the project's normal test task) — don't hand
   back a test you haven't confirmed passes.

## Step 3: Test with no spec — draft the spec

For each `@Spec("<id>")` the coverage check flagged as referencing a
nonexistent file (and it isn't just a typo — check the "did you mean" hint
the task prints first), read the implementing test and draft the spec file
at `<specsDir>/<id>.md`. Classify it the same way the project's existing
specs are classified (page/screen content-inventory, workflow capability
statement, or — if the test mounts a reusable piece of UI standalone rather
than a full page — component content-inventory; see the discovery step
above), distilling the test's
*product-level behavior*, not its mechanics — leave out exact button
labels, test tags, seeded ids, and step counts; those belong in the code,
not the spec. Attach the inline test reference directly to the
sentence/bullet it backs.

If the project has a pattern-docs directory (see the discovery step
above), check the drafted spec against anything relevant there before
finishing — does the test's behavior actually follow the project's
established convention (keyboard navigation, narrow/wide layout, etc.),
or does this component/page diverge from it? Note a genuine divergence in
the spec bullet itself rather than writing prose that reads as if no
pattern existed; if the divergence looks unintentional rather than a
deliberate choice, flag it to the user instead of quietly documenting it
as normal.

## Step 4: targets: mismatch — fix whichever side is stale

The check reports which side disagrees. Usually the test moved (e.g. a spec
that used to be scoped to one target got a portable test added, but the
spec's `targets:` front matter was never widened) — fix the spec's front
matter to match reality. If instead the spec's `targets:` scoping is what's
actually correct and the test is in the wrong source set, move the test to
the matching source set instead. Re-run `verifySpecCoverage` after either
fix to confirm it's resolved.

## Step 5: Variants/states mismatch — draft the missing test, or fix the stale id

For **`uncovered Variants/states entry`**: read the spec's bullet for that
variant id, decide which `testSourceDirs` entry it belongs in (same rule as
Step 2), and write a test — or add a case to an existing test function for
that spec — asserting the behavior the bullet describes, tagged
`@Spec("<spec id>", variant = "<variant id>")` on the specific `@Test fun`.
`WeekSlotPickerSpecTest`-style components/pages often already have a
sibling test for the *other* variant (e.g. one test per breakpoint/state) —
follow that same harness/fixture pattern rather than inventing a new one.

For **`test(s) referencing a nonexistent variant`**: the task's "did you
mean" hint usually means the variant id was renamed in the spec (fix the
`variant = "..."` in the test to match) or typo'd in the test (same fix).
If instead the id genuinely no longer applies (the variant itself was
removed from the component/page), remove that `@Spec(..., variant = ...)`
test/case rather than leaving it pointing at nothing — but confirm with the
user first, since deleting test coverage isn't something to do silently.

Re-run `verifySpecCoverage` after either fix.

## Step 6: Reconcile prose/behavior drift (judgment, not mechanical)

For each spec/test pair (walk the spec directory, find each one's
implementing test(s) via its inline references and cross-check against the
`@Spec(...)` occurrences actually in the code), compare each bullet/
sentence against what its referenced test's current code actually sets up,
does, and asserts. Look specifically for:

- A `@Test fun` carrying this spec's `@Spec(...)` id that no sentence/
  bullet references — the spec is missing coverage it should document (e.g.
  a new test function added for an edge case with no prose written for it
  yet).
- An inline reference naming a test/function that no longer exists, or no
  longer does what the bullet claims — either the code moved/changed and
  the spec's reference is stale, or the behavior itself changed and the
  bullet now overstates what's actually tested.
- A capability statement that no longer matches its referenced test's
  actual scope (e.g. the spec describes one behavior but the test was
  narrowed to only cover part of it).
- A `## Variants/states` bullet whose covering test asserts something
  different from what the bullet claims (e.g. the spec says a narrow
  layout "opens a full-screen popup" but the test now checks an inline
  collapsed panel instead) — `verifySpecCoverage`'s variant check only
  proves *a* test exists for that id, not that it still matches the prose.

**Never silently rewrite a spec.** Specs are product documentation — present
each drift you find as a proposed diff and ask before applying it, the same
way you'd treat an edit to any other doc file the user hasn't asked you to
freely rewrite. Minor wording drift is fine to note in your summary without
a full diff; a structural drift (a step added/removed) should always be
shown as an explicit before/after.

## Step 7: Report

Summarize: how many specs/tests were mechanically missing and were drafted
(Step 2/3), any `targets:` mismatches fixed (Step 4), any Variants/states
gaps or stale ids fixed (Step 5), how many spec/test pairs were checked for
drift (Step 6) and how many had drift found, and — for anything you drafted
or fixed — confirm `verifySpecCoverage` passes and the relevant test
task(s) were actually run and passed. Don't commit anything yourself unless
asked.
