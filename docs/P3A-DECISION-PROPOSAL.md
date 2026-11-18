# P3a — Persistent countries: decision proposal

17 November 2026. **Subsequently approved D94–D99.** The owner separately authorized pure implementation and fake/Test preparation; [current implementation evidence and real-service approval gate](P3A-VALIDATION.md) supersede the pending status below. This document preserves the reviewed contract and its original design-stage wording. No persistence code, DataStore calls, settings changes or publishing. P2b.1 passed available local multiplayer validation; its same-account reconnect, pending-generation disconnect and hosted/device gaps remain open. This proposal prepares those persistence-specific acceptance checks, not a claim that they passed.

## Scope and approval boundary

Persist one procedural country per Roblox player, using the existing P2b v1 world and simulation. Preserve P2a fixtures, climate/fairness/demand arithmetic, the two-second generation watchdog, current graph limits and Native renderer. Test universe **10776833313** only; Production **10776828545** remains untouched. An approved design is not permission to enable Studio API access, publish a place, or run hosted tests. Those require an explicit implementation/environment authorization.

This separates **P3a persistence** from the broader P3 economy/construction milestone. No spendable income, operating-cost debits, building, sector buying, growth, planning, weather events, monetisation, public profiles or rankings. Existing nonspendable simulation estimates remain estimates. Existing session-only Test worlds and authored demos are not automatically imported into saves.

Sources: [starting country](STARTING-COUNTRY.md), [data/security](DATA-AND-SECURITY.md), [architecture](TECHNICAL-ARCHITECTURE.md), [economy](ECONOMY-AND-REBIRTHS.md), [foundation](PROCEDURAL-GAMEPLAY-FOUNDATION.md), [P2b](P2B-VALIDATION.md), [P2b.1](P2B1-VALIDATION.md), [testing](TESTING.md). All specific policy values below are **recommendations**, not approved gameplay rules.

## Owner decisions requested

| ID | Recommendation | Consequence / alternative |
| --- | --- | --- |
| D94 | One standard DataStore, `PowerStateProfilesP3aTest`, default scope, `u:<positive UserId>` key; schema v1 inside the value | Atomic active-country checkpoint. No per-chunk keys or silent store-name change on schema upgrade. Local negative Studio IDs use only a fake adapter. |
| D95 | 180-second lease; 60-second checkpoint/renew target with ±5-second jitter; freeze 30 seconds before confirmed expiry | Prefer safety over immediate reconnect. Never steal an unexpired lease; crash recovery may wait for expiry. These timings require fault/budget testing. |
| D96 | Whole-country checkpoints, no offline progression; controls acknowledge live application separately from durable save | Healthy rollback exposure is normally up to 65 seconds, but outages can extend it to the freeze boundary, approximately 150 seconds after renewal. No guaranteed zero-loss shutdown. |
| D97 | Retain exact P2b generator/demand v1 and curated-name snapshot; separate stable country ID from fresh session command epoch | Reconnect restores identity without replaying old commands. Unknown versions/corruption block load; never reroll or erase automatically. |
| D98 | Bank schema uses integer minor units, initially exactly zero; no earning/spending or funded-operation checks | Zero is a persistence placeholder, not final starter balance. Existing generation continues without fuel billing as in P2b. Later economy approval chooses funding and prices. |
| D99 | Narrow injected, dependency-free persistence adapter; 256 KiB P3a hard encoded limit; manual reviewed recovery | Adds fault-test responsibility. No third-party package installation. Keep general 384/512 KiB proposals for later phases; do not enable larger world caps. |

Approve or amend these six decisions and separately authorize implementation stages before any persistence code is written. Real-service tests additionally need a verified Test configuration and test-account/key plan. Do not approve the full economic P3 scope by approving P3a.

## Proposed canonical schema

One JSON-compatible bounded table, numeric values finite, integer fields checked before arithmetic, arrays dense and maps string-keyed. No Instances, metatables, functions, cycles, raw client tables or mixed numeric/string dictionary keys. Key owner must equal the server-authenticated Player.UserId and stored ownerUserId.

