# P3b.3 — Guarded schema-v2 migration and release

18 November 2026. **Owner-authorized single-profile migration completed and release verified. Stop after this proof.** Test universe `10776833313`, personal creator/authenticated account missawfulname / `149564436`, standard store `PowerStateProfilesP3aTest`, default/global scope, exact key `u:149564436`. No alternative stores, keys or universes were accessed. Production was untouched. No continued economic gameplay, financial checkpoints, simulation advancement, settings changes, uploads, publishing, commits or pushes occurred.

## Guarded implementation

- Added `src/server/Adapters/Schema2MigrationAdapter.luau`. Manual `run` only, denied outside stopped Studio in the exact Test universe and personal authenticated owner account. It verifies pinned SHA-256 values for the complete approved canonical preimage, pure candidate (including the reviewed stable operation identity) and returned platform metadata. It exposes no generic write/checkpoint API. A per-module attempted guard prevents concurrent/repeated invocation. Fresh v1/head/version and complete canonical/hash checks precede the write; callback validation repeats the reviewed-content and metadata checks.
- Added `src/server/Domain/ReviewedMigration.luau`. Pure exact-preimage acquisition and exact-acquired-profile release predicates reuse the unchanged `ProfileLease2`/schema validators. Acquisition creates the approved 180-second fenced lease and atomic migration/grant/receipt. Committed operation replays return the identical candidate. Changed content, owner, fence, unknown schema, missing profile and expired release are refused. Release cannot mutate any country data.
- Added `src/server/Services/MigrationRunner.luau`. Sequential migration → uncached confirmation → fenced release → uncached confirmation. It never mounts a country or advances a simulation. It makes at most one application-level migration update and one release update; failed/lost responses require exact expected-record reconciliation before continuing. Read failures have at most three attempts, one-second waits and a 30-second retry bound. Callback deadlines are 30 seconds. A yielding service request is never cancelled/replaced or overlapped; unresolved results stop. The adapter caps total recorded service calls at nine. An unconfirmed/expired release leaves the lease for ordinary expiry, never forced unlocking.
- Added `tests/unit/P3b3.spec.luau` and `scripts/ValidateP3b3.py`. Updated the explicit service-reference allowlists in `scripts/Validate.ps1`, `ValidateP2a.py`, `ValidateP2b.py` and `ValidateP3a.py` to recognize only the new approved, tightly guarded adapter in addition to the existing one. No blanket DataStore allowance.

**Existing real gameplay DataStoreAdapter remains v1-only. ProfileService schema injection and PersistentTestService economic play remain fake-only.** Bootstrap/client/remote code does not reference the new migration path. No prices, grant, reserve, fractions, world generation, simulation, original schemas or lease arithmetic were changed. The new module may be present in a build but cannot execute against Production or ordinary Play; this is not a runtime rollout.

