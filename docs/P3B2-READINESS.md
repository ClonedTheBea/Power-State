# P3b.2 — Read-only schema-v2 migration readiness

18 November 2026. **Read-only verification and local migration preparation passed. No real migration, write or lease operation occurred.** The owner authorized only Test universe 10776833313, personal account missawfulname/149564436, standard store `PowerStateProfilesP3aTest`, omitted/default scope `global`, exact key `u:149564436`. Production was not accessed. No settings, runtime source, economy formulas, assets, commits, pushes or publishing changed.

## Current real head

Stopped Studio verified `game.GameId=10776833313`, `game.CreatorType=User`, `game.CreatorId=149564436` and `StudioService:GetUserId()=149564436`. Roblox's username lookup returned `missawfulname`. No Play session or real application adapter was started. The subsequent guarded command repeated destination/account assertions before obtaining the store and made **one GetAsync with UseCache=false** at approximately 05:49:12 UTC. No other keys/stores or version-history enumeration were requested.

| Field | Fresh observation |
| --- | --- |
| Country | Rowanbridge |
| Country ID | `55e35a88-e3b9-4f72-9e69-d9024e7730a4` |
| Seed | `1441a4d819354af7b306ef8797931e15` |
| Schema / profile revision / country revision | **1 / 15 / 123** |
| Session epoch / lease | **4 / absent** |
| Generation, climate, demand, starter template, name pool, network versions | **All 1**; candidate 0, fallback false |
| Simulation version / generator / completed step | **1 / On / 113** |
| Requested / delivered MWh | **5.875999999999989 / 5.355999999999993** |
| Reliability ring | 113 entries, index 113; window requested/delivered equal cumulative values above |
| Bank | **0 minor units / 0 Credits**, earned/spent zero, ledger 1 |
| Profile created / last saved UTC seconds | 1794944137 / 1794944388 |
| Platform key version | `08DF44E1F51DCFA5.000000000F.08DF44E28A32164D.01` |
| Platform CreatedTime / UpdatedTime (milliseconds) | 1794944138060 / 1794944388173 |
| Associated user IDs / custom metadata | `[149564436]` / empty |
| Measured uncached read | **462.879 ms**, one sample, not a service guarantee |

The full v1 validator checked the pinned network and coordinates, ownership, recipe versions, energy conservation, each reliability entry and aggregates, revision/receipt consistency and zero Bank. It accepted the current head. No conflicting lease, unexpected identity, unsupported version or corrupt data was found. The historical P3a result was used only as an identity guard, not as a substitute for this read.

## Exact proposed transformation

The existing `ProfileMigrations2.read` ran on the freshly read profile. `ProfileSchema2.validate` accepted the result. The original input remained canonically identical. Removing the added economy, restoring the original Bank and schema number recreated the entire preimage exactly: all other fields, including every history entry, are preserved.

[Field-level diff](P3B2-MIGRATION-DIFF.json) lists **26 leaf changes**. Its only redacted value is the planned operation GUID, retained in the private exact diff. The complete unredacted diff and exact pure candidate are local review artefacts, not executable writes.

- `schemaVersion`: 1 → 2; Bank `ledgerVersion`: 1 → 2; Bank `balanceMinor`: 0 → 100000.
- Add `openingGrantMinor=100000`, `openingGrantId=P3bOpeningV1:55e35a88-e3b9-4f72-9e69-d9024e7730a4`, and `operatingBufferMinor=25000`. Buffer is part of the same 1,000-Credit Bank, not another grant or balance.
- Existing Bank currency, scale, earnedMinor and spentMinor remain Credits / 100 / 0 / 0.
- Add economy/balance versions 1, `fromSchema=1`, planned activation operation GUID, `activationStep=113`, `lastSettledStep=113`, and the exact requested/delivered baseline values above.
- Add zero delivered/generated kW-minute meters, online steps, sales/bonus/variable/fixed totals and all four remainder counters. Statements are an empty Luau table (canonical JSON `{}`); no funding reason/step is introduced.
- No elapsed-time catch-up or retroactive payment/cost. The **first eligible interval starts at 113 and completes at 114**. The first financial hour is partial through step 120. Generator On state does not itself advance a step during migration.

The pure transform keeps the existing envelope/receipt unchanged and is **not** a complete persisted migration commit. In-memory `ProfileLease2.apply` separately verified the atomic acquisition composition:

| Execution envelope field | Proposed change if the reviewed head still matches |
| --- | --- |
| profileRevision | 15 → **16** |
| countryRevision | 123 → **124** |
| sessionEpoch | 4 → **5** |
| lease | absent → new execution session/job/place, fence 5, expiry = approved execution UTC ms + **180000** |
| lastCommit.kind | Release → **MigrateAcquire** |
| lastCommit.operationId | planned migration GUID, same as economy.activationOperationId |
| lastCommit.fence / baseProfileRevision / committedProfileRevision / countryRevision | **5 / 15 / 16 / 124** |
| createdAtUtc / lastSavedAtUtc | unchanged by the existing acquisition transformation; no simulation checkpoint occurs |

Session/job IDs, execution time and resulting Roblox version are execution-bound values, not fabricated current service metadata. The local lease preview used a synthetic session/job and the read timestamp solely for validation; it was never submitted. Repeating its operation returned an identical complete candidate, with no second grant. Another local operation during its synthetic lease returned `InUse`. No real lease was acquired, renewed or released.

## Private preimage and recovery review

Authoritative local package: `C:/Users/matt9/.codex/private/PowerState/P3b2-20261118/`.

