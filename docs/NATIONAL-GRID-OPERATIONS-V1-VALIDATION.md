# Latest: Stage 1D scheduling investigation

18 November2026. [Stage1D architecture and validation](NATIONAL-GRID-OPERATIONS-STAGE1D.md): resumable exact jobs meet measured candidate targets at native/30Hz service cadence; independent-branch deadline failures remain at throttled15Hz. Owner review required for any formal scheduling contract. The original synchronous16ms gate remains failed and historical evidence below is unchanged. Stages2-3 remain blocked; no gameplay or real persistence integration.

---

# Operations v1 - Stage 1C exact investigation result

18 November 2026. **Stage 1's original acceptance requirements have NOT passed.** The exact cut-constraint candidate passed the retained oracle/differential checks and substantially improved unequal-branch and island workloads, but adversarial, eight-independent-branch and equal-cost batches still exceeded16 ms. Stop for owner review; Stages2-3 remain blocked. No workload, fairness policy, capacity bound or acceptance threshold was relaxed.

## Chosen algorithm and correctness

Implemented a per-solve cut-constraint allocator, with the existing Stage1B preserved as a reference. Failed maximum flows expose necessary subset capacity constraints. The greatest fraction satisfying all learned cuts is certified by a flow; rejection adds a cut and reduces the fraction. Remainders are the exact old rotating single-kW sequence, searched as monotone feasible prefixes. Binding cuts freeze all individually unaugmentable sinks. A second, bounded refinement extends the last certified residual when targets increase; rejected residuals are discarded. Final economic routing is unchanged.

The [correctness argument and bounds](NATIONAL-GRID-OPERATIONS-STAGE1C.md) were written before acceptance testing. It explains cut necessity, maximal feasible fraction, prefix equivalence, monotone freezing and residual continuation. Constraints alone never certify an untested new vector. The eight-round,100,000 kW,4/8/32/48 and2,000,000-edge budgets remain. The algorithm replaces the former fixed binary-flow search with strictly decreasing cut-generated candidates; scalar fraction searches remain over0-1000. The hard operation limit still aborts the entire pure solve, and no partial financial result exists.

Island decomposition was evaluated but not introduced: learned cuts already isolate independently constrained islands while preserving the global persisted-step tie order. Equal-cost economic routing remains the previous shortest-path implementation, preserving stable source selection. No topology or dispatch results are cached across input calls. One tradeoff is more prefix-list work on the simple shared-corridor maximum fixture; that fixture is slightly slower than Stage1B, although still within its batch gate. The improvement is not universal and is not presented as such.

## Exact file inventory

- Added `src/server/Operations/FleetAllocation.luau`: learned sink-subset constraints, certified fraction selection, ordered integer-prefix batching and binding-cut freezing.
- Changed `src/server/Operations/FleetFlow.luau`: expose failed-flow cuts and add certified residual continuation. Capacity encoding and economic routing unchanged.
- Changed `src/server/Operations/FleetSolver.luau`: delegate allocation to the new module; retain validation, canonical sorting, reporting and conservation checks.
- Added `tests/unit/FleetStage1B/FleetNetworkModel.luau`, `FleetFlow.luau`, `FleetSolver.luau` and `source-hashes.json`: exact pre-Stage1C reference copies; earlier `FleetBaseline` also remains.
- Changed `tests/unit/FleetOptimization.spec.luau`: retain every previous workload/assertion; selectable Stage1B comparison, stable source-dispatch assertion, analytical eight-independent-branch case and all-workload timing gates.
- Changed `tests/unit/FleetWorkloads.luau`: added independent-branch and equal-cost fixture factories; original maximum fixture unchanged.
- Changed `tests/unit/FleetProfile.spec.luau`: selectable original/Stage1B/candidate profiling and workload subset.
- Added `docs/NATIONAL-GRID-OPERATIONS-STAGE1C.md` and `NATIONAL-GRID-OPERATIONS-STAGE1C-EVIDENCE.json`; updated this validation report, roadmap and decision register.

FleetNetworkModel in runtime, the original oracle test, legacy solvers, First Playable entry, finance, schemas and real adapters are unchanged by Stage1C. All Operations code remains dormant outside explicit tests.

## Correctness results