| Record | Fields and semantics |
| --- | --- |
| Envelope | `schemaVersion=1`, `ownerUserId`, immutable `createdAtUtc`, `lastSavedAtUtc`, monotonically increasing `profileRevision`, `countryRevision`, `sessionEpoch`, `lease`, `lastCommit`, `country` |
| Lease | `ownerSessionId` server GUID, diagnostic `jobId`/`placeId`, `fence` equal to sessionEpoch, `expiresAtUtcMs`; absent when released. Server GUID is necessary because JobId alone is not a reliable unique Studio session identifier. |
| Last commit | `operationId`, `kind`, `fence`, `baseProfileRevision`, `committedProfileRevision`, `countryRevision`; one bounded receipt, retained across release/acquisition until superseded |
| Country identity | Permanent country GUID; 32-character lower-case hex seed; `generationVersion=1`, `climateVersion=1`, `demandVersion=1`, `startTemplateVersion=1`, `namePoolVersion=1`, starter `candidate` 0–8 and `fallback`; versioned P2b network-definition identifier |
| Settlement | Stable generated ID, `nameId`, curated safe name snapshot, population 1000, demand-bus ID, integer-sixteenth coordinates and owned-sector reference. No free-text naming or development changes. |
| Infrastructure | Three starter nodes and two links, their semantic IDs, definitions, quantized coordinates, endpoint IDs and accepted capacities; generator ID and boolean `online`. Explicit canonical starter records checked against pinned regeneration; never infer network state from artwork. |
| Land | Exactly owned sector `(0,0)` in v1. Nine generated validation descriptors are not nine owned sectors. |
| Simulation | `simulationVersion=1`, completed step count, cumulative requested/delivered MWh, bounded reliability history and aggregates described below; no offline accumulator |
| Bank | `currency="Credits"`, `minorUnitsPerCredit=100`, `balanceMinor=0`, `earnedMinor=0`, `spentMinor=0`, `ledgerVersion=1`. P3a rejects nonzero values instead of silently zeroing them. No starting grant or transactions. |
| Future deltas | Explicit empty `builtNodes`, `builtLines`, `generatedOverrides`, `tombstones`, `constructionOrders`; `nextBuiltAssetSerial=1`. Nonempty records are unsupported in P3a. Future schema migration supplies capacities, quote/cost/operation IDs and reservations before enabling them. |

All integer counters have explicit nonnegative safe-integer validation (maximum 2^53−1, checked before increment); fail safely at exhaustion rather than wrap. Country IDs and operation/session GUIDs are bounded strings; normal asset ID limits remain 64 bytes. Display-name snapshots are curated and bounded to 64 UTF-8 bytes. Retain the approved signed world address domain and sixteenth-unit quantization. P3a permits only the current one settlement/three nodes/two links, not D05's future 16-sector/256-node graph.

Persist the immutable base recipe and explicit starter identities, not sampled terrain, fairness caches, GUI objects or camera pixels. Reconstruct terrain with the exact pinned version, compare candidate/fallback and starter records, then apply only approved mutable online/accounting state. A changed recipe/name pool must not move terminals or rename saved settlements. Resource/art versions are not invented as authoritative systems: a future resource version arrives in its own migration; cosmetic art revision stays outside gameplay authority.

`profileRevision` increments on every canonical write, including lease metadata. `countryRevision` increments only for completed simulation steps or accepted operational mutations. These are distinct from session-local transport revision, controlRevision, sequence and rate buckets. Session-local counters reset behind a fresh opaque command epoch on acquire (a separate server GUID, never the private lease owner token); the permanent country ID remains in the world descriptor and asset IDs. Existing P2a protocol behavior stays as its regression fixture. Future persistent-client adapters must stop assuming `snapshot.epoch == world.countryId`.

## Accounting and restore contract

