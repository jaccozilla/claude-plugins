# claude-plugins

A Claude Code plugin marketplace: shared agents/skills/commands consumed by other repos (knb, kite-compare) via `/plugin marketplace add`. See README.md for structure and consumption details.

## Git

- Never run `git push` unless the user explicitly says to push in that turn. Committing locally is fine without asking each time, but pushing to the remote always needs an explicit go-ahead first.

## Making changes

- Each plugin subdirectory (e.g. `spec-coverage/`) is independent — a change to one shouldn't require touching another plugin's files.
- Adding a plugin means both a new subdirectory *and* an entry in `.claude-plugin/marketplace.json`'s `"plugins"` array — don't forget the second half.
- Agent/skill/command files here follow the same format as a project's own `.claude/agents/`, `.claude/skills/`, `.claude/commands/` — if you're extracting one from knb or kite-compare, the file can usually move over unchanged.
