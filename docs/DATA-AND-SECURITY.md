# Data and security

17 November 2026 design extension: [Starting country](STARTING-COUNTRY.md) specifies proposed seed/version/template records, stable coordinates, name snapshots, immutable generated base plus player deltas/tombstones, and fail-closed generator migration. Existing one-key/fenced transaction rules remain. No profile schema or persistence code changes in this task.

Status: authoritative gameplay and persistent profiles are confirmed. Schema, lease policy and limits are proposals D01/D05/D16. Platform API facts are sourced in [Technical architecture](TECHNICAL-ARCHITECTURE.md); protocols below are application designs, not built-in Roblox guarantees.

## Canonical data relationships

| Record | Key / main contents | Authority |
| --- | --- | --- |
| Player profile | `u:<userId>` in versioned standard store | Canonical private state and ownership lease |
| Country | Nested in profile: era ID, seed, generation version, clock, sectors, assets, demand, cash | One active country per player |
| Progression | Nested: lifetime totals, legacy points/upgrades, achievements, era history | Survives eras |
| Commerce (proposed, not implemented) | Nested outside country reset: temporary boost remainder, versioned purchase records and entitlement verification metadata | Server transactions; Roblox is source of pass ownership; survives eras |
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

## Energy Shop persistence and authority (design only)