Persist requested/delivered cumulative MWh together with the same completed step and generator state. Preserve the existing double-precision accumulation; do not round saved energy to displayed decimals or replace approved arithmetic with a new fixed-point model. Require finite nonnegative totals, delivered no greater than requested within existing tolerances, and history consistent with the completed step. Outage energy is requested minus delivered, not an independently accumulating counter. Do not label delivered energy as an independently measured lifetime-generation metric; future generation/export attribution needs its own design.

Save the exact bounded 1,440-entry reliability ring, historyIndex and windowRequested/windowDelivered values to preserve summation behavior. Validate ring length against min(step,1440), each pair, index and recomputed aggregates within the existing testing tolerance (absolute 10^-6 MWh plus 10^-9 relative). Never silently repair by replacing inconsistent aggregates. Use JSON round-trip/replay tests to establish actual numeric fidelity. The stored ring is application state, not unbounded history.

Loading performs **zero** advance steps. Rebuild the current report from the pinned network, saved online flag and demand at `max(completedStep−1,0)`, matching current P2b's last evaluated interval. The next step evaluates demand at completedStep and increments energy once. Starting fresh uses step 0. Immediate On/Off recomputes power but adds no energy. Persisted cumulative totals, ring and step are restored as one checkpoint; do not replay the last committed interval. Reset the wall accumulator on load/resume, so time offline, loading or lease-suspended creates neither demand nor energy. Electricity replay tests must cover step zero, midnight, ring wrap and an Off command between steps.

UI distinguishes live unsaved progress from the last confirmed checkpoint, and shows loading, save delay, suspended or unavailable honestly. A save-related freeze retains selected asset/camera where possible but blocks commands and simulation. Ordinary menu opening does not pause the grid.

## Session ownership and atomic initialization

All writes use an injected server-only adapter and profile-key UpdateAsync. No client may choose a key, seed, country ID, balance, online restore flag, lease, timestamp or revision. Existing strict On/Off intent validation remains; persistence adds an active-session/mutation-state guard. The server obtains identity from Player, not payload fields. Do not replicate profile envelopes, lease secrets or other players' records.

1. Serialize join attempts per user on this server. Before loading, admit at most eight profile sessions including still-closing sessions. A same-user reconnect waits for the previous local close attempt; it cannot create a second writer.
2. Prepare an immutable new-country candidate, identity/seed and initialization operation ID once per acquisition attempt, outside any DataStore callback. Use the existing bounded generator scheduler; discard unneeded candidates when an existing profile wins. Preparation failure makes the join unavailable and writes nothing.
3. The acquire callback distinguishes successful nil from every error. On nil only, atomically insert the validated complete starter profile and lease. On existing data, validate supported structure/owner, refuse corrupt/future data and refuse a foreign unexpired lease. If released or expired, increment the stored sessionEpoch, assign the prepared unique session owner and lease, preserving country state. Never overwrite an existing winner with this server's candidate.
4. Callback retry reuses the same prepared candidate and operation identity; no random generation, yielding, remotes, external calls or gameplay activation inside the callback. Use a fresh copied return value. Preserve platform user-ID associations/metadata deliberately rather than accidentally deleting them.
5. Verify the returned committed owner, fence, revision and remaining lease time. An error is ambiguous, not proof of a new account or failed initialization. Resolve the same operation before retrying with another identity. A repeated acquisition already committed under this owner returns its committed result rather than incrementing the fence again.
6. Reconstruct/validate the saved world under the acquired lease before activation. Generation/restore failure freezes access and releases only the matching lease without rewriting gameplay. A disconnect during acquire sets a cancellation generation; a late successful acquire must be conditionally released and never mount a world for the departed Player.

Fencing: every checkpoint, renewal, release and migration compares ownerSessionId, sessionEpoch/fence, expected profileRevision and unexpired lease **inside** the callback. A new owner increments the stored fence; an old server cannot overwrite it even if its delayed shutdown callback resumes. GUID owner IDs also prevent accidental ABA reuse. Fences are monotonically increasing application integers, not Roblox-provided locks.

