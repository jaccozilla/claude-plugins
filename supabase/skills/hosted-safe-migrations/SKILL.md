---
name: hosted-safe-migrations
description: Rules for writing or editing Supabase migrations (anything under supabase/migrations/), storage buckets and storage policies, and seed data (supabase/seeds/, supabase/config.toml's seed settings), so they behave the same on a hosted Supabase project as on the local stack. Use before creating a table, policy, function, extension, storage bucket or seed file, and before seeding or resetting a hosted project.
---

# Hosted-safe migrations and seeds

The local Supabase stack and a hosted project differ in ways that only show up after deploying. Follow these when writing migrations and seeds, and when seeding a hosted project.

## Row Level Security

- Every `public` table needs RLS enabled **and** explicit `create policy` statements for each role/operation that should work — including public, read-only reference data (`for select using (true)`). Hosted Supabase enables RLS automatically on every new table (a project setting); the local stack does not, so a table with no RLS/policies works locally but breaks once deployed.
- A `grant` alone is not enough: with RLS on and no matching policy, `anon`/`authenticated` silently get **zero rows** back, not a permission error.
- Write `alter table <t> enable row level security;` plus its policies in the same migration that creates the table, so local behaves like hosted.
- A new table that stores information about a person (profile-like data) should get the same read policy as the project's other user-data tables, with owner-only writes. Check the project's existing policies and ADRs for the convention before inventing one.

## Functions

- Set `set search_path = ...` on every function (the Supabase linter flags a mutable search path). Include the schema extensions live in (`extensions`) if the body uses extension functions or operators.
- Every `SECURITY DEFINER` function in an exposed schema is callable through `/rest/v1/rpc/<name>` by whoever has `EXECUTE`. `revoke execute ... from public` and grant only to the roles that need it (`anon`, `authenticated`). A trigger function needs no grant at all: revoke it from `public, anon, authenticated`.
- A `SECURITY DEFINER` function that is meant to be an RPC must check `auth.uid()` (or an admin check) itself. The linter warning for these is expected; do not silence it by weakening the function.

## Extensions

- Create extensions in the `extensions` schema (`create extension if not exists <name> with schema extensions;`), never `public`. Reference their operator classes and functions through that schema (`extensions.gin_trgm_ops`) or put `extensions` on the function's `search_path`.

## Storage buckets and policies

- Anything a migration creates in a Supabase-managed schema (`storage`, `auth`) must be idempotent: `insert into storage.buckets ... on conflict (id) do update set ...;` (`do update` rather than `do nothing`, so a bucket that survived a hosted reset still picks up changed settings like `file_size_limit`), and `drop policy if exists "<name>" on storage.objects;` right before each `create policy ... on storage.objects`. `supabase db reset --linked` only wipes the project's own schemas like `public`, so buckets and storage policies survive it and a plain `insert`/`create policy` then fails with a duplicate-key / "already exists" error partway through, leaving the hosted DB half-migrated. A local reset recreates the whole container, so this never shows up locally.
- A public bucket serves object URLs without any `SELECT` policy. Do not add a broad `SELECT` policy on `storage.objects` for it: that lets any client list every file in the bucket. Give writers an owner-scoped `SELECT` instead (Storage reads a row before deleting or replacing it), for example by matching the first path segment (`storage.foldername(name))[1]`) to `auth.uid()`.
- If a policy is removed in a later edit, keep its `drop policy if exists` line so a hosted project that already has it loses it too.

- For a bucket used through `com.jaccozilla.kmp:supabase-utils`'s `PublicImageStorage`, also follow that module's `public-image-buckets` pattern (object paths, owner policies, what the integration test should cover). Run `./gradlew syncSharedDocs` in the app, then read `build/shared-docs/INDEX.md`; it lists the pattern for the module version the app uses.

## Seed data

- Split seeds into reference data every environment needs and fake local-only fixtures. Only reference data may reach a hosted project.
- Give each hosted project a `[remotes.<name>]` block in `supabase/config.toml` (`project_id = "<ref>"`) narrowing `[db.seed].sql_paths` to the reference files, with `enabled = true` in that same `[remotes.<name>.db.seed]` table. A remote block disables seeding unless it sets that itself. The CLI applies the block automatically when the linked project matches and prints `Loading config override: [remotes.<name>]`.
- Never run `supabase db push --include-seed` against a project without such a block: it would push the local fixtures too.
- Make every reference-data seed idempotent (`on conflict ... do nothing`) and add it to every `[remotes.*.db.seed].sql_paths` list.
- **Seed a hosted project through the Supabase Management API, never over a direct Postgres connection.** Use `supabase db query --linked -f <file.sql>` (HTTPS), not the CLI's direct-Postgres paths: the seed step of `supabase db reset --linked`, `supabase db push --include-seed`, or anything with `--db-url`/the pooler. The direct connection is unreliable for large seed files (batch timeouts and `failed SASL auth` against the pooler have left hosted tables empty). Seed in small chunks (a few idempotent `insert ... on conflict ... do nothing` statements per call) with retries, and verify afterwards by counting rows over the hosted REST API.
- If a `db reset --linked` ends with the seed step failing, don't rerun the reset; seed through `db query --linked` as above.

## Credentials

- The anon key and project URL are not secret (Row Level Security is the security model, and the key ships in every client bundle), so committing them is fine.
- The `service_role` key, the DB password, and any connection string with credentials bypass RLS and must never be committed or put in a repo `.env`. They go in CI secrets or a gitignored local file, and only if something genuinely needs them.