- Original suite passed **8,854 assertions**, including all **2,187 independent oracle configurations** and original maximum fixture. Both candidate iterations passed before the final matched run; no oracle case was removed.
- Expanded suite passed **1,037 assertions** for the final candidate. Retains previous852 assertions and adds80 per-source comparisons,96 assertions across eight steps on the new eight-branch graph, and9 independent analytical checks. Previous-solver internal edge routes are not treated as the oracle; per-sink allocation, variable cost, source tie results, conservation and deterministic input permutations/replay are checked.
- The new full-bound graph limits eight branches to1,500,2,000,...5,000 kW. Each receives its exact bound; total26,000 kW. It retains4 sources/8 sinks/32 nodes/48 links. Powered/unpowered islands, reversed/parallel corridors, availability/cost/demand/connectivity changes, exact rotating remainder ties, malformed input and five operation-exhaustion points remain covered.
- Retained engine regressions passed: P2a432, P3c94, P3b93, P3a178 (**797 assertions**). No real services were used.
- Both Rojo builds, strict/source mapping/service-boundary checks and Git whitespace passed. Six static scripts passed597 assertions. Full-project Studio Script Analysis: **0 errors / 0 warnings**, current-script-only unchecked. Two new annotation diagnostics in the residual/profiler code were corrected without behavior changes.

This is evidence for the bounded prototype plus a correctness argument, not exhaustive enumeration of every32-node graph or a claim of full Stage1 acceptance. Existing GUI/device/10,000-seed world-generation suites were not repeated for these dormant pure modules; no new gameplay/UI behavior was introduced.

## Matched measurements and every workload outcome

Same desktop Studio Test session, unchanged fixtures and costs, default2,000,000-operation limit. Stage1B then Stage1C ran **three rounds per workload**, each with40 single solves and10 serial batches of eight. Thus each implementation has120 singles and30 batches per workload, across seven classes (840 singles and210 batches per implementation). All validation and economic routing are inside the timed call; profiler observers are absent from benchmarks. Neither implementation was warmed with cached dispatch answers. Row ranges below are the three per-run p50/p95 values, not pooled percentiles. Batch p95 is the per-run maximum for ten batches. Detailed per-run values, initial failed trials and timestamps are retained in [evidence](NATIONAL-GRID-OPERATIONS-STAGE1C-EVIDENCE.json).

| Workload | Algorithm | Single p50 range ms | Single p95 range ms | Worst single ms | Batch p50 range ms | Worst batch p95/max ms | Max operations |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| small | Stage1B | 0.117-0.124 | 0.154-0.168 | 0.210 | 1.008-1.097 | 1.815 | 781 |
| small | Stage1C | 0.103-0.115 | 0.139-0.190 | 0.208 | 0.881-0.903 | 1.582 | 521 |
| intermediate | Stage1B | 0.666-0.684 | 0.755-0.901 | 1.139 | 5.305-5.616 | 7.530 | 5,341 |
| intermediate | Stage1C | 0.563-0.601 | 0.730-0.910 | 1.022 | 4.452-4.763 | 7.428 | 4,047 |
| maximum | Stage1B | 0.964-1.006 | 1.082-1.096 | 1.396 | 7.806-8.865 | 13.299 | 8,375 |
| maximum | Stage1C | 1.143-1.225 | 1.257-2.008 | 2.057 | 9.159-9.647 | 14.649 | 8,084 |
| adversarial | Stage1B | 13.141-13.648 | 14.521-15.038 | 21.694 | 104.517-108.396 | 126.761 | 148,462 |
| adversarial | Stage1C | 2.691-2.922 | 2.982-4.468 | 4.580 | 21.693-23.052 | 25.537 | 25,195 |
| islands | Stage1B | 2.753-2.952 | 3.253-3.480 | 3.949 | 22.419-23.421 | 25.328 | 34,340 |
| islands | Stage1C | 1.068-1.099 | 1.252-1.344 | 1.418 | 8.447-8.655 | 13.399 | 7,843 |
| equalCost | Stage1B | 1.631-1.712 | 1.849-2.923 | 3.134 | 13.207-13.568 | 16.316 | 10,837 |
| equalCost | Stage1C | 1.776-1.857 | 1.926-2.036 | 2.563 | 14.429-14.736 | 19.561 | 10,546 |
| independent | Stage1B | 13.882-14.681 | 14.494-20.338 | 24.001 | 108.520-109.515 | 113.967 | 165,604 |
| independent | Stage1C | 3.701-3.984 | 3.954-6.788 | 7.124 | 29.177-30.697 | 33.888 | 35,222 |

Final candidate outcomes: **small, intermediate, original maximum and islands pass** their timing gates. **Adversarial, equalCost and independent fail** the16 ms batch requirement. Small p95 remains below2 ms. No final-candidate individual solve exceeded10 ms; its maximum across matched classes was7.124 ms. All cases remained below the hard edge budget. The experimental suite remains red on the failed timing assertions; catching the exception in the temporary comparison runner only allowed recording both implementations and unrelated regressions, not passing the gate.

