# Data and migrations review

Pass run: <date>. Read: <plan files, the security review, the existing schema, migrations and seeds, and the project's migration rules>.

## Schema

<Tables, columns, constraints, indexes and policies the plan adds or changes, and the migration that carries each.>

## Migration safety

- Hosted-safe rules applied (row level security in the same migration, search paths on functions, idempotent storage statements): <...>
- Existing data: <backfill, defaults, anything that could break a current row>
- Rollback or replacement before launch / after launch: <...>

## Seeds and fixtures

<Local seed data and test fixtures the plan needs; what must never reach a hosted project.>

## Findings

- **[blocking | should-fix | note]** <Finding.> Decision: <...>.

## Result

<Is the data model sound? Which questions did this pass add?>
