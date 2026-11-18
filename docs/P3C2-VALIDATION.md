# P3c.2 — Guarded schema-v3 migration and release

18 November 2026. **The single owner-approved migration succeeded and its fenced lease release was verified. Stop after this proof.** No construction purchase, spending, grant, electricity revenue or simulation advancement occurred. Production, settings, permissions, artwork and publishing were untouched.

## Implementation and isolation

- `src/server/Domain/ReviewedMigration3.luau`: pure exact-preimage guard, approved seven-field transformation, atomic MigrateAcquire envelope and exact fenced release. Reuses the existing schema3 validator and 180-second lease. Migration increases country revision once and records MigrateAcquire; callback/committed replay returns the identical prepared record. Metadata guard rejects changed original version/times, custom metadata and associated UserIds.
- `src/server/Services/MigrationRunner3.luau`: dedicated sequential migration/confirmation/release/confirmation runner. One application update per transition; ambiguous responses require uncached exact-record reconciliation, never overlapping replacement writes. Reads are bounded to three attempts per confirmation, one-second waits and 30-second retry bounds. Callback deadlines remain 30 seconds; service calls cannot be forcibly cancelled safely.
- `src/server/Adapters/Schema3MigrationAdapter.luau`: manually invoked stopped-Studio-only capability, exact Test universe/personal creator/authenticated account/store/global key, pinned full preimage/pure-preview/metadata SHA-256 and nine-call ceiling. No general update API, bootstrap, client or remote caller. Both callbacks preserve platform UserIds and custom metadata. Its execution flag is **false again** after completion; ordinary real economy and construction remain disabled.
- `tests/unit/P3c2.spec.luau`, `scripts/ValidateP3c2.py`: fake adversarial migration/release and local isolation coverage. Existing static allowlists in `Validate.ps1`, `ValidateP2a.py`, `ValidateP2b.py`, `ValidateP3a.py` name only this additional guarded adapter; no blanket persistence allowance.

Existing schema1/2 migration tests, financial formulas, prices, reserve, generation arithmetic, construction implementation and Native renderer were preserved. New modules were tested using fresh temporary module copies to avoid the previously documented stopped-Studio require cache; only copied tests' dependency paths were redirected. No assertions or acceptance thresholds were relaxed.

## Gates passed before real access

| Gate | Actual result |
|---|---|
| New P3c2 fake migration | **46 assertions** |
| P3c1 exact captured-profile preservation | 26 assertions |
| P3a / P3b / P3b3 / P3b4 / P3b5 | 178 / 93 / 44 / 33 / 50 assertions |
| P3c / P3cSafety | 94 / 31 assertions |
| P3cAccounting | 1440 billed intervals, 12 exact restores |
| P2a / P2bAccounting / P2b1Scheduler | 432 / 2941 / 49 assertions |
| P2b world plus P3c route validation | 2,916,780 assertions; 10,000 accepted seeds/routes, all four rotations and safe fallback |
| Generation diversity / fallback / CPU p95 | 10000/10000 unique; zero fallback; 16.086 ms |
| Static/build checks | **819** across P3a/P3b/P3b3/P3b4/P3b5/P2a/P2b/P3c/P3c2 |
| Rojo | Both default and Test builds passed before execution and after gate closure |
| Studio Script Analysis | **0 errors / 0 warnings**, current-script filter off, before and after execution |

Fake tests exercised full preimage matching; pure preservation; once-only migration, grant preservation and no capital mutation; callback/operation replay; lost migration/release response; before-write failures; bounded unavailable reconciliation; competing ownership; stale fence; expired release refusal; corrupt/unknown/changed records; metadata and UserId mismatch rejection; retained associations on new platform versions. No destructive real fault injection or extra real key was used.

The fake full-ring construction profile was 92283 bytes; its full-day accounting run took 1.239 s. P2b's maximum sampled encoded generated snapshot was 43705 bytes. These are local engine/fake observations, not DataStore or physical-device performance guarantees. No new GUI/device acceptance is claimed. The existing non-blocking completed-project button and narrow Bank grouping polish remain deferred, as do physical touch/gamepad checks.

## Protected evidence and fresh preflight

The P3c.1 package at `C:/Users/matt9/.codex/private/PowerState/P3c1-20261118/` passed every recorded file and pinned-source hash check before execution and remained unchanged afterward. Earlier recovery evidence was also checked unchanged. The approved canonical preimage is 7654 bytes:

`dcc3b32a12b48032f4d1f3ac2ea3536da68e7412ea3fbdba12c43a04dd504bd2`

A separate protected `C:/Users/matt9/.codex/private/PowerState/P3c2-20261118/` package retained the copied preimage/preview/metadata and distinct stable migration, release and session IDs **before** any real access. Its XML export contains only Folder/StringValues. Private identities and full profiles were not printed to ordinary logs. Temporary preparation/execution/fake runners were removed after completion; their source is not an automatic startup path. Existing recovery packages were not overwritten or repurposed.

