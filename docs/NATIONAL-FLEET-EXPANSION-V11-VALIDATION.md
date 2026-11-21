# National Fleet Expansion v1.1 — balance, storage and staging

21 November 2026. Available fake Test validation complete; balance, storage and remaining performance concerns await owner review. Owner accepts v1's technical gameplay proof. This sprint does not authorize a price change, new persistence representation, real profile access, migration or wind purchase. Native remains default; Organic diagnostics are untouched. Historical v1 evidence remains in [the v1 report](NATIONAL-FLEET-EXPANSION-V1-VALIDATION.md).

## Baseline and boundaries

Fresh Studio preflight verified Test universe10776833313, personal creator149564436 and authenticated Studio user149564436. Real/Execution attributes were checked before Play. The normal fake host is explicitly selected by `NationalFleetProof`; no real adapter is supplied. Before optimization the normal district journey passed34 assertions at step134, Bank253.08 Credits,379 map descendants. Fake disconnect/reconnect passed18 assertions, including BeforeWrite/AfterWrite recovery. These are actual Studio host handlers, not network reconnection to a published server.

No source changes to approved prices, wind/demand kernels, solver, world arithmetic, schemas1–4, lease durations, construction definitions or immutable legacy evidence are authorized or required. Initial command input landed outside the editor and produced a clipboard-format error; it was re-entered after explicit focus verification. A first profiling launch lacked its newly synced module in the already-running Play session; a fresh session resolved it. Neither was a gameplay failure.

## Progression study and recommended decision

`FleetPriceStudy.spec` replays three fresh generated seeds (reference, all-zero and all-f), using the original1000-Credit grant, exact ordinary gas/district billing,17°C protected climate and normal demand. District first becomes affordable at step131. Each alternative wind price is **an analytical scenario**, never a catalogue change or schema-valid purchase. The study constructs only an unsaved electrical network, calls the actual solver at the candidate purchase phase, and applies original integer cost/sales formulas with the saved gas/sales fractional carries. No hypothetical profile is submitted to storage. The existing4000-Credit purchase is still exercised by the retained progression test.

| Candidate price | First affordable step | Post-district wait at1 interval/s | Bank after hypothetical debit | First24h operating savings across3 seeds | Exact marginal payback across3 seeds |
|---|---:|---:|---:|---:|---:|
|2000 Credits|963|13m52s|250.16 Credits|1343.53–1534.64 Credits|2052–2089 intervals /34.20–34.82 simulated hours|
|2500 Credits|1166|17m15s|251.80 Credits|1396.54–1541.83 Credits|2393–2731 /39.88–45.52h|
|3000 Credits|1352|20m21s|250.03 Credits|1441.83–1451.10 Credits|2928–3087 /48.80–51.45h|
|4000 Credits, unchanged|1751|27m00s|250.07 Credits|1328.62–1567.66 Credits|4129–4209 /68.82–70.15h|

35,575 solver comparisons across12 candidate/seed studies passed. Each comparison checks identical delivered energy against gas-only reference and no shortfall with gas available. Every first-day minimum Bank remained at least250 Credits. Payback is the first interval where cumulative gas fuel savings minus wind's On cost cover capital; sales are identical and cancel. This is **marginal investment payback**, not the time to rebuild Bank from all electricity profits. Availability varies by phase; samples do not establish population-wide balance or guaranteed future return. Waiting times exclude loading, saves, pauses, declined controls and service delay. Pure replay executes quickly for testing without changing gameplay income cadence.

**Proposal, requires separate owner approval:** trial2000 Credits for the first wind project, retaining250 buffer and all rates. This is the shortest tested wait without a grant or income multiplier, but still takes roughly16 active minutes from a fresh start and has a meaningful34-hour marginal payback.2500 is a reasonable slower alternative;3000/4000 leave most of the current idle stretch. Do not adopt any candidate from this report automatically. Existing4000 receipts and capital totals would need a versioned catalogue/receipt policy before changing the price; never reinterpret a historical receipt at today's price or refund automatically.

Price reduction alone cannot create an operational game. Before wind the oversized gas station and unconstrained routes make keeping gas On the obvious economic choice. After wind, potential tops out at1.6MW while normal combined demand remains higher, so gas backup is necessary; turning gas Off is a shortage demonstration, not a profitable strategy. A cap is a ceiling, not a production target; reducing a nonbinding cap does not save fuel under least-cost dispatch. Do not advertise these as deep decisions or charge for reinforcement of an unconstrained normal-country feeder.

