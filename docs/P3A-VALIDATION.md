# P3a — Persistence implementation and isolated real-service validation

17 November 2026. **Owner-authorized single-key real-service proof passed its available persistence checks.** See the real-execution section below for current results and limits. Earlier fake-only/readiness sections are historical. No settings, permissions, uploads, publishing, commits or pushes occurred. Production universe 10776828545 remains untouched. Normal startup is unchanged; real persistence remains explicit, Studio-only and restricted to the approved account/key.

## Initial fake-only implementation boundary (superseded where noted below)

- `Domain/ProfileCodec`: canonical JSON ordering with injected scalar encoding, bounded traversal/bytes/depth, serializable-only values and immutable copies.
- `Domain/ProfileSchema`: strict schema v1, pinned P2b recipe/identities/network, zero Bank, no construction, finite/ranged accounting, exact ring cursor and tolerance-checked aggregates. Step limits retain DemandModel's existing 1,000,000,000 ceiling; energy ceilings derive from its 10 MW validation bound and the unchanged 5 MW starter.
- `Domain/ProfileCountry`: whole-country capture/restore, no load-time advancement, saved On/Off, exact energy/history round-trip, rebuilt last report and fresh command epoch. Country ID/seed stay fixed.
- `Domain/ProfileLease`: atomic initialization/acquisition/checkpoint/renew/release; current fence, owner, expiry and expected revision checked in the transformation; duplicate operation receipts are idempotent. Immutable recipe/starter fields cannot change in a checkpoint.
- `Domain/ProfileMigrations`: validated identity read for v1; unknown versions refused. There is no fictional legacy schema migration or destructive repair.
- `Services/ProfileService`: eight admitted profiles including closing entries, one outstanding operation and one coalesced snapshot per profile, four outstanding service calls, five total request attempts per operation, jitter/backoff, budget checks, ambiguous-response reads, safety freeze and bounded shutdown drain. Five attempts include reconciliation reads, a conservative request bound within the approved maximum.
- `Adapters/FakeDataStoreAdapter`: isolated in-memory storage with copy-on-read/write, compare-and-swap callback replay, failure/response-loss/delay injection and a 64-key test ceiling. Fake data is lost when the server/Play session stops; it is not durable storage.
- `Adapters/DataStoreAdapter`: prepared UpdateAsync/uncached-read adapter for the approved standard store, preserving metadata/user-ID association. **Compile-time `LIVE_ACCESS_APPROVED=false` asserts before obtaining DataStoreService.** No runtime flag, remote, Studio attribute or test GUI can enable it.
- `Services/PersistentTestService`: manually started, Studio/server/Test-universe guarded fake proof; bounded generation uses the existing scheduler; actual remote commands use the existing owner/sequence/rate handler. No automatic bootstrap activation. P2a/P2b remain the normal Test fixtures, Native remains production default.
- Existing SimulationClient/LiveViewModel accept explicit `P3a`, show loading/save state, fake-storage disclosure and **0 Credits**, and retain existing map/control behavior. Other profiles retain their previous presentation.

Server profile owner is the authenticated Player. Positive IDs use `u:<id>` in fake storage during this stage; negative Studio IDs use `fake:<id>` and cannot reach the real adapter. Country/session/lease identities are separate. Only sanitized status and the owner's gameplay descriptor are sent; private leases/receipts are excluded.

## Lifecycle and failure behavior

A new profile is activated only after confirmed atomic initialization and validated reconstruction. A second local join cannot admit the same owner while a closing session still occupies its slot. Lease duration remains 180 seconds, checkpoint target 55–65 seconds, safety freeze 30 seconds before confirmed expiry. Renew-only operations cannot masquerade as saved gameplay. Offline/loading/suspended time adds no energy; ordinary menus do not pause simulation.

A lost response is resolved with the same operation ID and an uncached adapter read, without reapplying accumulated energy. A request deadline never frees a still-running call's slot or permits an overlapping write. Ownership loss drops the pending unsaved snapshot; stale server state cannot overwrite the newer owner. Clock reversal beyond one second or monotonic reversal suspends. Clock skew between real servers still needs service validation.