The first cut-only trial still measured adversarial batch medians23.88-24.72 ms. Residual continuation reduced a subsequent trial to21.65-22.07 ms; the final matched results above remain authoritative and include their variance. No further algorithm changes followed. No failed timings were discarded.

These are synchronous `os.clock` Studio CPU-time measurements, not hosted eight-client, physical-device or end-to-end simulation latency evidence. GC and the existing fake Test GUI can affect timings. No percentile is represented as a hard production guarantee.

## Remaining cost and memory attribution

Separate ten-sample profiles, mean phase ms:

| Workload | Stage | Fair fraction | Integer remainder | Final minimum cost | Residual clones per solve |
| --- | --- | ---: | ---: | ---: | ---: |
| Unequal branches | 1B | 9.5924 | 5.5460 | .2996 | 49 |
| Unequal branches | 1C | 1.3990 | .7387 | .2543 | 14 |
| Powered islands | 1B | 2.0234 | .4653 | .1406 | 15 |
| Powered islands | 1C | .3978 | .3209 | .1150 | 5 |
| Independent branches | 1B | 14.0045 | 1.1756 | .2553 | 76 |
| Independent branches | 1C | 2.2139 | 1.0021 | .1881 | 20.1 |
| Equal costs | 1B | .3756 | .0414 | 1.2757 | 3 |
| Equal costs | 1C | .3247 | .1745 | 1.0057 | 3 |

Stage1B's >10 ms independent/adversarial solves are explained by repeated fair-flow searches; Stage1C substantially reduces that work but still learns several successive cuts on independent branches. Equal-cost routing remains a separate bottleneck. Fraction/remainder phases include their capacity clones; residual-reset time in the evidence is a nested measurement, not additive. Clone counts are exact instrumentation for that table only. Shared `gcinfo()` deltas are GC-sensitive and do not establish total allocation, peak memory or leaks. The candidate also allocates bounded prefix tables (at most ceil(total demand/1000)+sinks+2, each at most8 entries) and at most255 subset cuts, all local to one solve.

## Concrete alternative for owner review - NOT approved or implemented

Recommend reviewing a **resumable exact-solver scheduling contract**, rather than another open-ended series of micro-optimisations. This explicitly changes the current timing acceptance; today's Stage1 remains failed until a separately authorized alternative passes its own tests.

Proposed pure/Test-only scheduling investigation:

1. One immutable solve job per country, maximum eight admitted countries and no accumulated backlog. Snapshot topology, availability, demands, costs, step and revision. Round-robin work across jobs; never prioritize by player wealth or customer identity.
2. Make feasibility, prefix processing and economic routing resumable inside their loops. Retain private residual state; check elapsed CPU and yield at bounded checkpoints (e.g. at most128 edge examinations or32 scalar prefix/cut operations). No yield inside an eventual financial commit.
3. Proposed global budget: **4 ms CPU target per Heartbeat for all jobs combined**, **80 ms aggregate CPU cap for one eight-country interval**, **750 ms elapsed deadline**, retaining **2,000,000 edge examinations per country** and all original graph bounds. These are new proposed limits, not measurements or guarantees. Record slice overshoot explicitly and reject the design if it cannot bound it; do not assume a time check makes a hard real-time scheduler. The80 ms cap gives headroom over the33.89 ms observed candidate batch, but unseen graphs may still fail.
4. Install only a complete, validated result for its exact input revision/step. Commands received while solving apply to a subsequent interval, or invalidate/cancel the job under an explicitly chosen policy; no stale result may be billed. Leave/rejoin, cancellation and shutdown discard incomplete private work. Deadline/work-budget failure must suspend that country's interval with no partial delivery/revenue, no catch-up burst and no repeated settlement. Gameplay integration of that policy would require separate review.
5. Validate all retained oracle/reference outputs independent of yield placement, deterministic replay, every cancellation boundary, revision races, queue bounds, allocation cleanup, eight-job fairness, CPU slice overshoot and deadline behavior at varying Studio frame rates before considering connected gameplay. Keep this as pure/fake scheduler testing; no finance, persistence or Operations UI authority is implied.

This trades same-batch latency for controlled frame occupancy and requires explicit owner approval. It does **not** make the existing16 ms requirement pass. If16 ms synchronous total must remain, an alternative is a separately scoped algorithm research task using a compiled cut-capacity representation and an exact equal-cost dispatch algorithm, with proof of invalidation under source/availability changes and the same failed fixtures. That has uncertain cost/performance; this investigation supplies no guarantee that it will fit. Reducing topology complexity is another explicit gameplay/workload decision, not an authorised fallback.

