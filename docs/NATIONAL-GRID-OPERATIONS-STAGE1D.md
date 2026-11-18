# National Grid Operations - Stage 1D scheduling architecture and validation

18 November 2026. **Investigation complete; owner review required.** Whole-solve staggering exceeded the4 ms frame target. Resumable exact jobs met the measured4/80/750 targets for every retained workload at native and throttled30 Hz service cadence, but the independent-branch workload failed the750 ms deadline at throttled15 Hz in all three final rounds. No hard real-time bound has been proved. The original16 ms synchronous eight-country gate remains **FAILED**; it was rerun and not relabelled. Stages2-3 remain blocked.

## A versus B

**A - one complete solve per Heartbeat opportunity:** least complexity and lower total CPU, with a rotated country order across rounds. Existing Stage1C solver executes once per country against a validated, copied, frozen network. One expensive country still blocks that whole frame. Across63 final intervals,9 missed a proposed target (frame spikes and one elapsed-deadline miss). Worst frame6.303 ms; worst whole interval37.380 ms CPU. Measurement harness never installs results into gameplay.

**B - resumable exact jobs:** same solver arithmetic, graph, cut constraints, remainder order, cost objective and operation counts. Lua coroutine stacks retain residuals, searches and cut state; completed searches are not restarted. Cooperative checkpoints occur every128 edge examinations by default, plus bounded scalar/phase boundaries. Tests also force every checkpoint at edge quantums1 and16. The scheduler gives round-robin400 microsecond service quanta, with4 ms aggregate Heartbeat target and250 microseconds of reserved headroom for checkpoint/control overshoot. Maximum64 resumes per scheduler step; jobs continue on subsequent frames without catch-up loops.

The candidate is a scheduling prototype, not a faster arithmetic algorithm. It adds CPU and retained state while reducing frame blocking. Final peak3.959 ms and aggregate46.862 ms were observed, not guaranteed. Native/30 Hz completion passed;15 Hz independent jobs were discarded on deadline. There is no fallback that silently relaxes the deadline or switches to an oversized complete solve.

## Implementation and changed files

New server modules:

- `src/server/Operations/FleetJobSnapshot.luau`: strict envelope and existing bounded network validation; private copied/frozen scalar records and metadata; version-stamp comparison.
- `src/server/Operations/FleetJobScheduler.luau`: explicit Studio/Test-only, eight-country single-interval scheduler; bounded admission, round-robin slicing, ownership/revision predicate, deadline/CPU/operation failure, cancellation, single-use result handoff and cleanup. No automatic Heartbeat connection or normal startup.

Changed solver modules:

- `FleetSolver.luau`: optional private checkpoint control around validation, compilation, allocation, routing and reporting. Default synchronous call remains available.
- `FleetFlow.luau`: checkpoint every configured1-128 edge examinations, after the existing cumulative operation-budget check.
- `FleetAllocation.luau`: checkpoints around rounds, cut tests, feasibility, ordered-prefix generation and freezing. No fairness/cost formula changed.

New Test files:

- `tests/unit/FleetStage1C/{FleetNetworkModel,FleetFlow,FleetAllocation,FleetSolver}.luau` and `source-hashes.json`: exact frozen pre-scheduling reference.
- `FleetStagger.spec.luau`: Approach A measurements, immutable inputs, full report equivalence, rotated order and three service cadences.
- `FleetYieldOracle.spec.luau`: forced-yield and input-permutation equivalence over all2,187 oracle configurations, full workloads, unpowered islands and changed demand/cap/cost/connectivity sequences.
- `FleetScheduler.spec.luau`: lifecycle, ownership, replay, cleanup, bounded queues, injected faults and cancellation audit.
- `FleetSchedulePerformance.spec.luau`: eight simultaneous jobs, actual Heartbeat waits, three rounds at three service cadences, every workload, latency/CPU/slice/cleanup evidence.
- `FleetWorkloads.luau`: exposes the unchanged intermediate fixture as a shared helper.

Documentation: this report, `NATIONAL-GRID-OPERATIONS-STAGE1D-EVIDENCE.json`, main Operations validation status, `PLANS.md` and `DECISIONS.md`. Existing oracle and expanded Stage1C test modules remain intact. No First Playable, legacy solver, generation scheduler, economy, schema, persistence or GUI code changed.