Native SHA-256 uses [EncodingService.ComputeStringHash](https://create.roblox.com/docs/reference/engine/classes/EncodingService) with [HashAlgorithm.Sha256](https://create.roblox.com/docs/reference/engine/enums/HashAlgorithm), checked against the known `abc` vector in Studio. No hashing dependency was installed.

## Gates completed before real access

Actual Studio engine execution, stopped edit mode, current Rojo Test source:

| Gate | Result |
| --- | --- |
| New P3b.3 fake tests | **44 assertions passed** |
| Retained P3a fake persistence | **178 assertions passed** |
| Retained P3b economy/migration | **93 assertions passed** |
| Local isolation/source/build tests | **439 checks**: P3b.3 57, P3a 161, P3b 149, P2a 34, P2b 38 |
| Rojo builds | **Both passed**, default and Test; source/whitespace checks passed |
| Studio Script Analysis | **0 errors, 4 pre-existing artwork warnings, 0 new warnings**, current-script filter off |

The new tests cover exact physical history/identity/network preservation, zero initial financial meters/carries, step-113 cutover, once-only grant, callback replay, committed replay, synthetic competing-owner and stale-fence rejection, expired release refusal, lost acquisition/release responses, before-write failure, failed-release lock retention, bounded unreadable ambiguous results and refusal without the private package. Existing P3b fixtures cover full-day billing, fractional conservation, fake migrations, reconnect/replay, On/Off and financial invariants. Existing P3a fixtures cover persistence failures and security. All storage faults remained fake.

Two new test return-type warnings were corrected before running the successful suite. The prior P3a static allowlist initially flagged the newly authorized adapter; the explicit allowlist and new adapter-specific checks were updated and the entire relevant static set passed before real access. No failed gate was bypassed. The four existing warnings originate in R33/R37 artwork tests; source hashes matched their pre-task versions. Three visible R33 warnings concern inferred callable unions at lines 97/107/108. No unrelated artwork test was modified.

Measured fake CPU samples: P3a full-ring canonical encode p95 8.136 ms; P3b full candidate-step p95 0.507 ms; full fake profile 89,670 bytes. These are desktop engine/fake-storage measurements, not hosted DataStore or multiplayer performance. No new GUI/device/endurance acceptance is claimed.

## Recovery evidence and fresh preflight

The original protected package at `C:/Users/matt9/.codex/private/PowerState/P3b2-20261118/` remained accessible and all manifest hashes matched immediately before execution preparation and again afterward. No original recovery file, metadata, checksum or operation identity was overwritten, replaced, deleted or reset. The local XML package was imported only to obtain the three approved strings; it contains no executable scripts. It was detached from the edit model after completion. No private receipt or session ID was printed to ordinary logs.

Approved canonical v1 preimage SHA-256:

`d812a9752fa685f9d6976e08ea0821510b4d82c405fa11df558c2903628655df`

At **06:17:20 UTC**, the adapter reverified Test universe, personal creator and authenticated Studio UserId before accessing the exact fixed store/global key. Fresh `GetAsync` with `UseCache=false` returned schema1/profileRevision15/countryRevision123/sessionEpoch4/no lease. The complete canonical bytes, SHA-256, platform version/times, custom metadata and associated UserIds matched the reviewed package. The pure candidate and composed acquisition candidate passed schema-v2 validation. No mismatch was silently adapted.

The proof ran in stopped authenticated Studio rather than a Play session: account identity came from `StudioService:GetUserId()`, and no gameplay service or player simulation was started. This is stricter than a normal Play-only migration entry and ensures no revenue can accrue during the proof.

## Exact operation outcome

| Field | Reviewed preimage | Confirmed migration | Confirmed release |
| --- | --- | --- | --- |
| Schema | 1 | **2** | **2** |
| Profile revision | 15 | **16** | **17** |
| Country revision | 123 | **124** | **124** |
| Session epoch/fence | 4 | **5** | **5** |
| Lease | Absent | New fenced **180-second** lease | **Absent** |
| Receipt kind | Release | **MigrateAcquire** | **Release** |
| Bank | 0 Credits | **1,000 Credits** | **1,000 Credits** |
| Operating buffer | None | **250 Credits inside the same Bank** | Unchanged |
| Activation / settlement cursor | None | **113 / 113** | Unchanged |
| Earned / spent | 0 / 0 | **0 / 0** | Unchanged |

Migration returned successfully at approximately **06:17:21.479 UTC**; the following uncached read confirmed the exact acquired candidate, including migration operation receipt, session/fence and every country field. Fenced release returned at approximately **06:17:21.962 UTC**; the final uncached read confirmed the exact released candidate at **06:17:22.097 UTC**. Both responses were received normally; no ambiguous real result, application retry or additional grant occurred.

Preserved country:

- **Rowanbridge**, ID `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, seed `1441a4d819354af7b306ef8797931e15`.
- All generation/climate/demand/starter/name/network versions, settlement identity, infrastructure, land, coordinates and generator **On** state preserved.
- Completed step **113**; requested **5.875999999999989 MWh**; delivered **5.355999999999993 MWh**; **113** reliability entries and index **113**, unchanged entry-for-entry.
- Economy version/balance version **1/1**, ledger **2**; zero generated/delivered financial kW-minute meters, zero online billing steps, zero revenue/expense categories and all remainder counters zero, no financial statements.
- Grant identity remains the reviewed once-per-country identifier; grant is not earned sales. There was no historical revenue, operating expense or simulation advancement. First future eligible interval remains 113 → 114, but its execution is **not authorized by this proof**.

Roblox metadata and associated UserIds were preserved by both callbacks and verified on each read. Platform versions:

- Migration: `08DF44E1F51DCFA5.0000000010.08DF453B9ABDCF1F.01`
- Released head: `08DF44E1F51DCFA5.0000000011.08DF453B9B0E2C6E.01`

Released canonical profile: **7,269 bytes**, SHA-256 `ea9847e05aeca2b0590e085276fa10dd322acc98e72160400e15b83ea0a97cee`. This digest covers the confirmed final logical record; the original P3b.2 preimage remains separately intact.

## Actual DataStore requests

Exactly **five application-level calls**; these are not counts of Roblox's internal HTTP attempts or callback invocations.

| Call | Outcome | Observed latency |
| --- | --- | --- |
| Uncached preflight GetAsync | Reviewed v1 head matched | **191.675 ms** |
| UpdateAsync MigrateAcquire | One atomic migration/grant | **502.855 ms** |
| Uncached GetAsync | Exact migrated candidate confirmed | **148.532 ms** |
| UpdateAsync Release | Existing fenced lease released | **317.291 ms** |
| Uncached GetAsync | Exact released candidate confirmed | **134.007 ms** |

Sampled read budget remained at least 2,496 and write budget at least 2,498. All five measured calls returned successfully. No renewals, financial checkpoints, SetAsync, IncrementAsync, RemoveAsync, recovery writes, alternate keys or reset operations occurred. This small sample is not a service latency guarantee.

[Sanitized request/results evidence](P3B3-MIGRATION-EVIDENCE.json). Studio truncated the one long final summary log line; individual request lines and completion marker were intact. Full-profile canonical verification was completed before that print, so preservation claims rely on the executed equality/schema assertions, not reconstruction from the truncated line. No extra real call was made to replace a logging limitation.

## Remaining boundary and risks

Studio is stopped, the private imported capture is detached, and no automatic write or economic loop is scheduled. The final verified lease is absent. The migrated real profile is intentionally rejected by the old v1 gameplay adapter; do not call the old real P3a proof or rerun migration. Normal fake Test play remains independent.

Continued real income, v2 reconnect, checkpoints and financial endurance require separate approval and an appropriate guarded runtime adapter. Real ambiguous-response recovery, prolonged outages, competing hosted writers, operator recovery and physical-device acceptance are not established by this successful one-profile proof. Existing recovery rules remain: no automatic downgrade, grant reset, forced unlock or independent rewind of money/energy. Public release still requires the deferred non-Robux insolvency recovery design.

Stop after P3b.3. No P3c, R4, R5, commerce or Production rollout is authorized.