## Reproduction and stop boundary

With the existing Test mapping in universe10776833313, temporary server runner calls:

- `FleetSolver.spec()` for the retained oracle and original fixture.
- `FleetOptimization.spec(true)` for preserved Stage1B and `(false)` for Stage1C; each intentionally fails if any retained performance gate fails, after reporting every round.
- `FleetProfile.spec(false, true)` for Stage1B or `(false, false)` for candidate phase attribution; profiles must be separate from timed benchmarks.

Require these ModuleScripts from `game.ServerScriptService.DevelopmentTests.unit` during Play. They are not automatic normal startup work. The temporary runner was detached after stopping Play; Script Analysis was reviewed with the whole project selected.

No real DataStore access, Rowanbridge/Production changes, schema4, wind, dispatch gameplay, control room, financial changes, artwork, settings changes, publication, deployment, commits or pushes occurred. Stop here for owner review.

---

## Historical Stage 1B evidence

# Operations v1 — Stage 1B optimisation result

18 November 2026. **Overall Stage 1 acceptance still fails. Stop before Stages 2–3.** The original coupled maximum-size fixture now passes repeatedly, but expanded maximum-bound branch-bottleneck and multi-island workloads fail the unchanged eight-country 16 ms gate. One equal-cost batch also exceeded it. Correctness comparisons passed. No threshold, graph bound, allocation policy, legacy solver or financial contract was changed.

## Changes and preserved baseline

- `src/server/Operations/FleetSolver.luau`: maximum-flow upper bound for the integer fraction search; freeze every sink proved blocked by the same residual cut; reuse the most recent feasible residual for exact one-kW increments; optional profiling observer.
- `src/server/Operations/FleetFlow.luau`: bounded Dinic blocking-flow feasibility; single-kW residual augmentation and failed-search cut; cost-ordered residual maxflow for distinct source costs; original shortest-path economic routing retained for equal costs. Existing shared physical link gates and node gates remain.
- `tests/unit/FleetBaseline/{FleetNetworkModel,FleetFlow,FleetSolver}.luau` and `source-hashes.json`: preserved previous algorithm and original pre-instrumentation SHA-256 hashes. Baseline Flow/Solver have only optional profiling hooks, so their present file hashes differ from the recorded originals; current hashes are also in the evidence package. Baseline files exist only in the Test mapping.
- `tests/unit/FleetSolver.spec.luau`: retains the original 32-node/48-link/eight-sink fixture and every original assertion; adds previous-solver allocation/cost comparison for all 2,187 oracle configurations.
- `tests/unit/FleetWorkloads.luau`, `FleetProfile.spec.luau`, `FleetOptimization.spec.luau`: reproducible fixtures, Test-only profiling, 852 expanded assertions and three repeated benchmark rounds.
- This report, `NATIONAL-GRID-OPERATIONS-STAGE1B-EVIDENCE.json`, `PLANS.md` and `DECISIONS.md`.

No normal entry point requires Operations. FleetNetworkModel's accepted validation and bounds are unchanged. Prior quote work is preserved. No connected wind, dispatch controls, generator accounting, schema4 or control room was implemented.

The flow upper bound only narrows the search; every selected fraction still passes residual feasibility. Failed one-kW reachability proves that other unreachable sink terminals cannot gain under the current fixed peer minima; increasing those minima cannot make them feasible. Reused residuals belong to the same solve and exact target vector. The one-kW remainder ordering and rotating ties are unchanged.

Economic specialisation uses the present model's source-only nonnegative linear costs: maximizing the feasible injection of each increasing-cost prefix yields a minimum-cost source allocation, with reverse residual arcs available to reroute paths. It does not apply to future losses, line tariffs, storage or negative prices. Equal-cost cases deliberately retain the previous economic routing path. Exact edge flows may differ when multiple optimal routes exist; capacities, conservation, sink delivery, cost and deterministic replay are the compatibility contract. Existing sorted IDs provide stable replay.

Topology and dispatch caching across calls were evaluated but not implemented: validation/compile is a small fraction of the failing case, and avoiding mutable-cache invalidation is preferable here. Availability, costs, demands and connectivity changes are covered by the differential tests. No stale result can survive such a change. Profiling callbacks are absent in ordinary solves; the explicit profiler is guarded to Studio/Test and publishes no private country data.

## Confirmed bottleneck and optimisation sequence