## State, version and cancellation contract

Each admitted snapshot binds country identity, session epoch, simulation step, country revision and topology revision to the exact network, source availability/effective caps, demand and variable costs. There is no wind model yet; future wind potential/cap changes must participate in the same versioned immutable input contract before integration. No client values or real profile data are involved.

States are `pending -> ready -> consumed`, or terminal `cancelled`, `stale`, `deadline`, `cpu-limit`, `failed`; `close` releases the whole interval. Ready means computation completed, **not electricity or money settled**. `take` revalidates the owner/version/deadline and allows one candidate handoff; a second call returns nil. A lookalike or old-interval handle cannot access another interval. Eight country slots are reserved for the interval, including tombstones, so cancellation cannot create an unbounded retry queue. No country can have overlapping/replayed jobs inside that interval.

Chosen command policy for this prototype: **explicit invalidation**, not commands silently applied to an in-progress snapshot. A server-side generator command must atomically advance the relevant country revision; the ownership/version predicate then rejects that job before further work or handoff. No automatic replacement is enqueued. A later explicitly admitted interval may use the newly validated inputs. Same-epoch input mutations without a revision change violate the coordinator contract and must not be permitted by a future integration. Copies protect jobs from mutable caller tables; they cannot compensate for an authority that lies about its own version.

On leave, cancel the handle; its thread, input and result references are released. Rejoin uses a fresh explicitly created interval and current epoch. Late old handles remain inert. Deadline/CPU/work-budget/ownership failure yields no usable candidate, no partial energy/financial state and no accumulated catch-up intervals. The prototype records a terminal reason; a future UI would show operations suspended/unavailable until a deliberate safe retry. Ordinary menus and the existing game are unaffected.

Cross-interval replay protection ultimately belongs to the server owner's cursor and atomic commit: after a non-yielding fake installation advances step/revision, a fresh scheduler rejects the old stamp. This was tested. The scheduler is not a durable ledger and does not implement an economic commit. Future integration must compare the expected stamp and install delivery/history/financial state atomically in the existing serialized country coordinator, with no yield between validation and installation. That integration is outside this approval. No yields occur in DataStore callbacks or financial commits because this prototype calls neither.

## Correctness and failure tests

- Retained independent oracle: **2,187 configurations**, full original suite **8,854 assertions**.
- Retained expanded Stage1C correctness: **1,037 assertions**; its synchronous performance assertions still fail and remain recorded. Catching that failure in the temporary runner permits independent safety tests; it does not mark it passed.
- **9,100 full-report yield/permutation comparisons** against the frozen Stage1C solver. For2,187 oracle configurations,56 workload/step cases,8 unpowered-island cases and24 changing-input cases, compare quantums1/16/128 and a reversed input permutation. Full report includes sink allocation, source output, minimum cost, physical flows, operation count and freeze rounds.
- **1,486 scheduler assertions** passed. Includes all12 checkpoint types and cancellation separately at **every one of1,395 actual checkpoint occurrences** in an independent-branch solve. This audits that graph and quantum128, not every possible checkpoint sequence of every graph.
- Stale step/topology/country revision/session, generator-cap command invalidation, cancellation after completion, old handles after rejoin, one-use handoff and cross-interval cursor rejection passed. No incomplete result escaped.
- Injected750 ms deadline,80 ms CPU-limit and operation-limit failures discarded results; malformed input admitted no job. Queue admission rejects a ninth country and overlaps. Identical jobs received progress with round-robin resume counts differing by at most one in the fairness check; benchmark admission order rotates across rounds without affecting outputs.
-32 repeated cancellation cycles each admitted8 jobs: pending/retained residual count returned to0 before closing every interval. The final cancellation census repeated that release assertion1,395 times.
- Retained engine P2a432/P3c94/P3b93/P3a178 assertions passed (**797** total). Six static suites passed597 checks. Both Rojo builds and mapping/strict/service-boundary/whitespace checks passed. Full-project Studio Script Analysis: **0 errors / 0 warnings**, current-script-only unchecked.

