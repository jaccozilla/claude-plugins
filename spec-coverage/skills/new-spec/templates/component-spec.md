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
- List distinct interactive states (open/closed, empty/loaded/error,
  selected/unselected, etc.) as their own bullets under "Variants/states"
  if the component has any — omit that section entirely for a component
  with no meaningful state.
- Each bullet gets its inline test reference once the implementing test
  exists — leave it off (or write `(unimplemented)`) if drafting the spec
  ahead of the test.
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

- <A distinct interactive state, e.g. "Shows a loading spinner while
  results are being fetched"> (`<TestFile.kt>`: `<test function name>`)
- <Another state, e.g. "Collapses to an icon-only view below a certain
  width"> (`<TestFile.kt>`: `<test function name>`)