The fake proof stages a copied complete next state before publishing it, so failed validation cannot partially apply an electricity step. Runtime saves are snapshots, never additive ledger operations. Commands report applied live separately from checkpoint confirmation. Closing freezes mutation and coalesces the final snapshot; successful final save and lease release are one conditional operation. Twenty-second shutdown drain is best effort. A hung callback can retain a bounded slot until it returns; it cannot resurrect a departed session. Unconfirmed shutdown state may roll back to the previous checkpoint.

## Automated evidence

The fresh Play-mode suite passed **178 P3a assertions**: atomic initialization, repeated callback/receipt idempotence, competing owners, exact lease boundary, stale writer rejection, ambiguous checkpoint/release, same-user fake reconnect, old command epoch rejection, 1,440-slot history wrap/midnight replay, On/Off between steps, malformed/oversized/deep/cyclic/future data, zero Bank, failed-read no-default behavior, no-budget requests, held-call bounds, clock reversal, pending-generation cancellation, delayed old writes, coalesced snapshots, late acquisition after disconnect and repeated cleanup.

These are **actual Luau/Roblox engine execution using fake storage and injected clocks/identities**. They do not prove same-account cross-server Roblox DataStore durability. Negative Studio identity storage and real-adapter denial remain separate boundaries.

Measured checkpoint at a full history ring: **84,620 encoded bytes** (~82.64 KiB), below 192 KiB soft / 256 KiB hard limits. Canonical encode measured p95 **7.317 ms** over nine checkpoint samples (small sample, not hosted latency or a full eight-country frame budget). Thirty-two fake reconnect/release cycles made **64 adapter calls**, retained **one key**, and returned the active-profile count to zero each time. Lua memory delta was **−1,250 KiB** in that run due to GC; an earlier run was +280 KiB. These deltas are noisy and do not establish an exact allocation cost.

Retained regressions: P2a **432**; P2b full 10,000-seed world sweep **2,916,780** assertions, 10,000 unique starts and zero fallbacks; accounting **2,941**; P2b.1 scheduler **49**, eight synthetic jobs **921.696 ms / 55 Heartbeats** in the focused run. World sweep CPU p95 **14.804 ms**, unchanged 75.457983 MWh day and 3.811 MW peak. Client regressions passed: P2a GUI **57**, P2b GUI **88**, GUI layout **348**, R2 interaction **135**, P2a/P2b/P3a actual RemoteEvent security **32 each**, and P3a responsive GUI **88** plus cleanup/remount checks. These exercise actual Roblox GUI/remotes but fake storage for P3a. P3a map descendants remain **345**. Desktop/portrait/tablet safe-root rendering p95 CPU was **0.1312 / 0.1568 / 0.1208 ms**, frame p95 **17.65 / 17.66 / 17.75 ms**, on this desktop Studio host. They are not physical-device measurements.

Both Rojo builds/source-boundary checks passed; local P2a checks **34**, P2b checks **38**, and P3a preservation/isolation checks **155** passed. The real adapter remains unreachable. No tests were deleted or thresholds weakened: two existing GUI/transport suites now accept an optional P3a profile while their default P2a/P2b behavior remains covered.

No real lease expiry, shutdown durability, hosted throttling or real-account reconnect is claimed. Reviewed recovery/backup remains a procedure rather than an implemented operator write tool. Existing P2b.1 eight-real-client evidence is preserved; it does not become an eight-real-client P3a result.

## Test setup corrections and limits

- Direct edit-mode require reused Studio's cached older DemandModel/WorldGenerator and failed on a missing mean-temperature field. Fresh Play-mode modules passed; that edit-mode attempt is excluded from current-source evidence.
- The full synchronous 10,000-seed sweep was initially launched during joining. It starved the unrelated P2b startup job (2,846.755 ms wall, 1,424.541 ms initial queue), which correctly hit the unchanged two-second watchdog. The world sweep passed but subsequent P2b GUI could not load that refused country. A separate clean-start run is used for live GUI acceptance. No generation threshold/algorithm was altered.
- The initial P3a GUI run caught the legacy preview Bank card still displaying 100,000 Credits. The P3a view-model and overview were corrected to zero; the subsequent GUI/transport run passed. Stored Bank was zero throughout. Header now explicitly labels fake saving.
- A local file encoding/line-ending issue was corrected before successful builds. Strict optional-GUI types were clarified; no diagnostics were suppressed.
- Canonical full-ring validation/serialization and eight-country simultaneous save CPU still warrant profiling before real-service adoption. Network/service performance cannot be inferred from fake timing.

