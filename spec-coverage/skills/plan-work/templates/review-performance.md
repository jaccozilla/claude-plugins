# Performance review

Pass run: <date>. Read: <plan files, the UI interaction, architecture and data reviews, the prototype, and the project's performance notes, existing caching and query patterns>.

## Hot paths and expected load

<The screens and operations users hit most or that touch the most data: how often, how much data (rows per list, payload sizes, growth over time), and the budget for each (e.g. time to interactive, query count per screen).>

## Round trips and batching

- Requests or queries per screen or action, and any N+1 (a query per row, a fetch per item in a loop): <...>
- What can be fetched together (joins, a view or function returning the shape needed, one request instead of several), run in parallel, or written in bulk: <...>
- What can be paginated, limited or loaded lazily instead of loaded up front: <...>

## Caching

| Data | Changes | Cache where (client, CDN, database, none) | Invalidated by |
| --- | --- | --- | --- |
| <...> | <how often, and who changes it> | <...> | <event, TTL or never> |

- Data that must never be served stale, or cached across users: <...>

## Database

- Indexes the queries in the data review need, and any that would not be used: <...>
- Policies or functions that could slow a query (per-row subselects in row level security, unindexed policy columns): <...>
- Heavy aggregates worth precomputing (materialized view, counter column, summary table) versus computing on read: <...>

## Client and delivery

- Bundle and asset weight, code splitting, image sizes and formats: <...>
- Rendering cost: large lists (virtualize or paginate), re-renders, work that blocks input: <...>
- Perceived speed: skeletons, optimistic updates, prefetching the likely next screen: <...>

## Background and rate limits

<Work that should leave the request path (queues, scheduled jobs), plus debounce, throttle and retry/backoff on the client, and limits on expensive endpoints.>

## How we will know

<Measurements to take after building (query plans, timings, payload sizes, a seeded large dataset to test with) and the numbers that would count as a regression.>

## Findings

- **[blocking | should-fix | note]** <Finding.> Decision: <...>.

## Result

<Will this perform well at the expected load? Which questions did this pass add?>