Two later progression candidates deserve a separate design: (1) choosing when to accept an additional demand commitment against forecast reserve and liquidity, and (2) choosing between a demonstrated congested-route upgrade and generation capacity. Both need actual constraints, price/reliability tradeoffs and approval; neither is implemented. Read-only demand/reserve explanation and the existing wind/gas experiment can teach the current system but should not masquerade as new gameplay. Avoid rewarding repetitive toggling: below75kW wind displaces less than its6-Credit/hour cost, but the resulting small saving is poor mandatory early-game activity.

Earlier wind yields more capital for subsequent expansion because operating savings begin earlier; it does not increase customer sales in this fully served network. Do not price future projects as a fixed multiple of this first-project discount. Re-evaluate a full future load/capacity scenario before approving the next purchase.

## Storage review — proposal only

Current schema4 keeps complete frozen migration evidence and live state in one atomic country. Representative full-history built profile:180,105 bytes. Supported high-number stress:212,969 bytes; this is a valid algebraic near-counter-limit fixture, not a billion-step replay. Conservative structural estimate:247,483 bytes, reserving24 characters per numeric scalar and1024 identity bytes. It is not an observed profile. Hard limit262,144 and soft warning196,608 remain unchanged. Worst structural headroom14,661 bytes does **not** authorize another technology.

Representative component sizes overlap and must not be summed indiscriminately:

| Component | Bytes |
|---|---:|
|Live simulation|82,162|
|Live history alone|81,943|
|Frozen baseline, all records|88,186|
|Frozen history alone|81,943|
|Fleet including baseline|89,279|
|Live economy including bounded statements|5,152|
|Built deltas|804|
|District construction record|448|
|Bank|324|

Both1440-entry histories dominate. Statement count remains25; source financial meters are scalar cumulative totals/carries, not per-generator history rings. Permanent receipts must never be evicted when lastCommit changes. Long-running countries grow numeric widths until the approved1e9-step/1e15-minor ceilings, then fail closed; time does not append unbounded rows. Larger fleets also consume node/traversal/solver/replication budgets, not just bytes. The current solver permits4 sources/32 nodes/48 links/8 sinks; owned-country composition permits only2 sources. A storage design is not authority to raise either limit.

**Recommended next storage design, owner gate:** retain one atomic profile key and all evidence, but investigate a new versioned lossless paired-array representation for both histories. Replacing `{requested=x,delivered=y}` with `[x,y]` saves exactly24 key bytes per row,69,120 bytes for two full rings, without rounding, dropping order/index/aggregates or losing a sample. Reconstruct the exact historical named records before unchanged schema3 validation; keep original financial carries and permanent receipts. The corresponding structural estimate would be178,363 bytes before format/version overhead, leaving83,781 bytes. This estimate is not implementation or a new accepted bound. Reserve and test explicit future per-unit/node/edge/receipt budgets rather than assuming arbitrary national growth fits.

Alternatives: quantized/coarsened history changes arithmetic or loses evidence and is not recommended under the current contract. Separately stored immutable cutover evidence would reduce the active key but introduces a multi-key dependency: write immutable content first, verify it, atomically switch a fenced manifest, never reference an unverified object, never delete referenced evidence, handle orphan writes and unavailable/corrupt reads, and reconstruct full historical validation before gameplay. A hash alone cannot recover unavailable evidence. Backup/export outside Roblox is not sufficient runtime authority. This additional failure and recovery surface is unnecessary before testing lossless inline compaction. No multi-store design is implemented.

Any future format migration needs exact old→new→old equality, malformed-array/version/size tests, full old-schema validation, interruption/idempotence tests, protected preimage/platform metadata and explicit execution approval. Keep financial settlement, topology, debit and permanent receipt in the same fenced commit. Never treat immutable audit data as a rollback save after subsequent earnings or purchases.

## Staging investigation and implementation

Thirty component samples per probe isolate copying, validation, encoding, settlement, capture and completion. Timings overlap; do not add them. `os.clock` active-region durations are CPU proxies including possible GC/preemption, not OS CPU counters. Shared `gcinfo` deltas do not isolate allocations, peak memory or a leak. No forced collector or timing policy change is used.

