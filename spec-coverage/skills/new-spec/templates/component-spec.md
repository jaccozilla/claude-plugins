<!--
Template for a component-style spec: a reusable piece of UI shared across
more than one page or workflow (e.g. a header, a search popup, a modal).
Replace every <...> placeholder and delete this comment block before
writing the file.

- A component spec describes the component in isolation, not any one page
  that embeds it — every bullet should be checkable by mounting the
  component on its own, not just observable incidentally through a page
  test.
- Omit `targets:` entirely if the project doesn't use per-target scoping.
- List distinct variants/states (open/closed, empty/loaded/error,
  selected/unselected, narrow/wide layout, etc.) as their own bullets under
  "Variants/states" if the component has any — omit that section entirely
  for a component with no meaningful state.
- Each Variants/states bullet MUST start with a short id in bold
  (`- **<id>** — ...`), e.g. `- **narrow** — collapses to an icon-only
  view below a certain width.` If the project's spec-coverage plugin
  supports variant checking (check whether `VerifySpecCoverageTask` parses
  `## Variants/states` bullets and a `variant =` param on `@Spec` — see
  `reconcile-e2e-specs`), `verifySpecCoverage` will fail the build unless
  every id here has at least one `@Spec("<this spec's id>", variant =
  "<id>")` test — so pick ids that read naturally as `variant = "<id>"`
  (short, lowercase, no spaces: `narrow`/`wide`, `loading`/`error`/`empty`,
  not full sentences).
- Each bullet also gets its inline test reference once the implementing
  test exists — leave it off (or write `(unimplemented)`) if drafting the
  spec ahead of the test.
- Don't list which pages/workflows use this component here — that
  reference belongs on the page/workflow spec's own bullet, pointing at
  this file.
-->
---
targets: [<target-a>, <target-b>]
---

# <Component name>

- <What the component always shows/contains — one bullet per distinct
  piece of content> (`<TestFile.kt>`: `<test function name>`)
- <Another bullet — content, not interaction: what's present, not what a
  user does>

## Variants/states

- **<id>** — <what distinguishes this variant/state, e.g. "shows a loading
  spinner while results are being fetched"> (`<TestFile.kt>`: `<test
  function name>`)
- **<id>** — <another variant, e.g. "collapses to an icon-only view below a
  certain width"> (`<TestFile.kt>`: `<test function name>`)