Use server UTC for shared lease expiry and an injected monotonic clock for local timers. Refresh comparison time inside each nonyielding callback invocation; an operation prepared before expiry cannot commit merely because its captured timestamp was old. Convert confirmed expiry into a conservative local monotonic deadline and recheck UTC too. Freeze at the earliest safety deadline; never extend local authority on request dispatch alone. Backwards clock movement cannot extend that deadline; material clock anomalies suspend. Arbitrary cross-server clock skew is not solved by UTC leases; fencing protects committed state, while testing must validate freeze margins and document platform clock assumptions.

An expired owner must not revive by renewing its old token. Abandon local unsaved state and reacquire from durable data through a new session, or show reconnect required. If another server already owns the profile, never send the abandoned state as a merge. No force-unlock button, automatic lease stealing, MemoryStore authority or MessagingService correctness dependency.

## Save, retry and shutdown lifecycle

States: Loading → Active → Saving (still active within safe lease) → Active; failures → SaveDelayed → Suspended; ownership loss → Unavailable; leave/shutdown → Closing → Released or Expired. A coroutine completion checks its captured session generation before affecting UI or runtime state.

The country mutation queue serializes commands and complete simulation steps. Capture a validated immutable checkpoint between steps, including all accounting fields. The per-profile storage queue permits one outstanding request and one coalesced latest dirty snapshot. New mutations may continue during a save within the lease safety window, but cannot alter its captured snapshot. Revisions prevent a delayed older checkpoint overwriting a newer one. Never write every simulation step or in response to arbitrary UI refreshes.

A checkpoint compares its base profileRevision, saves the whole country, increments profileRevision, records lastCommit, and renews the lease together. Lease-only renewal is allowed only with no dirty gameplay snapshot and no unresolved write; it must not keep an unsaved progressing country alive indefinitely. A lease-only renewal leaves countryRevision/lastSavedAt unchanged: UI must not claim gameplay was saved merely because ownership renewed. Snapshot retries are assignments of identical state, never additions to cumulative totals.

Before a new operation, resolve the previous operation's ambiguous outcome. Within the callback, matching lastCommit means already applied, not apply again; mismatched expected revision or fence means stop/reload. For verification after a write error, use an uncached service read; absence of a receipt is not permission to overwrite a newer revision. If the operation committed and then a new owner acquired, its old server still cannot resume. Once ownership is released, no later old callback may save; retaining lastCommit allows a lost release response to be recognized without reacquiring.

Proposed retry policy: transient failures get at most five attempts per logical operation, full-jitter delays capped successively at 1, 2, 4, 8 seconds, and a 30-second caller observation deadline. Ownership contention waits at most 60 seconds per join attempt, then shows “Country still in use; retry shortly”; never initializes a substitute. Check request budgets before dispatch and prioritize acquisition/lease/final checkpoints. A deadline does not cancel an underlying yielding Roblox call: retain its in-flight slot, issue no overlapping write, stop mutation at safety expiry, and fence/ignore late callbacks. Retry only after the preceding call has returned. Bound total in-flight service calls to four and queued/coalesced profile tasks to eight; leave no unbounded retry tasks or joining-player backlog.

If all retries fail, freeze and show reconnect/retry status; do not silently continue an unsavable country. Retry after suspension requires a positively verified still-valid matching lease and reconciled revision; otherwise reload under fresh ownership. Unauthorized access, invalid schema, oversized data and programmer validation errors are nonretryable. Logging records reason, timings and revisions with sampled diagnostics, not full profiles or tokens.

On PlayerRemoving, unsubscribe/detach client presentation, stop country mutation, capture final state and request one fenced save-and-release operation. BindToClose shares the same per-profile finalization, freezes all countries and starts no new joins or optional work. Propose a 20-second application drain deadline and up to four concurrent profile calls, subject to actual platform shutdown allowance and remaining request budget. Never promise all eight saves finish. On unresolved completion leave the lock to expire; do not release separately while a save is ambiguous. A pending acquire or save may finish late; it may only conditionally finalize its own session. Remove local references after completion/deadline without permitting callbacks to resurrect a country. No shutdown path writes defaults or bypasses fences.

## Validation, size and recovery