Before optimisation, ten maximum-fixture samples measured p50 **85.1518 ms**, p95/max **90.0432 ms**, **607,549** edge examinations. Mean progressive search was **75.8429 ms**, remainder **7.8557 ms**, final cost **1.0506 ms**, validation **0.1656 ms**, compilation **0.1395 ms**, freezing **0.0113 ms**, reporting **0.0265 ms**. Residual reset **0.7139 ms** is nested in those phases, not an additional cost. This confirms repeated fair-feasibility work as the original bottleneck.

Focused iterations, each retaining the 2,187 oracle and previous-allocation/cost comparisons:

| Iteration | Original maximum eight-country batch | Edge examinations | Result on original fixture |
| --- | ---: | ---: | --- |
| Original Stage 1 | 629.6831 ms | 607,549 | Fail |
| Cut grouping + transport upper bound | 40.4046 ms | 32,851 | Fail |
| Blocking flow + residual increment reuse | 14.8494 ms | 11,090 | Single pass, little margin |
| Source-cost specialisation | 7.9358 ms | 8,375 | Pass, then expanded testing below |

Final ten-sample profiling (separate from acceptance timing):

| Workload | Progressive mean | Remainder mean | Cost mean | Validation / compile mean | Residual tables per solve |
| --- | ---: | ---: | ---: | ---: | ---: |
| Original maximum | .3712 ms | .0413 ms | .3342 ms | .1930 / .1233 ms | 3 |
| Unequal branch bottlenecks | **9.0742 ms** | **5.0417 ms** | .2788 ms | .1908 / .1309 ms | 49 |
| Two powered islands | 2.0693 ms | .5136 ms | .1123 ms | .2037 / .1284 ms | 15 |

The original maximum fixture fell from 89 residual clones (50,552 numeric slots) per solve to 3 (1,704 slots). These are instrumented capacity-table counts, not all allocations. `gcinfo()` changes are recorded, including negative values from collection; the shared Lua heap and concurrent fake GUI mean they do not establish exact solver memory, peak usage or absence of leaks. The recursive blocking-flow path is bounded by the transformed graph (at most 162 vertices); no unbounded cache or retained per-country state was added.

The adversarial individual maximum **20.0477 ms** was investigated rather than dismissed as noise: all three runs had p50 about13 ms, and profiling attributes almost all of this to repeated progressive searches and remainder rerouting. Improving compilation alone will not close that gap.

## Correctness and repeated performance

Actual Studio Test runs:

- **2,187 independent signed-flow oracle configurations** passed total delivery, minimum variable cost at the selected allocation and the original fairness envelope; all also matched the preserved solver's per-sink delivery and cost. The full original suite passed **8,854 assertions** after the final optimisation.
- **852 expanded assertions** passed: six larger topologies at eight rotating steps each, 24 successive demand/availability/cost/connectivity mutations, exact replay/input permutations, purity, island reference sums, and atomic exhaustion at five operation budgets. The two-island reference delivers12,500 kW on one island and40,000 kW across seven other buses (5,714/5,715 each); removing the first island's supply gives zero there without contaminating the other island.
- Original maximum remains exactly4 sources/8 sinks/32 nodes/48 links,100,000 kW demand and61,000 kW delivered (7,625 each). Intermediate has four sinks and the same long corridor. The adversarial case retains the full32/48/4/8 bounds, varies eight requests and alternating branch capacities, and reverses parallel-link orientation. Island/equal-cost cases also retain the full bounds; disconnected links remain in the input.
- Original single-source P2a **432**, construction/two-sink P3c **94**, fake economy P3b **93**, fake persistence P3a **178** engine assertions passed after profiling. Legacy algorithms remain independent.

Each row below is **40 individual solves and10 serial batches of eight**, with no profiler observer, no dispatch cache and all validation/cost checks enabled. Three rounds give120 singles and30 batches per workload (720 singles/180 batches overall). Batch p95 equals its maximum with ten samples. All times are ms from `os.clock` around synchronous Studio execution; not hosted eight-client or low-end device evidence. Full values and timestamps are in [sanitized evidence](NATIONAL-GRID-OPERATIONS-STAGE1B-EVIDENCE.json).

