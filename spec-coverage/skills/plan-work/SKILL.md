---
name: plan-work
description: Plan a large, multi-step piece of work as a folder under the deferred-work directory's plan/ subfolder (e.g. docs/todo/plan/<slug>/), iterating on it with the user and reviewing it in separate passes (code architecture, security and privacy, UI interaction, data and migrations, performance) before any code is written. Use when the user asks for a plan, says a piece of work is too big or too uncertain for a single todo, wants to think through a feature before building it, or asks to review, revise, approve or execute an existing plan. Also use when a todo has grown into several steps with open design questions.
---

# Plan work

A **todo** records one deferred piece of work ([[track-deferred-work]]). A
**plan** is for work that is big, has several steps, and is not yet
understood well enough to build: the point is to iterate on it, ask a lot of
questions, and review it from several angles *before* executing. Nothing is
built from a plan until the user explicitly approves it.

## Where plans live

Find the deferred-work directory the same way [[track-deferred-work]] does
(the project's agent-instructions file, else `docs/todo/`), then use its
`plan/` subfolder (`docs/todo/plan/`). Create it if needed and mention that
to the user. Each plan is one folder named with a short kebab-case slug:

```
docs/todo/plan/<slug>/
  plan.md          goal, context, status, decisions made so far
  questions.md     open and resolved questions
  reviews/         one file per review pass
    product.md
    ui-interaction.md
    architecture.md
    security.md
    data.md
    performance.md
    specs.md
  prototype/       throwaway HTML prototype of the screens (index.html)
  specs/           draft specs for the plan (pages, workflows, components)
  adr/             draft ADRs for decisions the plan makes
  steps.md         the ordered work, written after the passes
```

Start from the files in `templates/`: `plan.md`, `questions.md`, `steps.md`,
and one `review-<pass>.md` per pass (copy it to `reviews/<pass>.md`), so every
plan has the same shape. Files are small and each has one job,
so a later session reads only what it needs: `plan.md` first, then whatever
the task touches. The folder is temporary; it is deleted when the plan is
done (see "Finishing").

## Status

`plan.md` carries a `Status:` line, one of:

- `draft`: still being shaped; questions open.
- `reviewing`: the required passes are being run.
- `approved`: the user said yes in chat to executing this plan.
- `executing`: steps are being built.

Only the user moves a plan to `approved`. Never infer it from silence, from
"sounds good" about a part of the plan, or from the passes being finished.

## Workflow

### 1. Understand before drafting

Ask clarifying questions until you are roughly 95% sure of the goal, scope
and constraints. Batch them (e.g. AskUserQuestion, several per call), each
with its realistic options and the recommended one first, and expect more
than one round: answers raise new questions. Read the code, docs, ADRs,
specs and patterns the work touches so the questions are informed and the
options are real. Record every question in `questions.md` as soon as it
exists and resolve it in place when answered, as
`- [x] <question> → <answer> (<date>)`.

### 2. Draft `plan.md`

State the goal in a few sentences, the context a stranger would need, what is
explicitly out of scope, and the decisions made so far. Keep implementation
detail out until the passes have run; this is the shape of the work, not the
code.

### 3. Run the review passes, one at a time

Set the status to `reviewing`. Run each pass as its own pass: re-read
`plan.md`, `questions.md` and earlier reviews fresh, read the project material
that pass needs, and write `reviews/<pass>.md`. Do not fold several passes
into one read; each angle finds different problems.

Required passes, in this order (a project may add more in its agent-instructions
file, e.g. accessibility, performance, i18n):

- **Product and use cases** (`product.md`): take the role of a product
  manager. First establish the roles (see below). Then, for each role, what job does each one come to do,
  and what are the use cases, end to end, including the unhappy ones (no
  access, nothing yet, a change of mind, two actors at once)? Are there
  cases the plan ignores, or behavior nobody asked for? Is the scope the
  smallest thing that delivers the value, and what is the first slice? This
  is functional, not visual: what the product must do and for whom, before
  how it looks. Write the use cases into `plan.md` as the list the later
  passes and the specs must cover.
- **UI interaction** (`ui-interaction.md`): the design view of the flows the
  product pass found: entry points, narrow and wide layouts, empty, loading,
  error and permission states, existing patterns and component specs to
  follow, and wording against the glossary. Build and iterate on a quick
  HTML prototype here (see below). It runs right after the product pass, not
  late, because layout and interaction answers change what the later passes
  must cover: a field or state the prototype shows is needed becomes a data,
  security or architecture question.
- **Code architecture** (`architecture.md`): module and layer boundaries,
  where logic lives, what existing components, patterns and ADRs to reuse or
  extend, what is genuinely new and whether a new ADR is warranted. Draft
  each warranted ADR (see below).
- **Security and privacy** (`security.md`): who can see or change what, the
  authorization boundary (row level security, not UI checks), exposure of
  personal data, abuse and misuse cases, what is logged or cached.
- **Data and migrations** (`data.md`): schema, policies, indexes, seeds,
  hosted-safe migration rules, existing data, and rollback.
- **Performance** (`performance.md`): will it stay fast at the expected load?
  Runs after the data pass because it judges the real queries and schema.
  For each hot path (the screens and actions used most or touching the most
  data) ask: what is **cachable** (data that rarely changes or is shared
  across users: where it is cached, what invalidates it, and what must never
  be served stale or across users); what is **batchable** (N+1 queries, several
  requests that could be one, writes that could be bulk, independent calls that
  could run in parallel); what can be **paginated, limited or lazy-loaded**
  instead of loaded up front; which **indexes** the queries need and whether
  row level security policies slow them; what is worth **precomputing**
  (summary table, counter, materialized view) versus computing on read; what
  **bundle, image and rendering** cost the prototype implies (long lists,
  re-renders); what can leave the request path (**background work**, debounce,
  throttle, backoff); and what **perceived speed** tricks fit (skeletons,
  optimistic updates, prefetch). State the expected load and a budget, and how
  it will be measured after building (query plans, timings, a large seeded
  dataset). Findings feed back into the data and architecture passes: a new
  index or summary table is a data change, a cache layer may need an ADR.
- **Specs** (`specs.md`): see below.

### Prototype the UI

Skip this only when the plan has no screens (then the UI pass says
`Not applicable:` as usual). Otherwise, in the UI interaction pass, write one
self-contained `prototype/index.html` (inline CSS and JS, fake data, no build
step or dependencies) covering the flows from the product pass:

- Make it look like the app, not a generic mock. Read the project's styling
  (stylesheets, theme and design tokens: colors, type, spacing, radii), its
  design language and pattern docs, and the existing components and component
  specs, then reproduce them in the prototype: same markup structure and
  class names or tokens where practical, same component look and behavior for
  buttons, lists, forms, dialogs and navigation, and glossary wording for
  labels. Where the plan needs a component the app lacks, build it from the
  app's existing pieces and flag it as new (it needs its own component spec).
  Reuse is what makes the layout and interaction answers carry over to the
  real build. Do not polish beyond that; it is a sketch to click through. It
  should look close to the app, but it will not be 1:1, and the user should
  be told so up front.
- Keep feedback on the big pieces: what is on the screen, how it is
  arranged, and how the flow moves. If the user asks for minor tweaks to
  spacing, font, exact colors, alignment or similar, say that this is only a
  prototype, those details come from the real components and styling in the
  build, and the time is better spent on layout and interaction. Do not make
  the change unless it affects a layout or interaction decision. If it does,
  make it and record the decision.
- Make it respond at narrow and wide widths, and include the empty, loading,
  error and no-access states, not just the happy path. If there are several
  roles, add a simple role switcher so each one's view can be checked.
- Open it for the user (e.g. `open prototype/index.html`), then iterate in
  rounds: they react, you change it, until layout and interactions are
  settled. Ask specific questions ("does the filter belong above the list or
  in a sheet?") rather than "thoughts?". Record each settled decision in
  `reviews/ui-interaction.md` and each open one in `questions.md`.
- Treat what the prototype reveals as findings: data it needs that the plan
  lacks, steps the use cases missed, states with no owner. Update `plan.md`
  and the product use cases, and note which later passes are affected.

The prototype is a design aid, not code to ship: the steps build the real
screens from the project's components and specs, never by porting the
prototype. It is deleted with the plan folder. Share it as an artifact only if
the user wants others to look at it.

### Finding the roles

Do not assume a role list; every project has its own. Build it from the
project, in this order, and cite where each came from:

0. The project's roles document (see [[define-roles]]: `docs/roles.md`, or the
   file its agent-instructions name). Treat it as the authoritative list and
   start from it; the steps below only fill gaps. If the project has none,
   run [[define-roles]] to create one before the product pass relies on it.
1. The agent-instructions file and the product overview (e.g. `CLAUDE.md`,
   `docs/overview.md`), and any ADR or doc about roles, permissions,
   authentication or anonymous access.
2. The glossary (nouns for people, such as Student or Coach) and the specs'
   "only reachable by" statements.
3. The code or schema that actually distinguishes them: role columns, policy
   names, route guards.

Always include the **anonymous visitor** if the product allows browsing
signed out, and note whether roles are exclusive or additive (one person can
be several). Show the user the resulting list in the first round of
questions and let them correct it: a role the docs never name but the plan
needs (e.g. a student of one particular coach) is a question, not an
assumption. Record the confirmed list in `plan.md` under "Roles" (referencing the
roles document rather than copying it), and have
the product pass walk the use cases for every role, noting for each use case
what a role that should not have access sees. Roles the plan introduces or
changes are called out as decisions, and updating the roles document
([[define-roles]]) is a step of the plan.

### ADRs are part of the plan

Part of the work may be a decision that deserves an ADR. Write it **in the
plan's `adr/` folder**, in the project's ADR format and numbering (read its
existing ADRs first; use the next free number, noting that another change may
take it before this plan lands), not in the project's real ADR directory: until
the plan is built the decision is a proposal and may change. Confirm with the
user first if the project requires that before writing an ADR. Mark each draft
`Status: proposed` (or the project's equivalent) and list it in
`reviews/architecture.md` with where it will land. Later passes may add or
overturn ADRs; keep the drafts current. The step that implements the decision
moves the ADR into the real ADR directory (renumbering if needed, fixing links
to it, and setting its status to accepted) in the same change.

### Specs are part of the plan

Once the product and UI passes (including the prototype) have settled behavior, think through which
specs the work needs (page, workflow and component specs, and updates to
existing ones) and **draft them in the plan's `specs/` folder**, in the
project's spec format and wording rules (use [[new-spec]] and its templates;
for a change to an existing spec, draft the new text in full). Do not put
drafts in the project's real specs directory: they have no tests yet and the
coverage check would fail. Then run the specs pass, which reviews the drafts
for: every use case from the product pass covered by a spec bullet; each
bullet testable and describing behavior, not a click-by-click script;
glossary wording; every page and workflow draft carrying `roles:` front
matter (the roles document's headings, or `any`) that matches the roles in
the plan's use cases; reusable pieces split into component specs; and nothing in
a spec the plan does not build. List in `specs.md` each draft with where it
will land. The steps move each draft into the real specs directory together
with the test that implements it ([[reconcile-e2e-specs]]).

A pass that truly does not apply still gets its file with `Not applicable:`
and the reason, so skipping is a visible decision.

Each review file lists findings with a severity (blocking, should-fix,
note) and, for each, what was decided. A finding changes the plan: update
`plan.md` or `steps` and add any new question to `questions.md`, then ask the
user. A finding that reopens an earlier pass means re-running that pass.

After the last pass, do a **consolidation read**: read every file together
for contradictions, gaps and anything a pass assumed that another overturned,
and note the result at the end of `plan.md`.

### 4. Write `steps.md`

Only now, break the work into ordered steps. Each step should be small
enough to build and verify on its own, say what it changes, name the specs,
tests and docs that ship with it (per the project's own rules), and list what
it depends on. Name the prototype's settled decisions in the steps that build each screen. Include the move of each draft spec into the real specs directory with its
test, and the move of each draft ADR into the real ADR directory with the step
that implements it. Mark which steps could be deferred as separate todos.

### 5. Ask for approval

Present a short summary: the goal, the decisions that matter, the findings
that changed the plan, the steps, and anything still uncertain. Ask for an
explicit go-ahead. Set `Status: approved` only after the user says yes in
chat. Any later change that alters scope, a decision or a step, sends the
plan back to `reviewing` for the passes it affects.

### 6. Execute

Set `Status: executing`. Work one step at a time, in order, following the
project's normal rules (change approval, tests, specs, commits). Tick the step
off in `steps.md` when it is built and verified. If a new decision turns up,
stop, add it to `questions.md`, and ask before continuing. If the work
drifts from the plan, update the plan first and say so.

### 7. Finishing

Delete the plan's folder in the same change that completes its last step.
Anything that outlives the plan goes where it belongs: decisions into the
ADRs already moved from `adr/` (a decision that only surfaced during
execution gets a new ADR, confirming with the user first if the project
requires it), behavior into specs, and any step the user chose to defer into
a todo via [[track-deferred-work]].

## Resuming and listing

When the user mentions a plan, or starts work in an area with an existing
plan, read `plan.md` first and report its status, open questions, and next
step before doing anything else. Do not skip ahead past an unrun pass.
