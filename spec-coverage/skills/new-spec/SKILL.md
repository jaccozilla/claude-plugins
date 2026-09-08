---
name: new-spec
description: Draft a new markdown spec file for a project using the gradle-plugins "spec-coverage" convention plugin, using the project's page/screen, workflow, or component template. Use when the user asks to add, write, draft, or scaffold a new spec — for a new screen, a new user flow, a new reusable UI component, or a new piece of product behavior — before an implementing test exists.
---

# Draft a new spec

This skill pairs with the `spec-coverage` Gradle convention plugin
(`gradle-plugins/spec-coverage`) and the [[reconcile-e2e-specs]] skill. Use
this skill to scaffold a brand-new spec file from scratch; use
`reconcile-e2e-specs` afterward (or whenever a `verifySpecCoverage` failure
points at this new file) to draft the implementing test.

**This skill doesn't hardcode any project's directory layout.** Before
writing anything, find the actual configuration:

1. Search the project for `id("spec-coverage")` (usually in a module's
   `build.gradle.kts`) and read that module's `specCoverage { }` block —
   this tells you the real `specsDir` and whether the project uses
   per-target scoping at all (some projects build for a single target and
   never use `targets:` front matter).
2. Read a handful of existing spec files under `specsDir` to learn the
   project's real conventions: how specs are organized into subdirectories
   (many projects split `pages/` vs `workflows/` vs `components/`, but
   naming varies), the `@Spec` id format (usually the spec's path relative
   to `specsDir`, minus `.md`), whether `targets:` front matter is used and
   what values it takes, and whether specs use inline per-bullet test
   references (a trailing `` (`<TestFile.kt>`: `<test function name>`) ``
   after each sentence/bullet) — the format this skill's templates default
   to — or a different established convention.
3. Check whether the project's `@Spec` annotation (usually near
   `specsDir`'s consuming test source set, e.g. `Spec.kt`) has a `variant`
   parameter, and whether `VerifySpecCoverageTask` in that project's
   `spec-coverage` plugin version parses `## Variants/states` bullets and
   the `variant =` param — some projects are on an older plugin version
   without this. If so, `verifySpecCoverage` mechanically enforces that
   every variant/state id a spec declares has at least one covering test —
   see the "Variants/states" guidance below and in `reconcile-e2e-specs`.
4. Check whether the project keeps a directory of reusable UI/behavior
   pattern docs (e.g. a `docs/patterns/` folder — the name varies by
   project, so look for whatever this project's own docs structure calls
   it; a project's top-level agent-instructions file, e.g. `CLAUDE.md`,
   often names its doc directories). If one exists, skim it for anything
   relevant to what this spec describes (a keyboard-navigable input, a
   narrow/wide layout variant, an empty/loading/error convention, etc.)
   before writing a word of the spec — see Step 2.

If discovery turns up an established pattern the new component/page/
workflow should follow but the implementation doesn't yet, say so plainly
in your report (Step 4) rather than silently writing a spec that describes
non-conforming behavior as if it were intentional.

## Step 1: Classify the spec

Ask the user (if not already obvious from what they're describing) whether
this is:

- **A page/screen spec** — what a single view shows for a given state. Use
  `templates/page-spec.md`.
- **A workflow spec** — a multi-step/cross-screen user flow. Use
  `templates/workflow-spec.md`.
- **A component spec** — a reusable piece of UI shared across more than one
  page or workflow (e.g. a header, a search popup, a nav bar), described so
  it's testable in isolation from any page that embeds it. Use
  `templates/component-spec.md`.

Any of the three may also carry a `## Variants/states` section when the
page/workflow/component genuinely renders or behaves differently between
distinct situations (narrow vs wide layout, empty/loading/error, open vs
closed) — not for every possible screen size or a transient loading
flicker. See "Variants/states" below.

If the project's existing specs are split into subdirectories by type (e.g.
`pages/` / `workflows/` / `components/`), that split determines both which
template to use and where the new file goes.

A page or workflow spec that includes a shared component should reference
that component's spec inline, from the bullet describing where it appears
(e.g. "A site header showing the logo and nav links (see
`components/header.md`)") — never the reverse; a component spec doesn't
list which pages use it.

## Step 2: Fill in the template

Specs read like product requirements, not test transcripts:

- A **page spec** is a content inventory — bullets naming what the view
  includes — plus, if the project keeps design mockups somewhere, a link to
  the matching one. Not interactions, not layout details — what's present.
- A **workflow spec** is a title plus a 1-2 sentence capability statement
  (e.g. "A user can submit a rating for an attribute with no existing data,
  and see the results reflect a real score afterward.") plus, optionally, a
  short bullet list of further plain-language acceptance criteria for
  distinct sub-behaviors or edge cases. Never a click-by-click Given/When/
  Then walkthrough, never button-label-exact step numbering.
- A **component spec** is a content inventory like a page spec, but scoped
  to the component in isolation — bullets naming what it renders and, if it
  has distinct interactive states (e.g. empty/loading/error, open/closed,
  selected/unselected), a bullet per state. Every bullet must describe
  something checkable by mounting the component on its own — not something
  only observable incidentally through a page that happens to embed it.

If the discovery step found a relevant pattern doc, hold what you're
about to write against it before finalizing: does this component/page
follow the same convention (e.g. the project's established keyboard-
navigation model, its narrow/wide layout rules), or does it diverge? A
deliberate, reasoned divergence is fine — note it in the spec bullet
itself (e.g. "Tab moves focus normally, unlike the project's usual
list-navigation pattern, because ...") — but don't write a spec that
silently describes inconsistent behavior as if no pattern existed, and
don't force conformance to a pattern that genuinely doesn't fit without
flagging the mismatch to the user first.

Copy the matching template, replace every placeholder with real content
distilled from what the user asked for, and drop `targets:` front matter
entirely if the project doesn't use it (don't leave it as an empty or
placeholder value). If the implementing test doesn't exist yet, leave the
inline test reference off each bullet rather than inventing one — an
unimplemented spec is exactly what `verifySpecCoverage` and
`reconcile-e2e-specs` are for.

### Variants/states

If the project's `VerifySpecCoverageTask` supports variant checking (see
the discovery step above), every bullet under `## Variants/states` MUST start with a
short id in bold — `- **narrow** — collapses to a single trigger row.` —
because `verifySpecCoverage` will fail the build unless at least one test
carries `@Spec("<this spec's id>", variant = "<id>")` for each id declared
there. Pick ids that read naturally as that string: short, lowercase, no
spaces (`narrow`/`wide`, `loading`/`error`/`empty`), not full sentences.
Each template has this section commented out (page/workflow) or present
(component, since it's the common case there) — include it only when the
behavior genuinely diverges, and delete it entirely otherwise. If the
implementing tests don't exist yet, the section is still fine to write —
`verifySpecCoverage`/`reconcile-e2e-specs` will surface the gap the same
way an unimplemented spec does.

## Step 3: Name and place the file

Derive the spec id the same way the project's existing specs do (usually a
slug of the title, placed under whichever subdirectory matches its type).
Write it to `<specsDir>/<id>.md`. Don't overwrite an existing spec file
without confirming with the user first.

## Step 4: Report

Show the user the drafted spec (or its path, if written directly), note
whether it has an implementing test yet, and — if not — mention that running
`reconcile-e2e-specs` (or the project's `verifySpecCoverage` task) is the
next step to get one drafted. Don't commit anything yourself unless asked.