| Workload | Run | Single p50 | Single p95 | Single max | Batch p50 | Batch p95/max | Max operations |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| small | 1 | 0.1317 | 0.1769 | 0.2127 | 1.1448 | 1.6680 | 781 |
| intermediate | 1 | 0.7775 | 1.2699 | 1.3528 | 5.8522 | 7.2402 | 5,341 |
| maximum | 1 | 1.3825 | 1.6997 | 1.7559 | 10.2439 | 12.6096 | 8,375 |
| adversarial | 1 | 13.5365 | 18.1190 | 20.0477 | 107.2607 | 118.5392 | 148,462 |
| islands | 1 | 2.8944 | 3.3580 | 4.0038 | 31.0023 | 35.9237 | 34,340 |
| equalCost | 1 | 2.2434 | 2.7521 | 3.5337 | 14.6267 | 15.1801 | 10,837 |
| small | 2 | 0.1252 | 0.2084 | 0.2319 | 1.0247 | 1.1266 | 781 |
| intermediate | 2 | 0.6791 | 1.2242 | 1.2364 | 5.2149 | 7.9830 | 5,341 |
| maximum | 2 | 1.0086 | 1.8995 | 2.0259 | 7.7681 | 8.4442 | 8,375 |
| adversarial | 2 | 13.2911 | 14.4828 | 14.5847 | 105.0948 | 136.7974 | 148,462 |
| islands | 2 | 2.8522 | 3.3189 | 3.5306 | 22.8131 | 24.6731 | 34,340 |
| equalCost | 2 | 1.8409 | 2.2668 | 2.7006 | 13.5299 | 18.5788 | 10,837 |
| small | 3 | 0.1282 | 0.1714 | 0.1787 | 1.0322 | 1.1792 | 781 |
| intermediate | 3 | 0.6892 | 0.9684 | 1.3534 | 5.3658 | 5.8105 | 5,341 |
| maximum | 3 | 0.9973 | 1.1696 | 1.2077 | 7.7910 | 8.0489 | 8,375 |
| adversarial | 3 | 13.2920 | 13.7844 | 14.3489 | 104.5401 | 112.8947 | 148,462 |
| islands | 3 | 2.8005 | 3.0553 | 3.1094 | 22.8776 | 25.3751 | 34,340 |
| equalCost | 3 | 1.6156 | 1.7861 | 1.8361 | 12.9672 | 13.6331 | 10,837 |

**Gate result:** small p95<=2 ms passes; the original maximum fixture's30 batches all pass16 ms; broader maximum-bound batches fail. Maximum operation count148,462 stays below2,000,000, reinforcing that the work ceiling is not a sufficient CPU deadline. No timings or fixtures were discarded. The expanded suite deliberately remains failing with `Stage 1B performance gate` until the approved requirements are met.

Both Rojo builds and static mapping/strict/service-boundary/whitespace checks passed. Six local scripts passed **597 assertions** total: FirstPlayable33, P2a34, P2b38, P3a167, P3b147, P3c178. Full-project Studio Script Analysis showed **0 errors / 0 warnings**, with current-script-only unchecked. These results do not override the failed performance gate. Existing world-generation10,000-seed, GUI/device and endurance suites were not rerun for these dormant pure modules; historical results remain historical, not new evidence.

## Technical alternatives — proposal, not implementation approval

Recommend a separately reviewed **exact parametric/cut-based fair-allocation algorithm** before connected gameplay. Carry residual state through increasing proportional target breakpoints and identify all bottleneck sets directly, rather than rebuilding feasibility for binary fractions across successive branches. It must reproduce the existing quantized fraction, one-kW remainder and rotating tie policy; a mathematically different fairness policy is not an acceptable silent replacement. Preserve this solver and all differential/oracle cases as references. Feasible-set cut calculations and incremental targets need a correctness argument before code changes. Island decomposition and grouped equal-cost routing are secondary exact optimisation candidates, with unchanged global remainder rotation and cross-island economics explicitly tested.

Alternatives requiring owner approval:

1. **Different exact algorithm (recommended):** strongest chance of addressing the measured repeated-search bottleneck while retaining32/48/4/8 and16 ms. Higher implementation/proof effort; no guaranteed performance claim until measured on these failing fixtures.
2. **Revised bounded topology/workload:** constrain branch diversity or smaller fleet/graph limits only if the gameplay tradeoff is explicitly accepted. Merely counting nodes/links does not predict the observed difficulty; shrinking the fixture is not a fix under today's approval.
3. **Separately designed scheduling:** incremental bounded work across frames with immutable interval inputs, cancellation/version handling and atomic result installation could bound frame blocking. It adds latency and suspended/stale-result semantics and does not satisfy the current16 ms same-batch CPU contract by itself. Requires a reviewed scheduling/acceptance change, not moving the same work outside the timer.

No proposed alternative has been implemented. Stop here for owner review. Stages2–3 remain blocked, and no claim of complete Stage1 acceptance is made.

