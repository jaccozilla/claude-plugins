---
name: track-deferred-work
description: Record work the user explicitly defers ("do that later", "not now", "note it for when X happens") as a file in the project's deferred-work directory, instead of letting it evaporate once the conversation moves on. Also covers a stuck failing test — prompt the user before recording it as deferred, never do so silently — and surfacing a stale deferred-work entry when starting new work that just resolved its blocking condition. Use whenever the user defers something rather than dropping it, when a test failure can't be fixed and needs the user's decision, or when starting a task that might unblock previously deferred work.
---

# Track deferred work

When the user explicitly defers something — rather than just deciding not to
do it — record it as a file instead of letting it live only in the
conversation.

## Find (or establish) the project's deferred-work directory

Don't hardcode a path. Check, in order:

1. An agent-instructions file (`CLAUDE.md` or similar) for a directory it
   already documents (e.g. "`docs/todo/` — deferred work").
2. Whether `docs/todo/` (or a similarly named directory — `todo/`,
   `docs/deferred/`) already exists and has files in it, confirming the
   convention even if undocumented.

If neither turns up a convention, default to `docs/todo/` at the project
root and mention to the user that you're creating it there.

## Recording a deferred item

File name: a short kebab-case slug of the deferred thing (e.g.
`google-auth-default-avatar.md`). Contents:

- What the deferred work is.
- Why it's deferred — the actual blocking condition (e.g. "no real Google
  OAuth credentials configured yet"), not just "later".
- Where in the codebase it would naturally be wired up, so picking it back
  up later doesn't require re-deriving context.

Don't just mention the deferral in conversation and move on — the file is
what makes it durable.

## Picking work back up

When starting new work, check the deferred-work directory for an entry
whose blocking condition the current task just resolved (e.g. you're now
setting up the thing a todo was waiting on). Surface it to the user rather
than leaving it stale.

Delete the file once the deferred work is actually done, in the same
change that does it.

## Failing tests are not deferrable on your own judgment

A failing test is never something to quietly leave for later. If, after
real fix attempts, a failure remains — including a pre-existing one you
didn't cause, and including one that looks environment/harness-related —
name it explicitly (test class/name, what you tried, and why you're
stuck) and ask the user how they want to proceed. Never classify it as
out-of-scope or acceptable yourself.

Only if the user explicitly agrees to defer it, record it as a
deferred-work item in a `test-failures/` subdirectory of the deferred-work
directory (e.g. `docs/todo/test-failures/`, creating it if it doesn't
exist yet) — kept separate from other deferred work so a scan of that
subdirectory alone shows every test currently allowed to fail. Same file
format as above: what's failing, why it's failing (the real cause, not
"flaky"), and what fixing it would require. Don't create this file — or
otherwise treat a failing test as "noted for later" — without that
explicit go-ahead; a deferred-work entry is not a substitute for asking.
Do not report the task as complete while the test is still failing,
deferred or not.