## Reproduce the fake proof

Use Power States - Test, universe **10776833313**, connected to `test.project.json` on port 34873. Normal startup remains P2b. Do not enable Studio API access.

1. Run `scripts/Validate.ps1`, then `python scripts/ValidateP2a.py`, `python scripts/ValidateP2b.py`, `python scripts/ValidateP3a.py`.
2. For focused testing, temporarily disable the long client `DevelopmentTests.Run` in the local edit model. Start a fresh Play session so old edit-mode module caches cannot contaminate evidence.
3. From a server Script, invoke `require(game.ServerScriptService.DevelopmentTests.unit["P3a.spec"])()`. Other pure suites remain independently available. Run the 10,000-seed stress sweep after live country generation finishes, not during join timing.
4. In the same Test server, explicitly invoke `require(game.ServerScriptService.Server.Services.PersistentTestService).start()`. It always chooses fake storage. From a client LocalScript invoke `require(game.Players.LocalPlayer.PlayerScripts.DevelopmentTests["P3a.spec"])(game.Players.LocalPlayer.PlayerGui)` for the GUI/remote suite. This reuses P2b GUI coverage and the existing adversarial transport suite with an explicit P3a profile.
5. Inspect 0 Credits, Fake storage, live/save status, generator controls, selection and map camera. Closing/reopening the GUI resubscribes without creating a new country. Stop Play discards fake storage. This is explicitly different from permanent saving.
6. Stop, remove temporary local verification scripts, restore the normal client runner, and verify Script Analysis with Current Script Only off. Never publish the temporary test setup.

## Historical real-service readiness before owner confirmation