## Reproduction and boundaries

Use the existing Test Rojo mapping in universe10776833313. In a temporary server Script during Play call `require(game.ServerScriptService.DevelopmentTests.unit["FleetProfile.spec"])(true)` for the retained baseline, `(false)` for the candidate, `FleetSolver.spec` for the original suite, and `FleetOptimization.spec` for expanded comparisons/batches. Run timings separately from other heavy regression suites. The benchmark intentionally records all rounds before asserting the failed gate. Remove the temporary runner after stopping Play; do not add these heavy suites to normal startup.

The temporary runner was detached after Play stopped. No real DataStore calls, Rowanbridge changes, Production access, settings changes, new assets, publication, deployment, commits or pushes occurred. First Playable startup and the approved economy/persistence paths are unchanged.

---

## Historical Stage 1 report (superseded only by the Stage 1B observations above)

# National Grid Operations v1 — Stage 1 gate report

18 November 2026. **Blocked at the approved solver performance gate. Stages 2–3 have not begun.** D167 authorizes pure/fake/Test Stages1–3 conditionally; it explicitly requires correctness and performance acceptance before connected gameplay. No threshold or input bound was relaxed.

## Implemented scope and files

- `src/server/Operations/FleetNetworkModel.luau`: strict record/array validation, integer kW/costs, role/reference/identity checks and prototype limits (4 sources,8 sinks,32 nodes,48 links,100,000 kW aggregate).
- `src/server/Operations/FleetFlow.luau`: compiled per-solve node/link gates, shared bidirectional physical capacities, fresh residual capacities, bounded feasibility and successive shortest-path economic routing with reverse edges.
- `src/server/Operations/FleetSolver.luau`: sorted deterministic inputs, proportional progressive filling, binary fraction search, rotating1kW remainder allocation, freeze only after residual infeasibility, then variable-cost minimization for the chosen delivery vector. Pure result includes source output, sink service, signed link flows, node throughput, cost numerator and operation count. It neither settles Credits nor mutates input.
- `tests/unit/FleetSolver.spec.luau`: oracle, residual rerouting, scarcity, branch bottleneck, disconnected customer, substation gate, source economics, large-unit fairness, rotating ties, input permutation/purity, malformed values, work-budget failure, legacy single-sink comparison and performance gates.
- Proposal approval note, roadmap, decision register, this report and sanitized [measurement evidence](NATIONAL-GRID-OPERATIONS-V1-EVIDENCE.json).

Existing GridSolver, DistrictSolver, economy, construction, schema1/2/3, bootstrap, First Playable entry and real adapters remain unchanged by this task. Prior uncommitted quote correction is preserved. Operations modules are dormant: no entry point requires them in ordinary gameplay. No dependencies or assets added.

## Correctness evidence actually obtained

The independent oracle enumerates signed flows on every four-link, two-source/two-sink topology with link capacities0–2kW, source bounds1–3kW and sink requests1–3kW: **2,187 network configurations**. For each, it compares maximum delivery, minimum source cost at the solver's chosen delivery vector, and the declared quantized fairness envelope. Node throughput, reverse transit and physical ratings are included in the oracle. Tiny integer fairness tolerance is intentionally supplemented by analytic large-kW proportional fixtures, rather than treating one-kW tolerance as useful evidence on its own.

Small-suite assertions before timing checks:6,655. Small p95 and eight-country checks passed, giving6,657 assertions in the first run. The expanded run additionally passed9 maximum-bound delivery/fairness assertions before the failing batch assertion. The32-node/48-link network has100,000kW demand,80,000kW available sources and a61,000kW shared corridor (60,000 trunk +1,000 parallel link). Each of eight12,500kW customer buses received7,625kW, with exact total61,000kW.

This is substantial prototype evidence, **not complete solver acceptance** or a formal proof over all supported graphs. Wider multi-island and8-sink oracle coverage, exhaustive affordability/ledger tests and worst-case scheduling remain before connection to gameplay. The old APIs were not replaced: retained P2a432 and P3c94 engine assertions passed in the initial pure-run session. The second expanded runner stopped at its failed performance assertion and did not execute its subsequent legacy suites again.

The abstraction is lossless integer transport, not AC power flow, voltage, frequency or N-1 security. The cost numerator is a solver diagnostic only; there is no new financial ledger or billing in this stage.

## Measured performance and failed gate

Desktop Roblox Studio Test,18 November2026. Measured with os.clock around synchronous solves; not physical-device, hosted multiplayer or GPU evidence. Small workload300 samples, maximum-bound workload40 samples; eight-country values are serial batches of eight independent solves in the same process, not8 connected players.

