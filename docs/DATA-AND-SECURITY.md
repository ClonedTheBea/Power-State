# Data and security

Status: authoritative gameplay and persistent profiles are confirmed. Schema, lease policy and limits are proposals D01/D05/D16. Platform API facts are sourced in [Technical architecture](TECHNICAL-ARCHITECTURE.md); protocols below are application designs, not built-in Roblox guarantees.

## Canonical data relationships

| Record | Key / main contents | Authority |
| --- | --- | --- |
| Player profile | `u:<userId>` in versioned standard store | Canonical private state and ownership lease |
| Country | Nested in profile: era ID, seed, generation version, clock, sectors, assets, demand, cash | One active country per player |
| Progression | Nested: lifetime totals, legacy points/upgrades, achievements, era history | Survives eras |
| Social identity | Nested raw customization and safe selections | Sanitized before publication |
| Event participation | Nested instance records, cumulative meters, claims and outbox revisions | Canonical personal event state |
| Public profile | `u:<userId>` in separate standard store | Derived sanitized projection |
| Rankings | One OrderedDataStore per metric/version, user ID keys | Derived, eventually consistent indexes |
| Event bucket / snapshot | Event-prefixed standard-store keys | Durable reconciled contribution index and milestone status |
| Archive page | Stable user/type/page ID, compact completed records | Durable history referenced only after write success |
| Temporary coordination | MemoryStore TTL keys | Cache/lease hints only; never sole reward/save authority |

Canonical profile envelope: schemaVersion, balanceVersion, countryRevision, sessionEpoch, lease owner/token/expiry, last committed operation IDs, lastSavedAt UTC, country, progression, customization, tutorial and events. CountryRevision increases across eras. IDs are strings or checked bounded integers; save tables contain serializable values only, no Instances/functions or cyclic references.

Assets reference catalog definition IDs and owned sector IDs; lines reference node IDs. Demand aggregates reference settlement IDs; work orders reference assets/teams; policies/research reference versioned definitions. Validate references on load and migration. Never silently drop an invalid asset and continue billing as if the save were healthy; quarantine for recovery with a diagnosable error.

## Load and session ownership

Acquire a lease using a profile-key UpdateAsync: if no profile exists after a successful service call, initialize the starter state once; if another unexpired owner exists, wait/retry with a bounded user-facing status; if ownership is free/expired, assign a new token and increment session epoch. A failed read/write is not “new player.”

Proposed lease: 180 real seconds, refresh/save target every 60 seconds with jitter and available budget. All writes verify owner token, epoch and expected revision inside the update callback. A server that cannot confirm lease renewal before a safety margin stops economic mutations and reward grants; a resumed stale server must not overwrite a newer owner. On token mismatch discard local unsaved state and require reload. These times need failure testing and budget profiling.

Do not force-steal an unexpired lease just because a second session wants access. On normal exit save and release ownership together; on crash wait for expiry. PlayerRemoving and BindToClose are best-effort final opportunities, not a guarantee. Budget shutdown writes across active profiles and do not start new optional publication work.

## Atomic mutation and persistence

MVP stores the entire bounded active country plus critical progression in one key to keep purchases, era reset and rewards atomic. Runtime commands and steps are serialized per country and produce a new revision. Routine changes autosave; critical rewards and era reset require durable confirmation before reporting success. Save snapshots are immutable while a write is in flight; newer local revisions queue behind them, not mutate a callback's captured table.

UpdateAsync callbacks may be retried and must not yield or perform external effects. Prepare pure transformations; do not send remotes, grant items externally or publish news inside a callback. After success inspect the returned committed operation/revision and then schedule derived work. An ambiguous service response is resolved by rereading/retrying the same operation ID, not inventing a replacement grant. These callback semantics are documented in [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores).

Ordinary command IDs use a bounded per-session sequence window and cached results; reject IDs below the accepted window rather than accepting an evicted request again. Persistent reward operations use permanent semantic claim keys (achievement ID, event reward ID, era ID). Keep only compact necessary claims and bounded recent generic transaction receipts. A stale command from a previous epoch is rejected even after reconnect.

