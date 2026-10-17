---
name: plan-work
description: Plan a large, multi-step piece of work as a folder under the deferred-work directory's plan/ subfolder (e.g. docs/todo/plan/<slug>/), iterating on it with the user and reviewing it in separate passes (code architecture, security and privacy, UI interaction, data and migrations) before any code is written. Use when the user asks for a plan, says a piece of work is too big or too uncertain for a single todo, wants to think through a feature before building it, or asks to review, revise, approve or execute an existing plan. Also use when a todo has grown into several steps with open design questions.
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
    architecture.md
    security.md
    data.md
    ui-interaction.md
    specs.md
  specs/           draft specs for the plan (pages, workflows, components)
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
- **Code architecture** (`architecture.md`): module and layer boundaries,
  where logic lives, what existing components, patterns and ADRs to reuse or
  extend, what is genuinely new and whether a new ADR is warranted.
- **Security and privacy** (`security.md`): who can see or change what, the
  authorization boundary (row level security, not UI checks), exposure of
  personal data, abuse and misuse cases, what is logged or cached.
- **Data and migrations** (`data.md`): schema, policies, indexes, seeds,
  hosted-safe migration rules, existing data, and rollback.
- **UI interaction** (`ui-interaction.md`): the design view of the flows the
  product pass found: entry points, narrow and wide layouts, empty, loading,
  error and permission states, existing patterns and component specs to
  follow, and wording against the glossary.
- **Specs** (`specs.md`): see below.

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

### Specs are part of the plan

Once the product and UI passes have settled behavior, think through which
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
it depends on. Include the move of each draft spec into the real specs directory with its
test. Mark which steps could be deferred as separate todos.

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
Anything that outlives the plan goes where it belongs: decisions that
deserve one into an ADR (confirming with the user first if the project
requires it), behavior into specs, and any step the user chose to defer into
a todo via [[track-deferred-work]].

## Resuming and listing

When the user mentions a plan, or starts work in an area with an existing
plan, read `plan.md` first and report its status, open questions, and next
step before doing anything else. Do not skip ahead past an unrun pass.