| Workload | p95 | Maximum | Eight-country batch | Maximum relaxations |
| --- | ---: | ---: | ---: | ---: |
| First small fleet run | .9568ms | 1.6526ms | 6.5111ms | 5,501 |
| Final small fleet run | .9799ms | 1.3980ms | 8.4630ms | 5,501 |
| Full prototype bounds | **85.1707ms** | **94.0892ms** | **629.6831ms** | 607,549 |

Approved small p95<=2ms passes. Approved eight-country<=16ms **fails by about39.4×** on the coupled maximum-size network. All passes together stayed below the2,000,000 relaxation hard budget, demonstrating that this work budget alone is not an adequate frame-time safeguard. Maximum-step timing above10ms is explicitly recorded here; it must not be hidden behind the small fixture result.

At16:11:11 UTC the retained assertion failed with `Required eight-country bounded-network <=16ms gate`. No connected fleet, accounting, wind or interface implementation followed. No automatic reduction to two sinks, higher CPU deadline, relaxed fairness, cached answer tied to stale controls, or fewer correctness checks was substituted.

## Technical review recommendation

The implementation rebuilds residual state and runs repeated feasibility searches for each progressive-fill/freeze round. Long paths, shared cuts, parallel edges and8 sinks raise work from5,501 to607,549 edge examinations. This workload growth is observed; a per-phase CPU attribution has **not** yet been measured. Repeated searches and individual freezing are the principal code-level optimisation candidates, not a proven timing breakdown.

Recommend a focused Stage1 optimisation/review before gameplay:

1. Instrument feasibility, remainder allocation and final min-cost routing separately, plus allocation/compile/reset costs. Retain this failing32/48/8 fixture and all timing assertions.
2. Evaluate cut-based freezing of a whole bottlenecked group and reusable residual/feasibility state. Cache topology only under an immutable topology-version key; source caps, wind, demand and cost changes must still recompute a correct allocation.
3. Compare every optimized result against the independent oracle and old candidate, retaining approved fairness error, deterministic rotation, min-cost objective and atomic failure behavior. Any altered allocation rule requires owner review.
4. Repeat small and maximum-bound batches, adversarial reorderings, shared/parallel cuts and independent islands. Only connect the scenario if the original gates pass. If these techniques cannot fit, propose a reviewed different algorithm or workload limit; do not change either silently.

No optimisation above is implemented or accepted by this report. Stage1 remains incomplete. Recommended next work is solver review, not purchases, real migration or a new gameplay phase.

## Other validation and boundaries

Both Rojo builds passed, along with strict-directive, source mapping, service-boundary and Git whitespace checks. Local ValidateFirstPlayable, ValidateP2a, ValidateP2b, ValidateP3a, ValidateP3b and ValidateP3c scripts passed. Full-project Studio Script Analysis showed0 errors/0 warnings after correcting new test-lambda and comparator annotations. These checks do not override the runtime performance failure.

The current task did not repeat all P2b world/fairness, P3a/P3b engine persistence, First Playable GUI or device suites: dependent stages were stopped, and their unchanged prior acceptance remains historical. No new snapshots, UI responsiveness, map descendant or control-room screenshot results exist because no Operations host/UI was built. Existing Native map/normal fake starter remain available. No claim of real storage, fake reconnect, forecast, wind or generator billing acceptance is made.

The temporary server-only solver runner was detached after Play stopped. Normal fake entry remains unchanged; all real-service gates remain closed. No real DataStore access, Rowanbridge modification, schema4 code, permanent purchases, Production, permissions, uploads, commits, pushes, publishing or deployment occurred.

## Future persistence boundary retained

Schema4/ledger4 remains design only. Future approval must preserve legacy identities, versions, history, grant, exact Bank/carries and permanent district receipt; define a non-retroactive cutover and per-generator expense reconciliation; retain atomic whole-country purchases, fencing and replay. No free wind/peaker or new customer demand may appear through migration. Those requirements are recorded in the approved proposal, not implemented here.

## Reproduce the blocking test

Use the Test Rojo mapping in universe10776833313. From a temporary server Script in a Play test, call `require(game.ServerScriptService.DevelopmentTests.unit["FleetSolver.spec"])()`. This pure suite creates no storage adapter or gameplay scenario. Observe oracle/small timing output followed by the maximum-bound timing and unchanged assertion. Detach temporary validation scripts afterward. Normal player startup must not invoke this failing experimental solver.