At **09:36:07.663 UTC**, the fresh uncached preflight passed all exact comparisons. Identity came from stopped Studio (`RunService:IsStudio`, `not IsRunning`, `StudioService:GetUserId`), with Test universe `10776833313` and personal creator/account `149564436` / missawfulname. Store `PowerStateProfilesP3aTest`, default/global scope, key `u:149564436` were fixed in the adapter.

The entire canonical schema2 record matched the approved checksum and original platform version `08DF44E1F51DCFA5.0000000018.08DF454402F5B56E.01`, CreatedTime `1794944138060`, UpdatedTime `1794986251964`, associated UserIds `[149564436]` and empty custom metadata. Profile24/country131/epoch7/no lease were fresh observations, not assumed historical values. No mismatch or unsupported record was encountered.

## Actual transition and preserved country

| Field | Fresh preflight | Confirmed migration | Confirmed release |
|---|---|---|---|
| Schema / ledger | 2 / 2 | 3 / 3 | 3 / 3 |
| Profile revision | 24 | 25 | **26** |
| Country revision | 131 | 132 | **132** |
| Session epoch | 7 | 8 | **8** |
| Lease | Absent | New fenced 180-second lease | **Absent** |
| Receipt | Previous release | MigrateAcquire | Release |
| Bank | 100766 minor | 100766 minor | **1,007.66 Credits** |
| Simulation step / settlement cursor | 118 / 118 | 118 / 118 | **118 / 118** |
| Generator | On | On | On |

Whole-country canonical equality with the approved pure preview was checked inside every write callback and on confirmation/release. Only the seven approved schema/ledger/empty-construction changes were introduced to the country, plus the explicitly authorized profile/fencing envelope. Construction version1, demand version1, composition2, topology0, capital spending0; no receipt or constructed terminal/feeder, no additional demand.

Preserved exactly:

- Rowanbridge ID `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, seed `1441a4d819354af7b306ef8797931e15`, all pinned generation/network versions, original settlement/infrastructure coordinates and IDs, owned sectors and deltas.
- Bank100766, opening grant100000 once only, operating buffer25000; earned2496/spent1730 minor. Base sales2496, bonus0, variable expense1664, fixed expense66. Carries0/0/0/**40000**, including the fixed-cost denominator60000.
- Activation step113 and existing economy identity; cursor118; generated/delivered financial meters12480 kW-minutes, four online economic intervals. No reset or retroactive billing.
- Requested6.135999999999987 / delivered5.563999999999991 MWh and all118 reliability entries/index118, unchanged byte-for-byte within the canonical country.

Migration confirmation completed at approximately **09:36:08.326 UTC**; final release confirmation at **09:36:08.826 UTC**. No heartbeat or Play session was started. This avoids P3b.5's unrelated preview-heartbeat limitation.

## Calls, versions and checksums

Exactly **three uncached GetAsync calls and two UpdateAsync calls**, all successful. No application retry, extra renewal, alternate key, recovery write, ambiguous result or unconfirmed ownership. Counts describe application calls, not Roblox's internal network attempts or callback invocations.

| Operation | Latency ms |
|---|---:|
| Fresh preflight GetAsync | 219.965 |
| MigrateAcquire UpdateAsync | 501.337 |
| Acquired confirmation GetAsync | 134.112 |
| Release UpdateAsync | 323.686 |
| Released confirmation GetAsync | 150.082 |

Minimum sampled read/write budgets: 2492/2496. This five-call sample is not a service guarantee.

Migration platform version: `08DF44E1F51DCFA5.0000000019.08DF45575FAF0326.01`.

Final released platform version: `08DF44E1F51DCFA5.000000001A.08DF45575FFF3C24.01`.

Final canonical profile: **7796 bytes**, SHA-256:

`d846d13a398113d1442ff1e0a3feeccbf2397fdf286cad88583f635524c75a65`

[Sanitized execution evidence and closed-gate source hashes](P3C2-EVIDENCE.json). Studio truncated the initial long summary line; the existing in-memory sanitized summary was then printed in bounded chunks and reconstructed locally. No extra DataStore call was made for logging. Full-record confirmation preceded the print, so truncation did not affect validation.

## Remaining boundaries

Execution gate is closed; temporary captures/test module copies are detached and Studio is stopped. Ordinary real economy/construction remains disabled. No failed acceptance gate was bypassed; no new Script Analysis diagnostics appeared. Existing Git line-ending notices in two unrelated artwork files remain informational.

Real service outages, competing hosted sessions and disaster recovery remain fake-tested only. This success does not authorize a purchase, ongoing earnings, normal real startup or a production rollout. Bank remains below the1250-Credit purchase eligibility threshold; no earning steps or grant were added to change that. Never restore the historical v2 preimage over a later v3 purchase: it could erase receipts and refund spending. Any future recovery needs separately reviewed forward reconciliation and ownership safeguards.

Stop after P3c.2. A real construction purchase requires subsequent separate owner approval. No commits, pushes, uploads, settings changes, publishing or deployment occurred.
