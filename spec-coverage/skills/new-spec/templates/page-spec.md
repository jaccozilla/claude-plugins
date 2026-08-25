<!--
Template for a page/screen-style spec: what a single view shows for a given
state. Replace every <...> placeholder and delete this comment block before
writing the file.

- Omit `targets:` entirely if the project doesn't use per-target scoping.
- Omit the "Mockup" line if the project doesn't keep design mockups.
- Each bullet gets its inline test reference once the implementing test
  exists — leave it off (or write `(unimplemented)`) if drafting the spec
  ahead of the test.
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