Do not put active world chunks in separate keys until an approved multi-key commit protocol exists. Later candidate: immutable chunk versions, then atomic profile manifest switch, delayed garbage collection and startup repair. A half-written manifest must never become a valid load. This is deferred; seed-plus-deltas and active caps are the current storage strategy.

## Budgets and degradation

Proposed encoded active profile target below 512 KiB, soft alert at 384 KiB. This is deliberately an internal budget, not a claim about Roblox's maximum key size. Measure actual serialization before accepting construction or a new archive-heavy operation. Archive completed history; never truncate critical claims to squeeze a save through.

Use GetRequestBudgetForRequestType and budget-aware queues, bounded exponential backoff with jitter, request coalescing and maximum queued operations. Prioritize load/lease/save, then critical event recovery, then public projections/rankings/news. Never write every simulation tick or read a DataStore for every UI refresh. DataStore limits include entry, throughput and experience storage limits and may change; consult the [official limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits) at implementation time instead of copying old rate formulas into gameplay.

On persistence trouble, show last confirmed save, retry within limits and pause mutation before lease safety is lost. Do not overwrite with defaults. Public-service failures may leave stale profiles/rankings without interrupting ordinary local play. Queue growth is capped; collapse superseded projections to their newest revision.

## Security boundary

Remote intent envelope: protocol version, session epoch, request ID, expected revision, command name and typed parameters. Identity is the Player supplied by Roblox, never a payload user ID. Server allowlists commands and checks:

1. Payload type, field allowlist, depth, string length and array count before expensive work.
2. Finite numbers (reject NaN/infinities), integer coordinates where required and bounded ranges.
3. Ownership of every referenced object and country; no arbitrary Instance or path access.
4. Legal state transition, prerequisites, resources, server quote and current catalog price.
5. Per-player and per-command token buckets plus server-wide expensive-query budget.
6. Replay/epoch/revision validity and atomic spending/reward application.

Proposed starting limits: five mutating requests/second with burst ten, two viewport requests/second with coalescing, one public-profile request/second; payload ceiling 8 KiB plus command-specific smaller limits. Tune through normal touch/desktop use and adversarial tests. Remote event queueing is not permission to do unbounded graph work. Reject malformed requests without echoing unsafe text; record sampled diagnostics without logging private full profiles.

The [official client-server security guide](https://create.roblox.com/docs/scripting/security/client-server-boundary) requires server validation and rate limiting around client-triggered behavior. Shared Luau types help development but provide no runtime security. Clients may display replicated catalog prices but cannot declare payment, output, population, research completion or achievements.

## Migration, recovery and privacy

Schema migrations are pure ordered version steps, tested against saved fixtures and producing validated new state before write. Preserve a recovery path via platform versions and explicit pre-migration backups where needed; do not assume each autosave is a permanent backup. Unknown future schema is rejected without overwrite. Balance migrations separately identify whether old assets retain their definition version or adopt new values.

Support an operator recovery procedure: identify affected user/revision, stop conflicting session writes, inspect a known-good version in a test environment, validate migration/references, restore with a new revision and reconcile derived projections. Restoration may need event contribution adjustment review; never automatically subtract from monotonic event buckets.

Retain only game-related data. Public fields are explicitly allowlisted; raw text, lease tokens and anti-exploit diagnostics stay private. Account/data deletion must cover canonical saves, public indexes, event membership references and archives according to applicable platform requirements verified before release. A public profile is not permission to expose unrelated user data.

## Acceptance

P3 gates saving; P8/P9/P11 extend critical transactions. Tests inject concurrent sessions, lease expiry, retry callbacks, ambiguous success, full queues, serialization limits, old schemas, invalid references and lost shutdown saves. Critical claim/reset tests prove either old state or complete new state after reload, never mixed state or duplicate rewards. Studio/live isolated-universe tests remain required in addition to mocks.
