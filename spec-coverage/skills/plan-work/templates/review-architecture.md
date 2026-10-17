# Code architecture review

Pass run: <date>. Read: <plan files, the product review, the project's architecture docs, ADRs and patterns, and the code the plan touches>.

## Where the work lives

<Modules, layers and packages the plan touches, and where each piece of new logic belongs and why.>

## Reuse

- Existing components, patterns and specs to reuse or extend: <...>
- What is genuinely new: <...>

## Decisions that may need an ADR

- <Decision, and whether to write an ADR (confirm with the user first if the project requires it).>

## Draft ADRs

<Each draft in the plan's `adr/` folder, and where it lands: the real ADR directory, number, and the step that moves it. Or "None".>

- `adr/<file>.md` → <real path>, moved by step <n>

## Findings

- **[blocking | should-fix | note]** <Finding.> Decision: <...>.

## Result

<Is the shape sound? Which questions did this pass add?>
