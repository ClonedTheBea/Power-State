# P3c.1 — Schema-v3 migration readiness

18 November 2026. **Read-only readiness complete; real migration and construction remain unauthorized.** The owner accepted the P3c fake-storage proof and authorized this single-profile inspection and local preparation. No runtime code or economic rules changed.

## Fresh real-service verification

Stopped Studio verified `GameId=10776833313`, personal `CreatorId=149564436`, `CreatorType=User`, authenticated `StudioService:GetUserId()=149564436` and username `missawfulname` before access. Exactly one application-level `GetAsync`, with `DataStoreGetOptions.UseCache=false`, read `PowerStateProfilesP3aTest`, default/global scope, `u:149564436`. No other key/store, lease operation, simulation step or write occurred. Production was untouched.

The read completed at approximately 09:03:29 UTC, measured 199.479 ms. This is a single observation, not a latency guarantee. Full schema-v2 validation, exact expected identity, absent lease, associated UserIds and empty metadata checks passed.

| Field | Fresh observed value |
|---|---|
| Country | Rowanbridge |
| Country ID | `55e35a88-e3b9-4f72-9e69-d9024e7730a4` |
| Seed | `1441a4d819354af7b306ef8797931e15` |
| Schema / ledger | 2 / 2 |
| Generation / climate / demand / starter template / name pool / network | all 1 |
| Simulation / economy / balance versions | all 1 |
| Candidate / fallback | 0 / false |
| Profile revision / country revision / epoch | 24 / 131 / 7 |
| Lease | absent |
| Generator / simulation step | On / 118 |
| Bank | 100766 minor = **1,007.66 Credits** |
| Opening grant / operating buffer | 100000 / 25000 minor |
| Earned / spent | 2496 / 1730 minor |
| Economy activation / financial cursor | 113 / 118 |
| Base sales / bonus / variable costs / fixed costs | 2496 / 0 / 1664 / 66 minor |
| Sales / bonus / variable carry | 0 / 0 / 0 |
| Fixed expense carry | 40000, unchanged exact numerator with denominator 60000 |
| Delivered / generated economic meters | 12480 / 12480 kW-minutes |
| Online economic intervals | 4 |
| Cumulative requested / delivered electricity | 6.135999999999987 / 5.563999999999991 MWh |
| Reliability ring | 118 entries, index 118; complete contents preserved |
| Activation baseline requested / delivered | 5.875999999999989 / 5.355999999999993 MWh |
| Settlement | nameId 7, population 1000, sector (0,0), fixed-point position (11264,8192) |

The original network, generator state, coordinates and IDs are validated and preserved by exact canonical equality, not reconstructed from this table. Opening grant ID remains `P3bOpeningV1:55e35a88-e3b9-4f72-9e69-d9024e7730a4`. Private operation identifiers remain only in the protected package.

Platform version: `08DF44E1F51DCFA5.0000000018.08DF454402F5B56E.01`; CreatedTime `1794944138060`, UpdatedTime `1794986251964`; associated UserIds exactly `[149564436]`; custom metadata empty. Read timestamp `1794992609416` UTC milliseconds. These are returned metadata, not a future compare-and-swap reservation.

## Exact pure preview

The approved `ProfileMigrations3.read` transformed the fresh capture locally. [Machine-readable diff](P3C1-MIGRATION-DIFF.json) contains exactly seven leaf changes:

| Path | Before → preview |
|---|---|
| `/schemaVersion` | 2 → 3 |
| `/country/bank/ledgerVersion` | 2 → 3 |
| `/country/bank/constructionSpentMinor` | absent → 0 |
| `/country/construction/constructionVersion` | absent → 1 |
| `/country/construction/constructionDemandVersion` | absent → 1 |
| `/country/construction/compositionVersion` | absent → 2 |
| `/country/construction/topologyRevision` | absent → 0 |

No receipt, district terminal, feeder, demand, purchase debit, grant, revenue or clock advancement is added. Project serial remains its initial unbuilt value. Recipe, settlement, network, owned sectors, simulation, economy and existing deltas are identical. Removing only the new construction/capital fields and projecting ledger 3 back to 2 produces byte-for-byte the entire captured profile. Repeating the pure migration on schema3 is idempotent. Bank and all carries remain exact.

This preview deliberately preserves profile/country revisions, epoch, timestamps, lease absence and lastCommit. It is **not a directly writable migration envelope**. A future durable migration requires its own reviewed fencing and operation receipt.

## Protected evidence and recovery

Package: `C:/Users/matt9/.codex/private/PowerState/P3c1-20261118/`, outside the repository and build-cleanup paths. It includes canonical `Preimage.json`, `PureMigration.json`, `Metadata.json`, `Summary.json`, XML capture `readiness.rbxmx`, exact diff, source hashes, local runner scripts and `MANIFEST.json`. The XML contains only Folder/StringValues, no executable scripts. File ACL was checked: current Windows owner only, FullControl; inheritance from the broader profile directory is removed. This is a local plaintext capture, not encryption or an independent disaster-recovery backup.

| Canonical artifact | Bytes | SHA-256 |
|---|---:|---|
| Preimage.json | 7654 | `dcc3b32a12b48032f4d1f3ac2ea3536da68e7412ea3fbdba12c43a04dd504bd2` |
| PureMigration.json | 7796 | `46bef9243589c03ef7c70338354e46912b079f2f40ff20326302d74b1b608faa` |

Checksums cover exact UTF-8 canonical bytes without added BOM/newline. Local SHA-256 agrees with the Studio capture. Earlier P3b.2 recovery package files were hash-checked unchanged; P3b.3 evidence is retained. No full preimage or session tokens were added to repository documentation or ordinary output. The temporary capture and fresh test copies were detached from the place after use; Studio remains stopped.