No new world-generation10,000-seed, GUI/device or hosted multiplayer acceptance is claimed. Those systems were not changed. Eight jobs are eight immutable fake country problems in one Studio server, not eight networked players.

## Final measurements across all workload classes

Each approach: seven workload classes, three rounds at each of three service cadences = **63 eight-country intervals /504 solves or attempted solves**. Final metrics include admission validation/copy CPU and all timed solver/scheduler work. Full report encoding used for test assertions is outside solver timings. Earlier runs, including the diagnostic latency-unit error, are retained separately in [sanitized evidence](NATIONAL-GRID-OPERATIONS-STAGE1D-EVIDENCE.json); the earlier seconds values are explicitly converted there. Final latency diagnostics are milliseconds.

Native uses actual Studio Heartbeat opportunities.30/15 Hz mean the harness throttles service to at most that rate while Studio continues its normal Heartbeats; frame quantization/jitter often makes the effective cadence lower. These are **not Studio settings changes, forced rendering frame rates or low-end device measurements**. Active work uses `os.clock` around synchronous resume/solve segments as a CPU-time proxy; elapsed completion includes waits. GC/OS scheduling can inflate active segments, so this is not an OS per-thread CPU counter or a hard real-time proof.

Each cell below is the maximum across three final rounds; **A / B** means whole solve / resumable. B completions are results handed off before expiry, out of24 attempted country solves per row. A does not perform a gameplay handoff; an over-deadline measurement is a failed target even if its pure calculation finished.

| Service cadence | Workload | Aggregate CPU ms A / B | Peak frame ms A / B | Elapsed interval ms A / B | B valid completions |
| --- | --- | ---: | ---: | ---: | ---: |
| Native | small | 1.749 / 1.591 | 0.292 / 1.383 | 130.015 / 13.265 | 24/24 |
| Native | intermediate | 6.237 / 7.002 | 1.085 / 3.765 | 128.014 / 27.703 | 24/24 |
| Native | maximum | 12.634 / 14.738 | 1.943 / 3.769 | 124.237 / 55.406 | 24/24 |
| Native | adversarial | 25.572 / 33.202 | 5.136 / 3.810 | 113.176 / 126.285 | 24/24 |
| Native | independent | 32.758 / 46.862 | 4.877 / 3.776 | 120.055 / 199.559 | 24/24 |
| Native | islands | 11.029 / 13.186 | 1.609 / 3.772 | 121.037 / 55.727 | 24/24 |
| Native | equalCost | 16.647 / 19.149 | 2.779 / 3.776 | 117.518 / 65.111 | 24/24 |
| 30 | small | 1.598 / 1.578 | 0.249 / 1.342 | 346.969 / 47.101 | 24/24 |
| 30 | intermediate | 6.598 / 7.813 | 1.113 / 3.772 | 344.917 / 94.565 | 24/24 |
| 30 | maximum | 10.602 / 16.051 | 1.302 / 3.767 | 372.772 / 170.922 | 24/24 |
| 30 | adversarial | 26.535 / 34.436 | 4.900 / 3.775 | 361.343 / 371.557 | 24/24 |
| 30 | independent | 32.956 / 44.608 | 5.313 / 3.937 | 334.943 / 481.783 | 24/24 |
| 30 | islands | 10.034 / 12.989 | 1.511 / 3.773 | 370.520 / 186.372 | 24/24 |
| 30 | equalCost | 17.148 / 20.340 | 2.359 / 3.781 | 333.701 / 261.748 | 24/24 |
| 15 | small | 1.570 / 1.769 | 0.249 / 1.394 | 611.407 / 80.776 | 24/24 |
| 15 | intermediate | 6.325 / 7.855 | 1.190 / 3.771 | 610.752 / 160.621 | 24/24 |
| 15 | maximum | 11.332 / 18.902 | 1.655 / 3.828 | 589.636 / 369.883 | 24/24 |
| 15 | adversarial | 24.690 / 31.977 | 3.917 / 3.773 | 793.436 / 674.351 | 24/24 |
| 15 | independent | 37.380 / 39.120 | 6.303 / 3.959 | 583.573 / 817.259 | 0/24 |
| 15 | islands | 10.687 / 12.582 | 1.624 / 3.767 | 619.907 / 305.715 | 24/24 |
| 15 | equalCost | 17.305 / 21.002 | 2.561 / 3.782 | 600.586 / 431.944 | 24/24 |

