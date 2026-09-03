<!--
Template for a workflow-style spec: a multi-step/cross-screen user flow.
Replace every <...> placeholder and delete this comment block before writing
the file.

- Omit `targets:` entirely if the project doesn't use per-target scoping.
- The capability statement is 1-2 sentences of plain-language product
  behavior — never a click-by-click Given/When/Then walkthrough, never
  button-label-exact step numbering.
- Acceptance bullets are optional — only add them if the flow has distinct
  sub-behaviors worth calling out separately (e.g. an edge case, a
  validation rule). A simple flow can be the capability statement alone.
- Each bullet gets its inline test reference once the implementing test
  exists — leave it off (or write `(unimplemented)`) if drafting the spec
  ahead of the test.
- Add a "Variants/states" section (see below) only if this flow genuinely
  plays out differently in distinct situations — e.g. narrow vs wide — not
  for every possible screen size.
-->
---
targets: [<target-a>, <target-b>]
---

# <Workflow name>

<One to two sentences: what a user can do, end to end, and the outcome —
e.g. "A user can submit a rating for an attribute with no existing data,
and see the results reflect a real score afterward."> (`<TestFile.kt>`:
`<test function name>`)

- <An additional acceptance bullet for a distinct sub-behavior or edge
  case, if any> (`<TestFile.kt>`: `<test function name>`)
- <Another, if any>

<!--
## Variants/states

Only if this workflow genuinely plays out differently between distinct
situations (not just a reflow) — e.g. a narrow-viewport flow that swaps a
dialog for a full-screen step. Each bullet MUST start with a short id in
bold (`- **<id>** — ...`); if the project's spec-coverage plugin supports
variant checking (see `reconcile-e2e-specs`), `verifySpecCoverage` fails
the build unless every id here has at least one `@Spec("<this spec's id>",
variant = "<id>")` test. Delete this whole section (including this
comment) if it doesn't apply.

- **<id>** — <what differs in this variant> (`<TestFile.kt>`: `<test
  function name>`)
-->
