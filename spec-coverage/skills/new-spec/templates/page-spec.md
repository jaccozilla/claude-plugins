<!--
Template for a page/screen-style spec: what a single view shows for a given
state. Replace every <...> placeholder and delete this comment block before
writing the file.

- Omit `targets:` entirely if the project doesn't use per-target scoping.
- Omit the "Mockup" line if the project doesn't keep design mockups.
- Each bullet gets its inline test reference once the implementing test
  exists — leave it off (or write `(unimplemented)`) if drafting the spec
  ahead of the test.
- Add a "Variants/states" section (see below) only if this page genuinely
  renders differently in distinct situations — e.g. a narrow vs wide
  layout that isn't just a reflow, or an empty/loading/error state — not
  for every possible screen size or transient loading flicker. Omit the
  section entirely otherwise.
-->
---
targets: [<target-a>, <target-b>]
---

# <Screen/page name>

Mockup: <link, if the project keeps one — otherwise delete this line>

- <What the view shows/contains — one bullet per distinct piece of content
  or state> (`<TestFile.kt>`: `<test function name>`)
- <Another bullet — content, not interaction: what's present, not what a
  user does>
- <A conditional-state bullet, e.g. "Shows an empty-state message when
  there are no results">

<!--
## Variants/states

Only if this page's layout or content genuinely diverges between distinct
situations (not just resizes) — e.g. narrow vs wide, or a loading/error
state at the page level rather than a single component's. Each bullet MUST
start with a short id in bold (`- **<id>** — ...`); if the project's
spec-coverage plugin supports variant checking (see `reconcile-e2e-specs`),
`verifySpecCoverage` fails the build unless every id here has at least one
`@Spec("<this spec's id>", variant = "<id>")` test. Delete this whole
section (including this comment) if it doesn't apply.

- **<id>** — <what differs in this variant, e.g. "stacks the sidebar below
  the main content instead of beside it"> (`<TestFile.kt>`: `<test
  function name>`)
-->