- `Preimage.json`: **6,620 bytes**, exact UTF-8 `ProfileCodec.encode` output, no BOM or trailing newline. SHA-256: **`d812a9752fa685f9d6976e08ea0821510b4d82c405fa11df558c2903628655df`**.
- `PureMigration.json`: **7,269 bytes**, SHA-256 **`68cdcb0723bf19e742c37b869908f442e10e8c40e2570a85297ce58bdbc72f38`**. This is the pure candidate, before the acquisition envelope changes above.
- `Metadata.json`: returned version/times/custom metadata/user associations, exact destination, read timestamp and measured latency.
- `ExactPureMigrationDiff.json`: full field-level diff, including the private planned operation identifier. Its checksum is in the public diff summary.
- `readiness.rbxmx`: original local Studio export containing the three captured strings; extraction matched the 6,620-byte canonical preimage. No executable scripts in that export.
- `MANIFEST.json`: checksums/lengths of artefacts and hashes of the reviewed schema, migration, lease, codec, economy and real-adapter source; read/regression commands retained alongside it.

Directory inheritance was removed and access granted only to the current Windows user; child ACL inheritance was verified. These are local plaintext files, **not encrypted or an off-device disaster backup**. They are outside the repository and Rojo mappings. An ACL-protected, Git-ignored staging copy also remains under `.build/p3b2-private/`; the outside-repository package is authoritative and must not be swept with build cleanup. No private receipt/session payload was printed to ordinary logs. The temporary ServerStorage capture was detached after export; it is absent from the edit model, and Studio remains stopped. No place was saved or published.

Recovery procedure, for owner review before any execution:

1. Verify the private package hashes and v1 schema, retain the returned key metadata/user IDs, and keep the exact planned migration operation ID stable. The checksum covers canonical logical profile data, not Roblox's internal storage bytes.
2. Immediately before an approved migration, repeat exact universe/creator/authenticated identity guards and an uncached head read. Require the reviewed version, canonical preimage and revisions to match and no active conflicting lease. Any change stops for a new review; do not adapt silently.
3. The future real write path must compare the current callback value with this reviewed preimage, validate it, preserve metadata/user associations, and commit schema/grant/cursors/fence/receipt together. Callback retry must recognize the same operation. Never call the pure transform alone as a write or add a grant separately.
4. On ambiguous response, suspend activation and reconcile using an uncached read and the same operation receipt. A committed valid v2 profile is restored as v2; an unchanged v1 may only be retried under the same approved operation and comparison conditions. Conflicting, corrupt, unsupported or unexplained state stops.
5. If restore fails after a confirmed migration, preserve the record and suspend. **Do not write this v1 preimage back**, reset the grant, downgrade, force-unlock, or restore Bank independently of energy/cursors/carries. Any recovery mutation needs a separately reviewed coherent whole-profile candidate, a higher fence/revision, fresh destination/head checks and explicit owner approval. No recovery writer or recovery service test was implemented here.

## Validation and limitations

[Sanitized execution evidence and source hashes](P3B2-READINESS-EVIDENCE.json).

- Actual Studio engine execution in stopped edit mode: fresh real-head v1/v2 validation, pure migration idempotence, exact legacy preservation, zero historical billing, atomic candidate revisions/lease/receipt, duplicate migration idempotence and synthetic competing-owner refusal passed.
- P3a fake persistence suite: **178 assertions passed**; 32 reconnect cycles / 64 fake calls / one retained fake key. Full-ring checkpoint 84,620 bytes, canonical encode p95 7.937 ms.
- P3b fake suite: **93 assertions passed**, covering migration, full-day billing, exact carries, replay, reconnect, ambiguous writes, stale owner, On/Off and finance invariants. Full fake profile 89,670 bytes; candidate-step p95 0.499 ms; 8,000 serial economy-only settlements p95 0.0268 ms. Desktop/edit-mode CPU samples are not hosted or concurrent-player results.
- Both Rojo builds and source/whitespace checks passed. P3a/P3b local checks **159 + 149 = 308 passed**. No relevant runtime source was changed.
- Studio 0.748.0.7481526 currently shows **0 errors / 4 warnings** with current-script filtering off, in existing R33/R37 artwork integration tests. Three visible R33 warnings concern inferred callable unions at lines 97/107/108. These were present before this task's changes; unrelated code was not modified. This does not supersede the previous version's zero-warning observation or claim a clean current all-project analysis.
- No new GUI/device, multi-client, endurance or actual v2 durability acceptance is claimed. No real fault injection or recovery write occurred. The preimage is point-in-time evidence, not a lock against later writers.

## Execution approval boundary

The readiness transformation matches the approved P3b contract; there is no newly detected data or arithmetic discrepancy. **Execution is still blocked by missing separate owner authorization and the intentionally retained real-v1-only adapter/fake-only schema injection guards.** A subsequent authorized stage must add and review the narrowly guarded real-v2 path, enforce the exact reviewed-preimage comparison and idempotent atomic commit, and repeat its regressions before its first approved write. This report does not imply the current adapter can safely execute v2 simply by toggling a flag.

Requested next-stage approval, if the owner accepts this report: prepare/review that exact-key guarded path, then migrate only this unchanged Rowanbridge profile with one 1,000-Credit grant, activation step 113, atomic revision 16 / country revision 124 / epoch 5 and a 180-second session lease. Reverify all values immediately before writing and stop on any mismatch. Any broader financial checkpoint, reconnect/release execution procedure should be explicitly included in that next approval; no additional key or Production action is implied. No write is authorized by this readiness report itself.
