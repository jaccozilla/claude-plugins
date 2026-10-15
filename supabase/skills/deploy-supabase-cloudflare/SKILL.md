---
name: deploy-supabase-cloudflare
description: Deploy a project backed by hosted Supabase and Cloudflare (a static site on Cloudflare Pages, optionally a proxy Worker) from a developer machine with the supabase and wrangler CLIs, including resetting or pushing the hosted database. Use only when the user asks to deploy, publish, or reset the hosted Supabase project, or asks how a manual deploy works.
---

# Deploy hosted Supabase + Cloudflare from this machine

A CI deploy workflow (often a manual-dispatch `.github/workflows/deploy.yml`) is the normal route; this is the manual route when `gh` is unavailable or CI is not set up. A deploy can wipe the hosted database and publishes publicly, so do it only when the user asks and confirm the target first. Read the project's own docs first (`CLAUDE.md`, `README.md`, the deploy workflow) for its specifics: Supabase project ref (`supabase/config.toml`'s `[remotes.<name>]`), Cloudflare Pages project name and production branch, build command, and `.env` variable names. Do not guess them.

**Before starting:** everything must already be committed and pushed (don't deploy a dirty tree), and the user must confirm which Supabase project and which Pages project will be affected.

## Pre-launch vs launched

Check the project's docs for whether it has launched.

- **Pre-launch** (no real users or data): migrations may be edited in place, so a changed migration means rebuilding the hosted database with a reset rather than migrating it.
- **Launched:** migrations are append-only. Use `supabase db push` and never `supabase db reset --linked`.

## Steps

1. **Hosted database (only when migrations changed).**
   - Pre-launch: `echo y | supabase db reset --linked`. Confirm the output says it is seeding only the reference-data files from the remote's narrowed `[remotes.<name>.db.seed]` list — never the fixtures — then check `supabase migration list --linked` shows every migration on both sides. A trailing "failed to cache migrations catalog" warning is harmless.
   - Launched: `supabase db push`.
   - If the reset's seed step fails, don't rerun it. Seed through `supabase db query --linked -f <file>` in small chunks (see the `hosted-safe-migrations` skill).
2. **Build the production bundle** with the project's release build (for a Kotlin Multiplatform wasm app, for example, a `-Pbuildkonfig.flavor=release` distribution task), run in the background through the project's quiet wrapper if it has one. The release build reads its Supabase URL, anon key, and optional Worker URL from the gitignored `.env`. Sanity-check the output: the bundle must contain the hosted Supabase URL and no `127.0.0.1`/`localhost`. Compiled-to-wasm string literals live in the `.wasm`, not the `.js`; macOS `strings` lacks `-e`, so search the bytes with Python.
3. **Deploy to Pages:** `wrangler pages deploy <build output dir> --project-name <project> --branch <production branch>`. Passing the production branch is what makes it a production (not preview) deploy; it must match the Pages project's production branch setting. Then `curl` the printed URL and the project's `*.pages.dev` URL for a 200. Use the project-local `wrangler` (for example `worker/node_modules/.bin/wrangler`), which is already logged in on a configured machine.
4. **Proxy Worker** (a `worker/` directory): redeploy only when its code or its `SUPABASE_URL` changed (`cd worker && wrangler deploy`). Don't redeploy it otherwise.
5. **Clean up after the deploy.** A release build can write into the same build folders the dev server and tests use, so a dev server or test run started afterwards may silently serve the release bundle and talk to the empty hosted database instead of the local stack. Stop any running dev server, then run the project's clean task (for Gradle, a plain `./gradlew clean`; if the project runs Gradle through a wrapper script that writes its own logs under `build/`, run `clean` directly, since the wrapper's own files are deleted by it). The next build is a full rebuild.

## Afterwards

- The hosted project should hold only reference data (no fixture users, coaches, or photos). Local-only fixture scripts do not run against it.
- Never put the `service_role` key or the DB password in `.env` or the repo.