Proposed P3a soft size alert **192 KiB**, hard **256 KiB** encoded UTF-8 JSON including lease/receipt; maximum nesting depth 12 and bounded schema-specific strings/collections. This is below the broader future 384/512 KiB target. Measure the full 1,440-slot ring and worst-case identifiers. Reject oversize candidates before dispatch; never trim history, erase identity or drop assets to fit. Runtime mutation preflight must preserve sufficient headroom for the fixed-size ring and envelope; any unexpected size/serialization fault suspends without overwriting the last valid checkpoint.

On load validate structure, types, ownership, versions, counters, coordinate lattice/domain, unique IDs, graph references, allowed definitions and accounting invariants before activation. Reject unknown fields for schema v1 except explicitly versioned optional fields; do not silently strip them. Missing/invalid profiles are unavailable, not “new player.” A successful absent key is the only initialization case. Routine gameplay cannot delete/reset keys; suspected deletion or an operator maintenance tombstone blocks initialization pending review.

Migrations are pure sequential schema transforms, independent of generator/balance versions. Acquire supported old data through its version-specific envelope validator, reconstruct/migrate outside callbacks, then conditionally commit against the acquired revision/fence. Retain old generators and golden vectors; do not map unknown versions to newest. Pure migration fixtures prove identity, anchors, bank and energy retention and idempotence after response loss. Unsupported future/ancient schemas stay untouched. P3a has no existing durable production profiles to migrate; do not fabricate a P2b-to-save conversion.

Before any destructive migration or manual recovery, require separately approved operator maintenance and a verified durable preimage export/backup. Platform versions help recovery but are not a backup for every autosave. Recovery identifies exact key/version, blocks new gameplay ownership, waits for or fences conflicting owners, validates the preimage and current head, then writes a **new** revision/fence exceeding the current head. Never restore an old lease/token or decrease envelope revisions. Record recovery operation/reason; an intentional accounting rollback requires explicit owner approval. No automated recovery writes, cloud exports or deletion tools are authorized here.

## Architecture and implementation stages — not started

Proposed modules follow existing boundaries: pure `Domain/ProfileSchema`, `ProfileMigrations` and snapshot validation; `Services/ProfileService` for lifecycle/mutation coordination; `Adapters/DataStoreAdapter` for service calls, budgets and uncached verification. Inject clocks, IDs and transport for tests. Reuse existing World/Simulation modules without moving them for cosmetic consistency. Client changes eventually consume sanitized save status and a fresh session epoch only; no storage credentials or profile authority on client. No dependency is selected or installed.

1. **Approval gate (now):** owner decides D94–D99 and explicit P3a implementation scope. No code until then.
2. **Pure implementation after approval:** schema, round-trip/restore and lease state machine with adversarial fake store; preserve existing regressions. No real service enablement implied.
3. **Test integration after approval:** guarded server adapter, session epoch separation, loading/save-status behavior, same-account close/rejoin handling and bounded queues. Persistent Test mode must be explicit; ordinary negative-ID Studio multiplayer stays fake/session-only and never writes `u:-1`.
4. **Real-service gate:** owner verifies Test universe/account/access and authorizes a distinct test-key namespace. If API access is disabled, stop for owner setup. Never enable access in Production. Dual-service-writer contention tests can use dedicated synthetic test keys, explicitly distinct from real-account reconnect evidence. No publishing/permissions inferred.
5. **Acceptance:** run the matrix below, record actual service behavior, limits and owner review. Stop after P3a. Economy/construction and Production rollout need separate proposals/approval.

## Required test matrix

