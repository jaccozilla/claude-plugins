# claude-plugins

A [Claude Code plugin marketplace](https://docs.claude.com/en/docs/claude-code/plugins) — shared agents, skills, and commands consumed across multiple repos (currently [knb](https://github.com/jaccozilla/knb) and [kite-compare](https://github.com/jaccozilla/kite-compare)).

`.claude-plugin/marketplace.json` lists every plugin in this repo. Each plugin is its own subdirectory with its own `.claude-plugin/plugin.json` manifest, installed independently.

## Structure

- `spec-coverage/` — skills for maintaining markdown-spec-driven e2e tests
  linked via `@Spec` annotations, paired with the
  [gradle-plugins](https://github.com/jaccozilla/gradle-plugins) `spec-coverage`
  convention plugin's `verifySpecCoverage` task.
  - `skills/reconcile-e2e-specs/SKILL.md` — reconciles markdown specs against
    their implementing tests: drafts a missing test for a spec, drafts a
    missing spec for a test, and flags specs whose description has drifted
    from what the test actually does.
  - `skills/new-spec/SKILL.md` — scaffolds a brand-new spec file from a
    page/screen, workflow, or component template, before an implementing
    test exists.
  - `skills/track-deferred-work/SKILL.md` — records work the user
    explicitly defers as a file in the project's deferred-work directory
    (e.g. `docs/todo/`), surfaces a stale entry once its blocking
    condition resolves, and — only with explicit user sign-off — files a
    stuck failing test under a `test-failures/` subdirectory.
- `design-system/` — skills for generating and applying Material 3 color
  schemes.
  - `skills/build-color-scheme/SKILL.md` — generates a full Material 3
    light/dark color scheme from a seed color or an image via the
    [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/)
    web tool, then applies it into the project's own theme file.

## Consuming this marketplace

From any project (or globally), in Claude Code:

```
/plugin marketplace add jaccozilla/claude-plugins
/plugin install spec-coverage@jaccozilla-plugins
/plugin install design-system@jaccozilla-plugins
```

While iterating locally (both repos checked out as siblings), you can point at the local path instead so edits take effect without a git round-trip:

```
/plugin marketplace add ../claude-plugins
```

## Adding a new plugin

Create a new subdirectory with its own `.claude-plugin/plugin.json` (name, version, description) and `agents/`/`skills/`/`commands/` as needed, then add an entry to `.claude-plugin/marketplace.json`'s `"plugins"` array.
