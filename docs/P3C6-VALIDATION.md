# P3c.6 â€” Post-construction electricity proof preparation

18 November 2026. P3c.5 is owner-accepted. This task prepares a five-interval, two-session proof and validates it with fake storage. **No real DataStore request, lease, gameplay step or purchase is authorised or performed.** All real gates remain closed. Runtime simulation, pricing, schemas and artwork are unchanged.

## Exact historical input

Used the existing protected local `C:/Users/matt9/.codex/private/PowerState/P3c5-20261118/BuiltProfile.json`, independently verified as 16,905 bytes with SHA-256:

`72299d6608dda5275d48e0a35c78dca8c48254fd11d2783a40b67bc86d01cd85`

Rowanbridge country `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, seed `1441a4d819354af7b306ef8797931e15`; schema/ledger 3/3, profile revision 37, country revision 257, epoch 10, no lease. Bank 25,003 minor units, generator On, simulation/cursor 242, one completed district-feeder-v1 receipt and 100,000 minor capital spending. These remain historical remote observations; no current remote state is claimed.

Target for any separately approved future execution: Test universe 10776833313; personal creator/authenticated Studio account missawfulname / 149564436; standard store PowerStateProfilesP3aTest, default/global scope, exact key u:149564436. Production 10776828545 is excluded.

## Proposed five-interval design

Session A advances exactly three existing one-minute simulation intervals, from step 242 to 245, checkpoints and releases. Session B freshly verifies that exact released intermediate head, acquires a new fenced session, restores without offline catch-up, then advances exactly two intervals to step 247, checkpoints and releases. Maximum five total intervals; no quote, Build, control mutation, extra funding or infrastructure change. One explicit one-second wait per interval; scheduling delays never authorize catch-up steps.

Demand uses unchanged DemandModel v1, the saved 1,000 residents and deterministic protected mean temperature 1700 centi-degrees. District request is floor((townKW + 2) / 4). Both sinks are fully served in this admissible topology. The table gives posted **minor units**, not Credits; all carries have denominator 60,000.

| Start â†’ end step | Town kW | District kW | Total kW | Sales | Variable cost | Fixed cost | Bank | Sales / variable / fixed carry |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 242 â†’ 243 | 3370 | 843 | 4213 | 843 | 561 | 17 | 25268 | 12000 / 48000 / 0 |
| 243 â†’ 244 | 3374 | 844 | 4218 | 843 | 563 | 16 | 25532 | 48000 / 12000 / 40000 |
| 244 â†’ 245 | 3378 | 845 | 4223 | 845 | 563 | 17 | 25797 | 24000 / 16000 / 20000 |
| 245 â†’ 246 | 3382 | 846 | 4228 | 846 | 564 | 17 | 26062 | 0 / 0 / 0 |
| 246 â†’ 247 | 3386 | 847 | 4233 | 846 | 564 | 16 | 26328 | 36000 / 24000 / 40000 |

Total generated/delivered energy is **21,115 kW-minutes / 60,000 = 0.3519166667 MWh**: original town 16,890 kW-minutes (0.2815 MWh), district 4,225 (0.0704166667 MWh). No losses or shortfall are introduced. The feeder peaks at 847 kW against 1,000 kW capacity. Both shared upstream lines carry the combined flow, peaking at 4,233 kW; the existing 5 MW generator and 10 MW substation remain within capacity. Original town request is independently checked against fixed reference values, not inferred from the combined total.

Five-interval sales **42.23 Credits**, variable cost **28.15**, fixed cost **0.83**, net **13.25**. Predicted Bank **263.28 Credits**. Cumulative sales/variable/fixed minor totals become 85,632 / 57,088 / 2,216. Earned 85,632; total spent 159,304 including unchanged capital spending 100,000. Opening grant remains exactly 100,000 minor once. Financial generated/delivered meter 407,048 â†’ 428,163 kW-minutes; online economic steps 128 â†’ 133. Bonus remains zero. The original 242 reliability entries are preserved; five new combined entries are appended. Country identity, activation identity/step, immutable infrastructure and permanent receipt are unchanged.

Expected normal released intermediate: profile 40 / country 260 / epoch 11, step/cursor 245, Bank 257.97 Credits. Final: profile 43 / country 262 / epoch 12, step/cursor 247, Bank 263.28 Credits, no lease. These are predictions for the specified transitions, not values to overwrite computed results. An unexpected extra logical transition stops for review.

[Independent integer reference](P3C6-FORECAST.json) was computed locally from the protected capture and approved rational demand/rounding formulas. The Luau suite checks the real DemandModel, DistrictSolver and ConstructionCountry/Economy results against those demands and a separate per-interval integer billing oracle. Physical floating-point MWh comparisons retain a 1e-9 absolute tolerance; financial and canonical comparisons are exact.

## Prepared tests and actual evidence

`tests/unit/P3c6.spec.luau` accepts the historical capture as an argument. It has no real adapter, DataStoreService, remote caller or Heartbeat. A manual stopped-Test harness verifies the complete input checksum and uses fresh module copies with BaseScripts detached. FakeDataStoreAdapter and the existing fenced ProfileService/schema3/lease3 are used for all persistence transitions.

Coverage: separate sink identities, requested/delivered power and shared line conservation; exact integer settlement/carries; preserved receipt, deltas, grant and old history; 3+2 checkpoint/release/reacquire partition; a synthetic 24-hour gap with zero offline progression; before-write failure, lost committed response and callback replay; malformed Bank, duplicate financial cursor and stale/foreign-owner rejection. Failed checkpoints retry the same immutable snapshot/operation, not simulation. Fake final state must equal the uninterrupted five-interval country exactly.

Generator-Off synthetic state preserves both unmet requests and posts no sales or operating costs. Disconnected-district synthetic solver input leaves the original town served and district unmet; only delivered town energy is billed, producing lower net income. Disconnection is a solver fault parameter, not a persisted real-network mutation. No unsupported topology is saved.

Actual stopped-Test Studio results, 18 November 2026: final P3c6 repeat at13:11:23 UTC passed394 assertions; all five per-row logs exactly match the independent forecast. Earlier389-assertion run also passed; final repeat adds five pinned demand references. Normal fake profile is17,214 bytes, six writes/six reads, released43/262/12. No real calls.

Retained server run13:03–13:06 UTC passed: P2a432, P2bAccounting2941, P3c94, P3cSafety31, P3a178, P3b93, P3b3 44, P3b4 33, P3b5 50, scheduler49. Full-day accounting1440 intervals/12 exact restores passed; full-ring92,283 bytes. The10,000-seed routes/pads/four-rotation/fallback sweep and2,916,780 world assertions passed, zero fallback; generation CPU p95 16.467ms. Scheduler eight synthetic jobs870.699ms/51 Heartbeats; these jobs do not advance the real country. P3a canonical encode p95 7.556ms; P3b whole candidate-step p95 0.533ms. These are desktop Studio fake/local measurements, not hosted-service latency.

Both Rojo builds,1,058 static assertions (including27 new), Git whitespace and full-project Script Analysis0 errors/0 warnings passed. Current-script filter was disabled. No runtime source changed; GUI/device suites were not rerun for this fake-only preparation. [Sanitized machine-readable evidence](P3C6-EVIDENCE.json) records final forecasts and check counts. No fake timings or results imply real Roblox service acceptance.

## Guarded execution design â€” not enabled or implemented as a live adapter

Prepare a new separately gated PostBuild capability after owner approval; do not repurpose Fund or Build permission. Existing ConstructionProofPlan rejects already-built countries and must not be loosened for generic gameplay. Use a dedicated finite allowlist of exact complete country snapshots for steps 242â€“247, generated from the reviewed built profile using the existing arithmetic. Session A admits only its 242â€“245 prefix; session B only 245â€“247. Validate both full profile schema and exact expected snapshot/revision on every read and candidate callback.

Only Acquire, one Checkpoint per session, Release, and strictly necessary unchanged-country Renew/reconciliation are eligible. No initialization, migration, Build, quote or generator-control path. Reject every change to construction receipt, topology, deltas, original network, seed, grant or activation. Accept only exact deterministic economic/physical progression; never assign forecast Bank values. ProfileService must recognize only a private registered capability paired with the exact schema3/lease3 modules. Normal startup, clients and remotes cannot create or enable it.

Before any service access, require stopped Studio, exact Test universe, personal creator and authenticated StudioService user 149564436; fix store/scope/key in source. Verify closed unrelated gates and reviewed source hashes. Detach all BaseScripts in the dedicated module tree; do not start Play, previews or any heartbeat-driven simulation.

Fresh preflight must use GetAsync with UseCache=false and match the entire approved canonical hash, released lease, identity, pinned versions, receipt and financial/electrical state. Require platform version `08DF44E1F51DCFA5.0000000025.08DF45716BF4E852.01`, CreatedTime 1794944138060, UpdatedTime 1795005755473, exactly UserIds[149564436] and empty metadata. Any difference requires renewed review, not a silent rebase.

Export the actual fresh profile and returned platform metadata to a new protected package outside the repository. Independently hash it before acknowledging retention or acquiring. Preserve all earlier packages. Acquire must still atomically compare the reviewed head, so export delays cannot admit a concurrent change. Preserve associated users/custom metadata in all updates.

Use the existing 180-second lease, 30-second safety margin, one operation per profile, four global in-flight calls/eight profiles, five-attempt/30-second reconciliation bounds, request-budget checks and 20-second shutdown drain. Revalidate safe ownership before each interval; freeze on uncertainty. Commit the complete physical and financial snapshot atomically; only confirmed state may be acknowledged. A lost result requires uncached reconciliation of the same operation ID, never replaying the interval or issuing a replacement payout.

## Proposed real procedure and ceilings â€” separate approval required

1. Complete preparation gates; confirm explicit authority for **five total intervals in two sessions** and exact destination. No real read is authorized by this document.
2. Session A: fresh preflight/export/hash as above; acquire; restore exactly; run three explicit intervals with expected per-step checks; stage/checkpoint once; uncached full checkpoint confirmation; fenced release; uncached full released confirmation. Record/export intermediate canonical and platform state.
3. Stop if Session A is not fully confirmed and released. Session B may use only the exact intermediate record produced and securely retained by this same approved chain. It must freshly read/compare that full profile/platform record and export/hash before acquisition. No unrelated later head may be substituted.
4. Session B: reacquire/restore without advancement from elapsed time; run two explicit intervals; checkpoint once; confirm uncached; release; final uncached exact comparison and protected export. Confirm complete receipt/history/carries and absent lease. No third session or additional interval.
5. Close the temporary gate and clear capability/runner references; verify all normal flags false. Stop.

Normal path per session: three UpdateAsync calls (Acquire, Checkpoint, Release) and three uncached GetAsync calls (preflight, checkpoint confirmation, released confirmation). **Total six updates + six reads = twelve calls.** No renewal should be needed on the normal short path. Session B preflight is a separate read even though Session A already confirmed release.

Proposed additional proof caps: 90 seconds per acquired session; 30 seconds per operation; five total intervals; 24 application calls across the complete two-session proof, with at most 12 updates and 12 reads. These narrower proposed caps coexist with, and do not weaken, existing coordinator lease/retry/budget limits. They are not permission for repeated checkpoints or unrelated writes. Count failed calls and reconciliation against the same total. Necessary renewal must be unchanged-country and recorded; any departure from expected profile revisions must stop and be reviewed before advancing into the next session. Never use a retry as permission for extra simulation. Evidence-export time before acquisition is not simulation time.

Stop on changed head/platform metadata, corrupt/unsupported schema, mismatched receipt, conflicting lease, unsafe ownership, unavailable budget/deadline, non-allowlisted output, unexpected logical transition, or irreconcilable write. Preserve actual pending/confirmed state and suspend; do not force-unlock, silently restart a session, refund, reset or restore an old snapshot. A service request that has timed out locally may still finish: do not reuse its slot or treat it as definitely uncommitted.

## Recovery and remaining limitations

A preimage is forensic evidence, not authorization for automatic rollback. Restoring an older snapshot could erase valid electricity earnings, revive a lease, or undo purchased infrastructure. Any recovery requires fresh authorized inspection and a separately reviewed forward reconciliation preserving fencing, permanent receipt and legitimate completed intervals. Do not overwrite with historical P3c.4 or P3c.5 data.

Real texture/UI/device work, hosted outages, actual live-player reconnect and post-build real delivery remain untested here. The proposed reconnect is stopped-Studio same-account fenced release/reacquisition, as in prior proofs. It is not a public-release guarantee. No new art, balance, schema, infrastructure, real adapter or automatic gameplay was introduced.

Files in this preparation: tests/unit/P3c6.spec.luau, scripts/ValidateP3c6.py, docs/P3C6-FORECAST.json, docs/P3C6-EVIDENCE.json, docs/P3C6-VALIDATION.md, PLANS.md and docs/DECISIONS.md. Prior P3c.5 working-tree changes were preserved.

**Approval gate:** review the five-interval 3+2 procedure, exact forecast and execution caps. Separate explicit approval is required before preparing/enabling the final live capability or making any real service request.