Baseline full-profile encoding p50/p95/peak:8.335/9.387/11.401ms; full validation15.479/16.681/17.181ms. Full-country copying0.568/0.750/0.949ms; history copying0.249/0.636/0.761ms; accounting copying roughly0.014ms median. Capture1.996ms median; settlement0.370ms; complete2.493ms. Repeated canonical traversal/encoding is the demonstrated dominant cost, not history copying alone.

Implemented a bounded weak immutable-subtree byte cache in `ProfileCodec`. Cache proofs require recursive immutability, no metatable, exact scalar-encoder identity, canonical output, subtree node count and relative depth. Every hit still charges its complete byte/node/depth contribution to unchanged limits. Mutable or shallow-frozen input cannot reuse a full-subtree proof. Cache leaf chunks rather than overlapping simulation/country/profile ancestors, avoiding redundant retained strings. Limits:128 entries,2MiB encoded payload with coarse eviction; metadata/allocator overhead is additional. Weak keys permit reclamation; conservative counters can trigger earlier eviction after GC. Cache misses follow original validation/traversal. No hash replaces canonical equality.

`FleetRecord.snapshot` shares only proven deeply immutable branches and copies/freezes mutable branches. `ProfileService.stage` uses it for schema4 only and still validates the entire candidate before publishing the pending snapshot. Callbacks, fences, deadlines and atomic installs do not yield or change. Original capture returns remain compatible. The first attempted outer capture freeze failed a retained legacy-projection test; it was reverted, not the test weakened. The first broad byte cache improved an ideal warm probe but churned under eight profiles; leaf-only caching was measured separately rather than claiming the ideal result as eight-player performance.

Final numerical measurements, regression completion and screenshots follow. Whole-profile staging and checkpoint costs remain separate from 4ms/80ms solver budgets and 750ms result deadlines. No low-end-device or hosted-frame guarantee follows.

### Final measured performance

Same Studio host and full-history fixture; 30 samples per component. Units are milliseconds, p50 / p95 / peak. These are overlapping probes, not an additive accounting of a frame.

| Probe | Before | Final |
|---|---|---|
| Full country copy | 0.568 / 0.750 / 0.949 | 0.571 / 0.886 / 1.034 |
| Live history copy | 0.249 / 0.636 / 0.761 | 0.270 / 0.552 / 0.596 |
| Full profile validation | 15.479 / 16.681 / 17.181 | 6.815 / 7.493 / 13.455 |
| Full canonical encoding | 8.335 / 9.387 / 11.401 | 2.443 / 3.419 / 3.485 |
| Capture | 1.996 / 2.144 / 2.217 | 1.875 / 2.287 / 2.426 |
| Settlement | 0.370 / 0.597 / 0.686 | 0.306 / 0.362 / 0.481 |
| Complete | 2.493 / 3.246 / 3.554 | 2.463 / 2.722 / 2.794 |
| Coordinator stage | Not separately collected | 6.735 / 7.877 / 14.263 |
| Checkpoint preparation | Not separately collected | 0.500 / 0.699 / 0.866 |
| Fake checkpoint execute and confirm | Not separately collected | 96.688 / 106.889 / 116.326 |

The last row includes synchronous fake adapter validation, copying and confirmation; it is **not real DataStore latency**. It remains substantial. Do not claim the saving path is optimized or frame-safe. Further restructuring requires a focused proposal preserving retried-callback validation and atomicity; no yielding or prevalidated-write bypass is introduced here.

Eight-country baseline: native requested cadence peak callback 29.947ms, wall 361.476ms; requested 30Hz peak 23.189ms, wall 482.974ms. Final five batches at each cadence:

| Cadence | Callback p50 range | Per-batch p95/peak range | Eight installs wall range |
|---|---:|---:|---:|
| Native / requested 60Hz | 16.233–18.770ms | 18.949–22.954ms | 293.87–342.03ms |
| Requested 30Hz | 16.773–19.544ms | 18.732–26.841ms | 458.98–485.92ms |

Only a small number of callbacks occur in each batch, so its nearest-rank p95 equals its peak. Before callback percentile samples were not collected; the component p50/p95 comparison above is the available matched percentile evidence. All ten final batches installed eight countries, met unchanged solver 4ms/80ms and 750ms completion limits, and drained jobs/coordinator profiles on shutdown. Whole staging is not bounded to 4ms, and the final 30Hz outlier exceeds the earlier 22–24ms observation. This is an improvement in repeated encoding/validation, not elimination of synchronous stalls. Individual batch measurements and resource-cleanup observations are retained in the evidence files.

