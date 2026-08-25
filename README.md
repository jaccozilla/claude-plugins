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
    page/screen or workflow template, before an implementing test exists.

## Consuming this marketplace

From any project (or globally), in Claude Code:

```
/plugin marketplace add jaccozilla/claude-plugins
/plugin install spec-coverage@jaccozilla-plugins
```

While iterating locally (both repos checked out as siblings), you can point at the local path instead so edits take effect without a git round-trip:

```
/plugin marketplace add ../claude-plugins
```

## Adding a new plugin

Create a new subdirectory with its own `.claude-plugin/plugin.json` (name, version, description) and `agents/`/`skills/`/`commands/` as needed, then add an entry to `.claude-plugin/marketplace.json`'s `"plugins"` array.