- Intended owner: **missawfulname**, personal account **149564436**. Read-only Roblox Users API on 17 November 2026 confirmed this ID/name. The owner's earlier R3.4 manual evidence identified Test as “By @missawfulname”.
- Intended Test universe: **10776833313**, Power States - Test. Current unauthenticated Games API returned ID/creator zero and unavailable title, so it did **not** independently verify the current Test creator. Authenticated/manual confirmation is still required; no authentication bypass attempted.
- Proposed destination: Test universe standard store **PowerStateProfilesP3aTest**, default/global scope, keys **u:<approved positive test-account UserId>**. The first proposed account is `u:149564436`, only after explicit owner approval. No arbitrary/made-up real player IDs. Concurrent-writer fault tests stay fake until an exact dedicated real-key procedure is approved.
- Isolation: Roblox stores are universe-scoped; the Test universe plus this fixed store name separates these records from future Production. The adapter denies every other universe. No Production destination or rollout is configured.
- Required setting: owner inspects **Experience Settings → Security → Enable Studio Access to API Services** in Test only. Current setting is not verified or changed. If disabled, owner must separately authorize/perform enabling. Studio access can touch actual experience data, so it must not be enabled in Production for this test. [Official setup](https://create.roblox.com/docs/cloud-services/data-stores).
- Proposed approved-session test: verify universe/owner/setting and whether the exact key already exists; do not overwrite existing or unexpected data. After separate code-enablement authorization, create/load the approved account profile, toggle Off, wait for durable checkpoint, disconnect/rejoin and compare identity/energy/history. Exercise conditional lease contention using authorized test sessions and the same approved key, then lease expiry/recovery without force-stealing. Verify budgets, ambiguous responses where safely reproducible, privacy and bounded calls. No reset/delete or permissions/publishing included. Stop on corrupt/unsupported data or unverified destination.

**Approval remains required before changing the hard lock, enabling access or issuing any real DataStore request.** This task ends at that boundary. Confirm the authenticated Test creator and setting first; then approve the exact store/key and test procedure. No approval request covers P3b revenue or P3c construction.

## Read-only readiness follow-up — 17 November 2026, 19:17 UTC

This supersedes the historical unverified ownership/settings and no-read boundary above. The owner confirmed personal ownership, Studio API access **Enabled**, and the exact destination in the P3a Real DataStore Readiness instruction. This authorizes environment/key inspection, not adapter enablement or writes.

- Studio Command Bar verified `game.GameId=10776833313`, `game.CreatorType=User`, `game.CreatorId=149564436` and authenticated `StudioService:GetUserId()=149564436`. Play was stopped. These values match the approved missawfulname account and Test experience. Actual server Player identity must be checked again when an approved Play test begins.
- After asserting all these guards, a single `GetAsync` with `DataStoreGetOptions.UseCache=false` inspected standard store `PowerStateProfilesP3aTest`, omitted/default scope (`global`), exact key `u:149564436`.
- The API call succeeded and returned **nil / absent** at 19:17:03 UTC. No profile was initialized. No existing payload was printed or modified. This establishes read access and point-in-time key absence, not write permission, durability or immunity to a later concurrent creation.
- API setting Enabled is owner-confirmed; the successful actual read corroborates service access. No settings were changed. No setting change is currently indicated.
- Evidence: Studio log `0.747.330.7470002_20261117T084929Z_Studio_F0BEA_last.log`, readiness output 19:16:21 and read output 19:17:03 UTC. The prepared application adapter was not used or enabled; `LIVE_ACCESS_APPROVED=false` remains unchanged.

**Next explicit approval requested:** enable the guarded Test-only real adapter and execute the previously documented create/checkpoint/reconnect/lease tests only for this store and key, with initial Bank 0 Credits. Recheck active universe, real server Player UserId and uncached key contents immediately before the first write. Stop on unexpected/unsupported data; atomic initialization must also refuse unexpected concurrent creation. No reset/delete, settings, permissions, publishing, Production or additional keys are included. The owner has approved the destination/procedure in principle, but has expressly withheld execution approval until readiness is complete; no write has been attempted.

## Future irreversible actions — documented, not implemented

Construction purchases, rebirths, permanent rewards and other irreversible actions need durable transactional checkpoints before success is acknowledged. Debit/grant/action ID and relevant simulation counters must commit together, with lost-response reconciliation and replay prevention. The ordinary autosave rollback policy alone is insufficient for those actions. No ledger, purchase, reward or economic feature is added here.


## File inventory

New runtime modules: the nine Domain/Services/Adapters modules listed above. Changed runtime files: `src/client/Simulation/SimulationClient.luau` and `LiveViewModel.luau` only. Existing bootstrap, World and Simulation modules and all artwork are hash-preserved in `P3A-PRESERVED-SOURCE.json`.

Tests: new unit/integration `P3a.spec.luau`; optional P3a parameter added to `tests/integration/P2b.spec.luau` and `P2aRemote.spec.luau`. Validation: new `scripts/ValidateP3a.py`; `Validate.ps1`, `ValidateP2a.py`, `ValidateP2b.py` now permit only the hard-disabled, server-only approved adapter reference instead of a blanket ban on future persistence syntax. No other storage call is allowed.

Documentation: `PLANS.md`, `README.md`, `DECISIONS.md`, `P3A-DECISION-PROPOSAL.md`, `DATA-AND-SECURITY.md`, `TECHNICAL-ARCHITECTURE.md`, `PROCEDURAL-GAMEPLAY-FOUNDATION.md`, `TESTING.md`, this report, preservation hashes, selected measurements and inspection captures. Earlier uncommitted work remains preserved.


Final focused client check passed **15 presentation/privacy assertions**, including zero Bank overview, private fields absent, save status and suspended control behavior. Live/Saving/Delayed/Suspended presentation inputs in that check were **synthetic UI states**, not actual service failures. The final server suite repeated all 178 persistence assertions successfully. [Actual fake-mode dashboard](p3a-screenshots/fake-dashboard.jpg), [selected measured logs](P3A-MEASUREMENTS.json).

Final cleanup at 19:10 UTC removed both temporary local verification scripts and restored the normal client runner. Play is stopped. [Studio Script Analysis](p3a-screenshots/script-analysis.jpg) shows **zero errors and zero warnings**, with Display only current script unchecked. Final local checks repeated successfully: P2a 34, P2b 38, P3a 155 and Git whitespace validation.


## Authorized real execution — 17 November 2026

The owner's **P3a Real DataStore Execution Approval** explicitly authorizes this proof. Destination: personal account missawfulname / **149564436**, Test universe **10776833313**, standard store **PowerStateProfilesP3aTest**, default/global scope, sole key **u:149564436**. API access was already enabled; no setting change was made. Real fault injection, deletion/reset, alternative keys and Production remain excluded.

### Adapter and integration changes

- `DataStoreAdapter.create(player, expectedCountryId)` now permits the owner-approved proof only after Studio/server/Test-universe, personal creator and actual Player membership/UserId assertions. These checks precede DataStore service access. Every read/update requires the literal approved key. No external flag, client request or normal bootstrap selects this adapter.
- Each adapter instance performs a fresh uncached read. First creation requires absence; reconnect requires the exact previously recorded country ID and a fully valid schema. The first atomic update additionally compares the current value with the preflight baseline (or its own operation receipt on retry). Unexpected concurrent creation/change is refused. A missing expected profile is not regenerated.
- Existing fencing, 180-second lease, 30-second safety margin, 55–65-second autosave interval and retry/reconciliation logic are unchanged. The adapter preserves user-ID associations/metadata. Bounded diagnostics retain at most 64 call records; read options are destroyed after use.
- `PersistentTestService.start()` remains fake. Explicit `startReal(player, expectedCountryId)` selects the guarded adapter. Other Player IDs cannot be admitted to that real proof. Its diagnostic snapshot is server-only. The normal client/server bootstraps and all approved world/simulation algorithms remain hash-preserved.
- SimulationClient now describes the actual server-reported storage mode in loading, header, inspector and overview. Real mode displays **Real save** and explains that only confirmed checkpoints are saved; Fake mode retains its loss-on-Stop-Play warning. Bank stays 0 Credits in both. No economy feature was added.
- New manually invoked server `tests/unit/P3aReal.spec.luau` exercises only normal, approved operations. It is excluded from the production build and is not invoked by ordinary test startup. Existing static checks now verify the new exact-account/Studio authorization instead of requiring the superseded false approval constant. The fake suite still verifies that no-Player invocation fails before service access.

### Preflight and actual operations

Before the first write at approximately **19:35:38 UTC**, the real adapter verified `game.GameId`, personal creator and the actual connected authenticated Player **149564436**, and obtained an uncached nil result from the exact approved key. Default scope is omitted in the API call and resolves to `global`. No alternate account/key/store was attempted.

| Session / phase | Actual result |
| --- | --- |
| First Play, CreateOff | 18 assertions; atomic creation, 3 online steps, generator Off, 3 offline-generator steps, checkpoint, renewal and confirmed release. Profile revision 4, fence 1. |
| Second Play, ReconnectOn | 21 assertions; same authenticated account restored Off, seed/identity/network/whole history and exact energy. Acquisition added no offline progress. Three more Off steps, then On and 3 steps; checkpoint, renewal, release. Revision 8, fence 2. |
| Third Play, VerifyOn | 14 assertions; restored On with identical 12-step accounting; no simulation steps added by this phase. Acquire, two renewals and release. Revision 12, fence 3. |
| Third Play, live service | Explicit real GUI service reacquired fence 4; real remote On/Off controls, responsive GUI, timed whole-country autosave. Saved revision 14 at step 70. Stop Play exercised the service's graceful final-save/release path. |
| Fourth Play, read-only verification | Fresh authenticated Player and uncached read: profile revision 15, fence 4, lease absent, final receipt Release. Reconstructed complete country matched saved data exactly. No real write in this session; subsequent regressions used fake storage. |

**Saved country:** Rowanbridge, ID `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, seed `1441a4d819354af7b306ef8797931e15`. Generation/climate/demand/starter/name-pool/network versions all **1**, candidate 0, no fallback.

**Final observed durable state (19:40:23 UTC):** generator On; step/history index **113**; requested **5.875999999999989 MWh**, delivered **5.355999999999993 MWh**; window totals equal these cumulative totals because the ring has not filled. Bank **0 minor units / 0 Credits**. Encoded released profile **6,620 bytes**. This is the small live profile; the separate full-ring fake fixture measured 84,620 bytes. No force unlock, reset, deletion, corrupt write or extra real key was used.

The three scripted phases account for 12 updates: 3 acquisitions, 2 checkpoints, 4 renewals, 3 releases. Live service added acquisition, timed checkpoint and final release, for **15 UpdateAsync calls** total. There were **11 explicit GetAsync calls** (preflight and confirmation reads), giving **26 application-level DataStore calls** during execution, excluding the earlier readiness-only read. These counts are not Roblox's internal HTTP attempts/budget charges. The final revision 15 and phase completion evidence agree with those committed operations. No application-level retry or ambiguous result was observed; those paths remain fake-tested.

### Measurements and evidence

[Selected actual logs and measured request records](P3A-REAL-MEASUREMENTS.json), [actual real-storage dashboard](p3a-screenshots/real-dashboard.jpg).

| Measurement | Observed result |
| --- | --- |
| Uncached reads, 8 complete timing samples | median 156.33 ms; nearest-rank p95 330.12 ms |
| Updates, 10 complete timing samples | median 483.73 ms; nearest-rank p95 834.60 ms |
| Sampled remaining request budgets | GetAsync and SetIncrementAsync each at least 584 |
| Coordinator maximum outstanding calls | 1 in each observed sequential proof |
| Real GUI map descendants | 345, stable across movement/resizing |
| Desktop 1366×704 | map CPU p95 0.1220 ms; frame p95 17.50 ms |
| Portrait safe root 360×580 | map CPU p95 0.1616 ms; frame p95 17.57 ms |
| Tablet safe root 768×960 | map CPU p95 0.1238 ms; frame p95 17.51 ms |

These are small Studio samples on this desktop, not physical mobile or production service guarantees. The first phase's oversized log line was truncated by Studio; subsequent reporting uses compact summaries and individual request lines. Its timing records and the final service shutdown call are excluded from latency aggregation. Its completed 18-assertion result/revision and the next session's exact restoration verify creation and release. No extra real writes were performed to replace missing timing samples.

### Validation and remaining limits

Real scripted phases passed **53 assertions** total. Actual real-storage responsive GUI passed **88 assertions**, cleanup/remount, and explicit Real-mode/zero-Bank disclosure checks. Native remains the map default. The 178-assertion fake persistence suite passed after adapter enablement; storage-failure and corrupt/expiry/race injections remained fake. Actual Live and timed-checkpoint states were observed; delayed/suspended/error presentation uses the existing synthetic UI/fake-service tests, not intentionally induced real outages.

Remaining: no second simultaneous real service writer, abrupt process-kill recovery, real throttling/budget starvation, actual ambiguous network response, long outage, clock skew between hosts, operator recovery or hosted multi-server rollout tested. Existing same-account evidence is sequential authenticated Studio Play sessions, not two published Roblox servers. Real profile history did not wrap; full-ring/midnight round trips remain covered by the unchanged fake tests. No physical-device performance claim. Eight-country serialization/save bursts remain a future profiling concern. The full 10,000-seed sweep was preserved from the preceding P3a/P2b runs, not unnecessarily repeated for this adapter/UI change; protected hashes verify unchanged world arithmetic.

### Reproduction boundary

The created profile must be retained. **Do not rerun CreateOff** or reset/delete the key. Any future approved reconnect must pass the exact saved country ID above. Normal Play still runs the existing P2a/P2b fixtures, not automatic real persistence. Temporary local verification runners are removed after this proof. The approved task stops after these tests; no P3b/P3c or Production deployment follows.


Final execution-stage regression results: P2a 432 server assertions; P2b accounting 2,941; P2b.1 scheduler 49 (eight synthetic jobs 906.890 ms / 54 Heartbeats); P2a GUI 57; P2b GUI 88; P3a fake GUI 88 plus 15 presentation/privacy assertions; P2a/P2b/P3a fake-storage remote suites 32 each; GUI layout 348 and R2 interaction 135. Both Rojo builds and source-boundary checks passed. Local P2a/P2b/P3a static checks passed 34 / 38 / 159. [Final Script Analysis](p3a-screenshots/real-script-analysis.jpg) shows zero errors and warnings with Current Script Only off.

One temporary regression-harness sequencing issue caused Gui.spec to wait for a baseline shell after the prior test destroyed it. Supplying the expected baseline shell allowed the unchanged 348/135 suites to pass. No assertion or acceptance threshold was removed; no real persistence operation was involved. A pre-existing unrelated asset-type warning from Studio was not a DataStore failure. Play is stopped; both temporary local real-test runners are removed and the normal test runner is restored. No further real operations are scheduled.