Actual fake host endurance: 600.881 seconds, 591 observations, steps 1957→2552, maximum country size 92,415 bytes, capture/encode peak 12.515ms. Coordinator end state: one active profile, zero in-flight operations, peak one, 50 cumulative calls. Shared heap changed by −300KiB; GC and other engine work make this neither a leak proof nor a peak bound. The eight-country isolated tests separately verified zero retained profiles/jobs after cleanup. No allocation-by-site or GC pause telemetry was available; do not infer either from `gcinfo`.

### Storage experiment result

The non-writing paired-array study passed nine size/round-trip/schema checks. It JSON-round-tripped the proposed representation, restored both named histories, compared the complete canonical profile byte-for-byte and ran the unchanged schema4 validator. Full histories saved exactly 69,120 bytes in each of three fixtures: 179,066→109,946; 180,105→110,985; 176,953→107,833. The packed record is **not a valid current schema4 storage record** and is never passed to an adapter. These results support reviewing D249; they do not authorize a persistence-format change or establish malformed-input/migration recovery acceptance for a future format.

## Regression evidence and limitations

Actual Studio results on the final runtime implementation:

- Schema4/full-size fixtures: 227; canonical legacy comparison: 14; immutable byte/snapshot boundaries: 217. Includes shallow-frozen mutable children, alternative encoders, depth/node/byte charging, eviction, cycles and caller independence.
- Owned accounting: 138; atomic transactions: 85; security: 69; cancellation: 36; full-day balance: 5,766; price study: 35,575 across twelve scenarios. Existing three-seed 4,000-Credit progression still passes.
- P2a: 432; P2b accounting: 2,941; P3a: 178; P3b: 93; P3b.3/.4/.5: 44/33/50; P3c: 94; P3c safety: 31; P3c 1,440-interval accounting with twelve restores. Retained schema1–3 migrations, grant, receipts, replay, failure and lease rules pass.
- Wind-site corpus: 930,005 checks over 10,000 accepted worlds/four rotations; retained P2b corpus: 2,916,780. Construction route/pad coverage retained. A redundant world sweep also passed; it is not additional seed diversity.
- Operations encoding/atomic/scenario/security: 5,020/326/3,144/231. Solver exhaustive oracle: 2,187 cases and 8,854 assertions. Yield oracle and current scheduler: pass; scheduler safety 1,486 and all twelve cancellation boundaries. Fleet lifecycle: 2,062 across eight fake countries/120 intervals; schedule: 63 eight-country intervals including fail-safe unsupported cadence.
- Normal district journey: 34; actual remote intent checks: 12; full owned-wind journey: 91; post-reconnect owned GUI: 62. Includes 30-second expiry/refresh, one purchase, cap/On-Off controls, remount/subscription identity, stale unsubscribe, malformed controls, preserved capital and responsive focus. Fake lifecycle: 18 before and after optimization. Funding helper advances genuine bounded fake intervals for test setup; gameplay rates and ordinary cadence are unchanged.
- Bank structured rows: 1,968 checks over twelve viewport/text-scale combinations. Legacy GUI: 364; R1: 16; R2 interaction: 135; R3: 190; R3.1: 52; R3.3: 739 **synthetic**; R3.5: 241 repeated three times. Native map remained 379 descendants, below 600. R34/R37 real-art soaks were not rerun: artwork/rendering code is unchanged, and historical evidence is retained.
- Both Rojo builds and source/security/whitespace checks pass. First Playable, P3c and P3c.3 local source validators pass. Full-project Script Analysis after Play: **0 errors, 3 pre-existing Organic warnings**, current-script filter off. OrganicCoast 23:13 and OrganicRibbon 14:50/14:82 remain unchanged. Temporary new runner return-type inference warnings were corrected with an explicitly heterogeneous suite list; no runtime warnings were suppressed.