Recovery procedure: stop gameplay; separately authorize a guarded current-head inspection; verify package hashes/source versions and current platform head/lease; distinguish a failed-before-write result from an exact committed migration by its operation identity and full candidate. An ambiguous result must be reconciled before any further mutation. If ownership, schema or content differs, stop for review. Never force-unlock, delete, reset or blindly restore this preimage. After later schema3 purchases, restoring this schema2 copy would erase receipts/infrastructure and potentially restore spent money. Recovery then needs a separately reviewed forward repair preserving durable transactions and fencing. No recovery writes are authorized here.

## Validation actually performed

In stopped authenticated Studio, fresh copies of current modules ran against fake storage and the captured local data. No additional real read was needed.

| Suite/check | Result |
|---|---|
| New P3c1 captured-profile preservation/invalid-version/carry/grant/size tests | 26 assertions passed |
| P3a fake persistence | 178 passed |
| P3b economy/migration | 93 passed |
| P3b3 guarded migration fake | 44 passed |
| P3b4 existing-v2 fake | 33 passed |
| P3b5 bounded execution fake | 50 passed |
| P3c construction and P3cSafety | 94 + 31 passed |
| P3cAccounting | 1440 billed intervals, 12 exact restores passed |
| Static scripts P3a/P3b/P3b3/P3b4/P3b5/P2a/P2b/P3c | 759 checks passed |
| `scripts/Validate.ps1` | both Rojo builds passed |
| Studio Script Analysis, current-script filter off | 0 errors, 0 warnings |

Initial use of the long-lived stopped-Studio require cache produced a P3b5 request-count failure and missing `ProfileService.build` in P3c tests. A freshly cloned P3b5 test already passed its unchanged count assertion; fresh current server/test modules then passed every suite. Only dependency paths in temporary test copies were redirected to fresh server copies. No assertion, threshold, accounting formula or repository runtime implementation was weakened. A diagnostic command also initially had a Lua replacement-string error; it made no service calls and was corrected. These are separately recorded harness diagnostics, not suppressed passing results.

Measured fake full-ring construction profile 92283 bytes; real pure preview 7796 bytes, below 192 KiB soft/256 KiB hard limits. Fake P3c solver p50/p95 0.0737/0.1154 ms; eight-country synthetic commits total 530.283 ms, peak 4 calls; full-day accounting 1.280 s. These are Studio CPU/fake-coordinator observations, not real purchase latency or concurrency guarantees. No GUI or physical-device acceptance is newly claimed; retained P3c evidence remains applicable because runtime/UI code is unchanged.

## Proposed guarded migration stage — separate approval required

1. Implement/review a dedicated stopped-Studio, exact-account/Test/key schema3 migration adapter and fake tests. Existing `ProfileLease3` accepts already-v3 profiles; it is not a v2 migration writer. Keep normal real startup disabled and isolate all preview heartbeats.
2. Verify private package/source hashes, authenticated identity, universe/creator and exact destination again. Perform a fresh uncached read immediately before any future write. Require this exact canonical preimage, platform version, metadata/UserIds and absent lease. A changed head stops for renewed review; do not silently adapt historical revision values.
3. Prepare the seven-change pure candidate. Propose a dedicated `MigrateAcquire` envelope consistent with the previous guarded migration: fresh private operation/session IDs, unchanged 180-second lease, epoch +1, profile revision +1, country revision +1, matching receipt/timestamps. With the reviewed head unchanged this would be profile25/country132/epoch8. This envelope still requires implementation and fake replay/expiry/metadata tests before execution; it is not part of the pure preview.
4. One guarded `UpdateAsync` atomically commits only that reviewed candidate and lease. Its callback revalidates the full expected preimage and platform metadata; retries return only the identical prepared candidate for the same operation. No external callback side effects. Preserve associated UserIds/custom metadata. No country initialization, grant, simulation, checkpoint earnings or purchase.
5. Uncached confirmation must match the complete acquired candidate. Then one fenced release update, followed by an uncached read of the exact released candidate. Expected released state, if the starting head matches, is schema3/profile26/country132/epoch8/no lease, Bank1007.66, step118 and empty construction.
6. Normal proposed service sequence: three uncached reads (preflight/acquired/released), two updates (migration/release). Retain the prior migration runner's bounded reconciliation: at most three read attempts, one-second waits, 30-second bound, nine total application-level calls, no overlapping replacement write. Ambiguous results require exact-record reconciliation; unresolved/expired ownership stops, with no forced release or new operation ID. Review these limits in the new adapter before authorizing execution.
7. Record returned versions, latency, canonical checksums and final release. Close execution gates and stop. Real purchase remains a separate later approval; current Bank is below the 1250-Credit purchase threshold, and no earning steps are authorized by migration approval.

## Remaining acceptance and file changes

Readiness does not establish real schema3 callback behavior or recovery under Roblox failures. The dedicated v3 migration envelope/adapter and its adversarial fake tests are the next preparation requirement. Platform data may change after this read; hashes do not reserve the key. Separate explicit approval is mandatory before any real write.

Non-blocking UI follow-up, recorded only: replace the already-built disabled price button with clear completed-state wording; improve Bank totals grouping on narrow mobile layouts. Physical touch/gamepad acceptance remains outstanding. No UI polish was implemented.

Files added: this report, `P3C1-MIGRATION-DIFF.json`, `tests/unit/P3c1.spec.luau`. Updated: `PLANS.md`, `docs/DECISIONS.md`. Private evidence lives outside the repository. No Production, settings, uploads, commits, pushes, publishing or deployment.
