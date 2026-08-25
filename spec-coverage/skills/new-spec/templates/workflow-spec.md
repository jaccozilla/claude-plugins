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