Owner-confirmed product constraints are in [Economy](ECONOMY-AND-REBIRTHS.md#energy-shop-and-double-income--design-only), D21–D23. The following is a proposed protocol, not implemented commerce. It must be tested against the existing session fencing, atomic profile mutations and budget limits before sale.

Persist commerce outside the resettable country: versioned offer ID, temporary benefit purchase operation ID, remaining active milliseconds (0–1,800,000), checkpoint/sequence and activation state; bounded recent purchase results; verified pass ID/user ID/source/time for reconciliation. Store remaining time, not an offline expiry timestamp. Do not persist client clocks or a mutable client-provided income factor. No raw payment details/Robux balance belong in the game profile. A cached ownership record is evidence to reconcile, not an independent purchasable entitlement store.

### Credits purchase

1. Server validates session, catalogue offer/version, request shape/rate, current authoritative price, sufficient unencumbered Bank balance after the protected reserve, no active temporary benefit and no verified permanent ownership. Ownership Unknown blocks purchase rather than charging someone who may already own the pass.
2. Return a bounded-lived server quote containing product, exact Credits price, duration, eligibility and revision. Confirm intent includes quote ID and stable operation ID, never a client price, multiplier or remaining duration.
3. Serialize the command with country settlement. In one fenced profile mutation debit Credits, create the 1,800-second benefit and record the result. Report success only after durable confirmation; keep activation pending rather than consuming time during an unconfirmed grant.
4. If the service response is ambiguous, reconcile the same operation ID. Never charge again to repair a lost response. Reject stale epochs/sequence numbers even after bounded cached results are evicted. Reconnect returns the committed benefit/result without duplicating it.

All grant/debit transformations are pure; no marketplace call or remote send inside UpdateAsync. A new legitimate purchase after expiry has a new operation ID, not a replayed prior grant. Rebirth preserves the commerce subtree and snapshots its current remainder in the reset transaction.

### Timer and income checkpointing

The server measures monotonic active elapsed time and applies the eligibility predicate in Economy. Clients receive display snapshots (remaining duration, active/paused/permanent state, revision), not authority to pause/extend. Large/discontinuous deltas cannot advance arbitrary rewards. On known country suspension freeze both progression and duration; on reconnect resume from the canonical remainder. Offline UTC differences never subtract time. Ordinary menus do not pause active online simulation time (D30); only actual server-known simulation suspension changes eligibility.

Every durable checkpoint that records boost-derived income or a later spend must include the corresponding consumed duration in the **same profile revision**. Split activation/expiry intervals deterministically. Ordinary autosave may roll back uncommitted income and consumed duration together after a crash; it must never retain the income while restoring that time. Critical purchases, construction, era resets and rewards snapshot both before durable acknowledgement. Publish rankings/projections only from committed records. Server ownership epoch fences stale shutdown writes.

This is a proposed bounded rollback model, consistent with existing autosave semantics, not a claim that crashes preserve every last second of progress. Verify economic replay safety across spending and every external effect; if tests reveal exploitable rollback or unacceptable lost progress, require a stronger durable-window protocol before commerce. Do not solve it by writing every second without budget evidence. Define maximum rollback exposure and checkpoint cadence in the live-commerce design review. Failed durable grant must leave either old balance/no benefit or new balance/full benefit, never a charged player with no entitlement.

### Permanent Game Pass

Use a separately configured allowlisted pass for this experience; no IDs are chosen here. Client UI may request current player-appropriate price for display and deliberately open the native prompt after review. The server verifies ownership through Roblox, including on join and following purchase completion. Never accept a client success flag, fake receipt, pass ID or claimed Robux debit as authority. A completion notification triggers authoritative reconciliation, not repeated grants.

Price-loading failure, off-sale product, cancellation and ownership-check failure are separate UI states. Unknown ownership prevents duplicate prompts/temporary purchases; retain existing verified evidence for reconciliation and do not erase it because an API call failed. The duration/benefit policy during an ownership outage needs explicit approval: a safe proposal is to continue already server-verified session ownership, while new unresolved ownership shows Pending verification without fabricating success. Roblox remains the ownership source; game save recovery must not make a previously purchased pass permanently disappear.

Both sources reduce to a single factor of 1 or 2, never multiplication of flags. When permanent ownership arrives during a temporary boost, apply the owner-confirmed dormant-remainder policy (D31) atomically with verification state; no automatic refund or extra reward is assumed. Current APIs/pricing references are in [Components](GUI-COMPONENT-SPEC.md#roblox-integration-boundary-verified-15-november-2026). Credits purchases use our ledger; pass purchases use Roblox's pass lifecycle, not an invented developer-product receipt flow.

### Required adversarial cases

Duplicate confirms; stale quotes; two concurrent purchases; forged price/duration/ownership; purchased pass while Credits request is pending; failed ownership lookup; cancellation; success with lost response; expired lease and stale server resumption; disconnect during grant; crash after income but before save; spend after a boost interval; reconnect/era reset at expiry; repeated pause/resume; timer rollback; version migration; max-money caps; mismatched player/offer; off-sale/changed/personalised price; outside-experience pass acquisition. Assert no double debit/grant, no 4× income, no duration loss offline, and no retained income with replayed consumed time. Actual isolated platform tests are required before production commerce.

## Migration, recovery and privacy

Schema migrations are pure ordered version steps, tested against saved fixtures and producing validated new state before write. Preserve a recovery path via platform versions and explicit pre-migration backups where needed; do not assume each autosave is a permanent backup. Unknown future schema is rejected without overwrite. Balance migrations separately identify whether old assets retain their definition version or adopt new values.

Support an operator recovery procedure: identify affected user/revision, stop conflicting session writes, inspect a known-good version in a test environment, validate migration/references, restore with a new revision and reconcile derived projections. Restoration may need event contribution adjustment review; never automatically subtract from monotonic event buckets.

Retain only game-related data. Public fields are explicitly allowlisted; raw text, lease tokens and anti-exploit diagnostics stay private. Account/data deletion must cover canonical saves, public indexes, event membership references and archives according to applicable platform requirements verified before release. A public profile is not permission to expose unrelated user data.

## Acceptance

P3 gates saving; P8/P9/P11 extend critical transactions. Tests inject concurrent sessions, lease expiry, retry callbacks, ambiguous success, full queues, serialization limits, old schemas, invalid references and lost shutdown saves. Critical claim/reset tests prove either old state or complete new state after reload, never mixed state or duplicate rewards. Studio/live isolated-universe tests remain required in addition to mocks.
