---
name: track-deferred-work
description: Record work the user explicitly defers ("do that later", "not now", "note it for when X happens") as a file in the project's deferred-work directory, instead of letting it evaporate once the conversation moves on. Also surfaces a stale deferred-work entry when starting new work that just resolved its blocking condition. Use whenever the user defers something rather than dropping it, or when starting a task that might unblock previously deferred work.
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