Across native and30 Hz, **all42 B intervals /336 countries** completed with measured peak<=4 ms, aggregate<=80 ms and elapsed<=750 ms. At15 Hz,18/21 intervals completed; all three independent-branch intervals returned0 valid results. Their cleanup was observed on the next service opportunity, as late as817.259 ms. The deadline prevents handoff after750 ms; it cannot make code execute at exactly750 ms while the thread is not scheduled. The states correctly became `deadline`, with no retained residuals afterward.

All final B frame overshoots above4 ms were0 in these samples; per-slice arrays and per-country terminal/completion latencies are retained. A's worst measured overshoot was2.303 ms (6.303 ms whole solve). Neither timers nor these samples prove a hard4 ms bound. Validation/compilation and bounded between-checkpoint work are not preemptible; GC, allocation, OS suspension and the trusted owner predicate can overrun. The owner predicate used here is pure, bounded, non-yielding stamp comparison; no service call is allowed in it.

Memory: active/ready state is at most8 jobs, at most255 cuts and the existing bounded residual/prefix structures per job. Results/threads/input snapshots are cleared on terminal failure or consumption; remaining8 small interval records/tombstones disappear on close. `gcinfo()` observations, including negative deltas from collection, are in the evidence and do not prove a peak-byte ceiling or absence of all leaks. The initial32-cycle cancellation run reported-405 KiB shared-heap change; structural release checks are stronger evidence than that noisy value. No per-country state survives through an automatic backlog.

## Proposed formal replacement contract - owner decision pending

Recommend **B as the architecture to review**, not unconditional acceptance of Stage1 or a claim that scheduling made the synchronous benchmark pass.

A possible replacement would require:

1. Preserve exact outputs, all graph bounds,2,000,000 cumulative edge ceiling, immutable versions, one-job-per-country, maximum8 jobs, cancellation/cleanup and no partial installation.
2. At native and a separately accepted **minimum supported30 Hz service cadence**, every retained workload in repeated tests must deliver all eight valid results within750 ms and80 ms aggregate active CPU. Maintain4 ms global solver frame target, record every overshoot and investigate any measured exceedance; the owner must explicitly accept that this is a cooperative target rather than a mathematical hard bound.
3. Below the supported cadence or on deadline/CPU failure, discard results and suspend the affected interval without catch-up or partial settlement. Repeated failures must be visible, not silent demand loss. The15 Hz failures demonstrate this behavior but do **not** pass a15 Hz performance requirement.
4. Before connected gameplay, separately design atomic result installation, command acknowledgement/invalidation UX, ownership-loss handling and safe recovery. Verify real hosted-server workload interference, longer-running memory behavior and scheduler overshoot distribution. Do not reuse this pure proof as financial/persistence authorization.

The30 Hz support boundary is a **new proposal**, not an approved exemption. If the owner requires all15 Hz workloads to finish within750 ms and4 ms per-frame target, this prototype does not qualify. Options requiring review include a longer low-cadence deadline, a different CPU allocation policy, or further exact algorithm work; none was implemented. Raising limits or dropping the independent fixture is not an automatic fallback.

## Reproduction and stop

In the existing Test Rojo mapping (universe10776833313), temporary server runner calls `FleetScheduler.spec`, `FleetYieldOracle.spec`, `FleetStagger.spec` and `FleetSchedulePerformance.spec` under `game.ServerScriptService.DevelopmentTests.unit`. Run original `FleetSolver.spec` and `FleetOptimization.spec` separately; expect the broader synchronous performance gate to remain red. No normal bootstrap invokes the scheduling modules or test suites.

The temporary runner was detached after Play stopped. Production, Rowanbridge, real DataStore records, normal First Playable startup, financial accounting, wind simulation, schema4, construction, control room and artwork remain untouched. No settings changes, uploads, publication, deployment, commits or pushes occurred. **Stop after Stage1D for owner review; do not begin Stages2-3.**