| Area | Acceptance evidence required after implementation |
| --- | --- |
| Initialization | Two writers see nil, callbacks repeat, reply lost, generation fails, player leaves mid-acquire: exactly one durable country, no reroll or duplicate initialization |
| Leases | Competing unexpired owner refused; expiry/acquire race; stale owner resumes and late final save rejected; renewal response lost; clock jumps; safety freeze before further steps/commands |
| Reconnect | Same real account retains seed/name/anchors/online/totals; new command epoch rejects old payload; reconnect before previous release and immediately after crash/expiry; distinguish synthetic identity tests |
| Saves | Mutations during in-flight save, delayed callbacks, ambiguous commit/release, timeout without cancellation, five-attempt exhaustion, full queue/budget starvation, simultaneous finalization: one ordered writer and no stale overwrite |
| Restore/accounting | Serialized round-trip, step 0/day boundary/1440 ring wrap, Off between steps, negative coordinates, unchanged terrain recipe; continuous versus split saved/restored replay agrees within unchanged tolerance; no offline energy |
| Corruption | Wrong owner, missing/unknown/future schema, nonfinite/negative values, invalid versions/candidates/IDs/references, oversized/deep data and nonzero Bank: no activation or default overwrite |
| Migration/recovery | Callback retry and crash at each transition; unsupported generator blocked; reviewed restore keeps new fence/revision and exact identity; explicit preservation of preimage |
| Resources | Eight simultaneous joins, eight active countries plus closing attempts capped, leave while generation is pending, hung service calls and repeated reconnects: bounded tasks/queues/memory and cleaned subscriptions |
| Isolation/regression | P2a 432 fixtures/security, P2b deterministic vectors/climate limits/10,000-seed sweep/accounting, P2b.1 multiplayer, GUI/Native regressions, both Rojo builds and Script Analysis; no Production store path |
| Real Roblox | Isolated standard DataStore create/load/checkpoint/release, same-account reconnect, two actual service writers, request-budget measurements and graceful/abrupt stop where feasible; mocks never count as actual durability |

Measure serialization bytes/time, service latency p50/p95, request counts, retry reasons, actual dirty age/rollback, acquisition wait, freeze latency, generation CPU/wall/yields, queued/in-flight count and memory across repeated sessions. Preserve approved generation gates; there is no promise that network/DataStore loading completes inside its separate two-second generator watchdog. Document untestable crash/shutdown conditions rather than mark them passed.

## Platform facts checked for this proposal

Checked official documentation on 17 November 2026; recheck APIs/limits before implementation. These facts do not validate the application protocol above.

- Standard stores and one atomic profile key fit this scope; stable user-ID keys simplify ownership. Roblox recommends keeping data that must change atomically together. [Best practices](https://create.roblox.com/docs/cloud-services/data-stores/best-practices).
- UpdateAsync transformations can retry and cannot yield. Pure callback inputs and post-commit effects are application responsibilities. [Data stores](https://create.roblox.com/docs/cloud-services/data-stores).
- Failed writes may have an unknown result; uncached GetAsync verification avoids the ordinary local read cache. It does not itself acquire ownership. [Caching and verification](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching).
- Current standard-store version backups are hourly rather than every-write snapshots, and superseded versions expire. Manual preimage retention is a separate recovery requirement. [Versioning](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching).
- Roblox has entry/throughput/request limits; internal caps and budget-aware scheduling remain necessary. Do not use Studio measurements as proof of hosted budgets. [Limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits). Finalization uses [BindToClose](https://create.roblox.com/docs/reference/engine/classes/DataModel#BindToClose), but the proposed application deadline is not a durability guarantee.

## Documentation validation for this task

Review covers proposal status, scope conflicts, identity/session separation, ambiguous write handling, bounded queues and accounting restore against current source. Local links and protected-file hashes are checked separately in the completion record. No new runtime tests or real DataStore operations were run: this is a design deliverable, not persistence acceptance.


Completion checks: **204 protected source/test/script/asset/Rojo configuration files unchanged by SHA-256**, **169 local links/anchors passed**, six proposed decision labels verified, and `git diff --check` passed. Eight documentation files were created/updated: this proposal, `PLANS.md`, `README.md`, `DECISIONS.md`, `DATA-AND-SECURITY.md`, `TECHNICAL-ARCHITECTURE.md`, `PROCEDURAL-GAMEPLAY-FOUNDATION.md` and `TESTING.md`. Existing uncommitted implementation work was preserved. No Rojo/Studio suites were rerun for prose-only changes; no DataStore, permission, upload, commit, push or publish action occurred.