Failures and diagnostic setup limitations are retained, not hidden. Besides the corrected capture freeze, the initial diagnostic list mistakenly invoked historical Stage1B `FleetOptimization.spec`: its 1,037 correctness assertions passed but its old synchronous eight-job 16ms gate failed. That gate was superseded by the approved Stage1D scheduled contract; the test itself remains unchanged. The runner now selects the approved yield/scheduler tests, which passed. This report does not claim the old gate passed. A legacy R1 GUI invocation waited for its fixture-specific Bank widget in the live owned view; mounting the original AppController fixture completed the suite. Command-bar attempts to retrieve the client module's active instance returned nil; persistent client LocalScripts were used for evidence views instead. These attempts did not modify service state or acceptance thresholds.

Eight-country measurements are eight fake actors, **not eight actual hosted clients**. Desktop Studio safe-root sizes and bound keyboard/gamepad actions do not establish physical touch/gamepad or low-end mobile performance. Owner-operated device acceptance remains outstanding. The ten-minute run covers the fake owned host, not a real persistence endurance guarantee. Play is stopped and the new automatic profiling/regression/journey flags are disabled locally; repository defaults remain opt-in.

## File inventory and inspection

Runtime changes: `src/server/Domain/ProfileCodec.luau`, `src/server/Domain/FleetRecord.luau`, `src/server/Services/ProfileService.luau`, and `src/client/Simulation/OwnedFleetPresentation.luau` only. No schema, solver, prices, geography, lease or adapter changed.

New tests: `FleetFrozenCodec.spec`, `FleetStagingProfile.spec`, `FleetPriceStudy.spec`, `FleetStorageStudy.spec`, opt-in `Fleet11Run.server` and `Fleet11Journey.client`. Existing `OwnedFleetPerformance.spec` adds repeated percentile measurements; `OwnedFleetProgression.spec` exposes an optional analytical observation hook while retaining its ordinary purchase test. Documentation: this report, `PLANS.md`, `DECISIONS.md`; collector: `scripts/CollectFleet11Evidence.py`.

Evidence: [raw Studio output](evidence/national-fleet-expansion-v11/studio-output.txt), [complete parsed measurements](evidence/national-fleet-expansion-v11/measurements.json), [20 unchanged contract hashes](evidence/national-fleet-expansion-v11/source-audit.json). Engine-truncated JSON records remain in raw output; the collector does not invent missing fields.

Actual Studio screenshots: [desktop wind](evidence/national-fleet-expansion-v11/desktop-wind.jpg), [portrait wind](evidence/national-fleet-expansion-v11/portrait-wind.jpg), [portrait Bank](evidence/national-fleet-expansion-v11/portrait-bank.jpg), [full-project Analysis](evidence/national-fleet-expansion-v11/script-analysis.jpg). Portrait is a 360×550 safe-root inside desktop Studio, not a physical-phone capture. The collapsed inspector deliberately scrolls; use Expand to show more controls. The desktop screenshot retains a Rejected control status from deliberate malformed-remote testing, not failed normal generation.

For owner review, connect the Test project on port34873, keep all real execution flags disabled, select the existing local `NationalFleetProof` fake mode and Play. Inspect wind after the normal district/funding/purchase journey; select its marker, compare last completed output/permitted output with next weather potential, scroll/expand details, then open Bank. Stopping Play discards fake progress. Do not enable long opt-in test runners for an ordinary playtest. No publication or real profile access is needed.

## Player-facing clarity

The owned generator inspector now labels last completed permitted output separately from next-interval weather potential, and explains that cap is a limit rather than a target. Wind guidance identifies weather, On/Off and network limits,6-Credit/hour On cost and the need for gas backup. Existing controls, assets,44px targets and Native map are retained. Physical touch/gamepad acceptance remains outstanding unless explicitly recorded below.

## Real schema4 readiness recommendation — not authorized here

After owner balance/storage/performance review, request a separate exact-account/Test-key read-only readiness task. Verify authenticated identity, universe/creator, disabled ordinary startup, uncached current profile and lease, supported versions and both prior investment receipts. Capture a protected full preimage with platform version/user IDs/metadata and SHA256 outside the repo. Produce exact pure v3→v4 diff, immutable baseline equality, no grant/debit/advance and full-profile growth envelope using the actual profile. Stop on any mismatch, corruption, conflicting lease or insufficient size headroom. Separately approve bounded fenced migration with no gameplay, release and uncached readback. A later wind purchase requires another approval and fresh funds/quote/lease preflight. No real readiness read, migration, price change or purchase is inferred from this report.
