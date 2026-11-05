---
name: lint-fix
description: Find problems with IntelliJ's inspections (through the IntelliJ MCP server's lint_files tool), fix them, then format the files with IntelliJ's code style (reformat_file). Defaults to the files changed in git; pass "all" to cover every source file in the project, or pass explicit paths. Use when the user asks to lint, fix lint errors or warnings, clean up IDE warnings, or format and lint the code.
---

# Lint, fix, format (IntelliJ)

Runs IntelliJ's own inspections and code style through the IntelliJ MCP tools (`mcp__idea__lint_files`, `mcp__idea__reformat_file`). The result should match what the IDE shows as squiggles and what "Reformat Code" produces.

## Arguments

- No argument: the files changed in git (modified, added, renamed and untracked), from `git status --porcelain`.
- `all`: every tracked source file in the project (`git ls-files`) plus untracked files that are not ignored.
- One or more paths or directories: just those (a directory expands to its tracked files).

## Prerequisites

- The IntelliJ MCP tools must be available (load them with ToolSearch `select:mcp__idea__lint_files,mcp__idea__reformat_file` if they are deferred) and the project must be open in the IDE. If the tools are missing or every call fails because no project is open, stop and tell the user; do not fall back to another linter.
- Always pass `projectPath` (the working directory) to the IntelliJ tools.

## Steps

### 1. Pick the files

- Build the list from the argument above. Make paths project-relative.
- Drop deleted files, anything under `build/`, `node_modules/`, `.gradle/`, `.idea/`, generated sources, lock files, and binary files (images, fonts, archives). Keep types the IDE inspects: `.kt`, `.kts`, `.java`, `.xml`, `.sql`, `.json`, `.yaml`/`.yml`, `.toml`, `.properties`, `.md`, `.html`, `.css`, `.js`/`.ts`, `.sh`.
- If the list is empty, say so and stop.
- In `all` mode, state the file count. If it is more than about 50, ask the user to confirm before going on (the format step can touch every one of them).

### 2. Find problems

- Call `lint_files` in batches of about 20 files with the default `min_severity` (`warning`).
- Handle every entry explicitly:
  - `timedOut: true` with no problems: the file is **not** known to be clean. Retry it once on its own with a larger `timeout`; if it still times out, report it as not checked.
  - `notAnalyzedReason`: report the file as not analyzed with the reason. Do not treat it as clean.
  - Top-level `more: true`: the batch is incomplete. Re-run for the files that have no entry yet.
- Collect the problems per file, errors first.

### 3. Fix problems

- Fix each problem by editing the code, errors before warnings. Read the file around the reported line and column first (positions are 1-based) and fix the cause, in the style of the surrounding code.
- Do not silence a problem with `@Suppress`, a `noinspection` comment, or by deleting code that is in use. If a fix would change behavior, touch public API, or is a judgement call, leave it and list it for the user.
- After each round, re-run `lint_files` on the files you edited. Repeat until they are clean, at most 3 rounds; whatever is left goes in the report.
- Fixing one file can create problems in another (for example removing an unused declaration that a test used). Re-lint any other file you touched.

### 4. Format

- Run `reformat_file` on every file in scope that is formatted by the IDE: in the default and path modes, the files you fixed plus the changed files; in `all` mode, every file in scope.
- Skip files that were not analyzed and non-source files such as `.md` unless the user asked for them to be formatted.
- Run `lint_files` once more on the reformatted files to confirm formatting introduced no problems.
- Do not run a Gradle formatter or any other tool: the format rules are IntelliJ's.

### 5. Report

Give a short summary: files checked, problems fixed (grouped by kind), problems left with file, line and reason, files reformatted, and any files that timed out or were not analyzed. Do not commit; leave the changes in the working tree.
