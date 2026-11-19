# Testing and evidence

**Operations v1:** OperationsAtomic/Schedule/Scenario/Security/FleetLifecycle unit suites and Operations/OperationsRemote/OperationsJourney integration suites extend retained oracle/yield/lifecycle and legacy coverage. In the Test mapping only, set ReplicatedStorage `RunOperationsTests=true` and keep `RunRegressionTests=false` before Play to run the opt-in OperationsRun server/client pair. The server finishes pure/resource/scheduling checks before releasing the normal-entry client journey. It injects one bounded two-second calculation delay at minute95; the client also waits beyond the connection-health window before ordinary Retry. Clear the attribute after testing. It is absent by default and excluded from the production runner. No real-service gate is used. Report preparation/install CPU separately from solver slices. [Evidence](NATIONAL-GRID-OPERATIONS-V1-IMPLEMENTATION.md).

**P3a follow-up:** D94–D99 are owner-approved (D100); D104 authorizes the completed single-key real Studio/Test proof. [P3a validation](P3A-VALIDATION.md) records actual create/checkpoint/reconnect/release evidence and remaining service limits. Real start requires the approved account, universe and key; normal bootstrap remains unchanged. Earlier design-only wording below is historical.

**P3a design-only gate:** the [persistence test matrix](P3A-DECISION-PROPOSAL.md#required-test-matrix) adds atomic initialization, fencing, ambiguous writes, same-account races, restore accounting and actual Test DataStore acceptance. No persistence tests have run yet; existing P2a/P2b/P2b.1 results remain regression evidence only.

**P2b.1:** actual eight-client ownership/control/replication checks and generation queue timing/cancellation are covered by `P2b1Multiplayer.spec`, `P2b1.spec`, the dormant cloned `P2b1Probe`, and `P2b1Scheduler.spec`. Live service inspection must run in a server Script context. [P2b.1 procedure, measurements and limitations](P2B1-VALIDATION.md).

**P2b update — 17 November 2026:** P2b validation adds `P2bWorld.spec` (10,000-start sweep, reference/replay/fairness/demand/performance), `P2b.spec` (live generated GUI), `P2bSoak.spec` (ten-minute live generated endurance), and the existing remote suite parameterized for both services. Python climate checks remain independent reference evidence. [Current results and reproduction](P2B-VALIDATION.md).

P2a update,17 November2026: the owner subsequently approved the fixed5 MW generator/3 MW demand/10 MW substation fixture and isolated live implementation. [Current P2a contract and evidence](P2A-VALIDATION.md) supersedes earlier P2a candidate values/status below; future procedural/climate/economy proposals remain unimplemented.

17 November 2026 design gates: [Starting country](STARTING-COUNTRY.md), [Climate/demand](CLIMATE-AND-DEMAND.md), [Minimal simulation](MINIMAL-SIMULATION.md), [Planning](PLANNING-APPLICATIONS.md) and [Demand events](NATIONAL-DEMAND-EVENTS.md) define future golden-seed, fairness, border, energy, replay, idempotency and bounded-work fixtures. These are planned tests, not newly passing runtime suites. Current documentation-only evidence is in [Foundation validation](PROCEDURAL-FOUNDATION-VALIDATION.md).

R3.1 update: the owner requested visual refinement after accepting R3 technically. Current native art/framing, 1,091 passing assertions and 574-map-descendant measurements are recorded in [R3.1 validation](R31-VALIDATION.md). The [modular art recommendation](R31-ART-STRATEGY.md) remains a proposal; no uploads or future gameplay are authorized. Historical R3 measurements below are retained.

Status: P1 uses a dependency-free Studio assertion harness (D17). Simulation and other gameplay fixtures below remain future-phase specifications.

## Current presentation harness (P1/R1/R2/R3)

R3.5: the isolated Test runner retains all existing suites and adds `R35.spec` for real-atlas marker/label presentation, 44px targets, mode/fallback restoration, fixed anchors, bounded movement and cleanup. `ValidateR35.py` checks the two new modules are excluded from the production build. See [current R3.5 evidence](R35-VALIDATION.md); historical counts below remain historical. Production contains no development runner or comparison controls.

R1 adds `tests/unit/CurrencyFormat.spec.luau` (26 cases) and `tests/integration/R1.spec.luau` (16 client assertions). Both passed in Studio. R2 preserves that coverage, revises the existing shell/engine geometry assertions for approved responsive behavior and adds production-controller interaction and ten-minute smoke suites. Current execution evidence, commands and limitations are in [R3 validation](R3-VALIDATION.md); earlier R1/R2 evidence remains historical. R3 adds 190 rendering/interaction assertions, bounded-instance checks and desktop Studio draw/frame profiling while retaining every existing suite.

Run `powershell -File scripts/Validate.ps1` from the repository to build normal/test places and check mapping, strict directives, absence of gameplay remotes/service calls and Git whitespace. This is not a Luau type checker. Studio Script Analysis and runtime tests are separate gates.

`tests/unit/Shell.spec.luau` checks responsive rectangles, breakpoints, inspector states, text enlargement and bounded/anchor-preserving map transforms (324 assertions). `tests/integration/Gui.spec.luau` checks real engine text/control bounds across six safe-root sizes at 100/125/150% local text size (348 assertions), restoring original sizing even on failure. `R2.spec` exercises production route, selection, camera, modal focus and remount behavior. `Soak.spec` repeatedly resizes, pans, zooms and selects for 600 seconds while checking stable GUI instance count. These tests do not synthesize physical gestures or prove hardware performance.

The normal mapping excludes tests. `test.project.json` includes a Studio-only server runner and a manually invoked client GUI suite. See [Studio setup](STUDIO-SETUP.md) for commands and [P1 validation](P1-VALIDATION.md) for evidence and remaining checks.

## Test layers

### GUI redesign documentation and future gates

The design-only task checks Markdown links/anchors, terminology/conflict consistency and theme-token contrast calculations, and compares hashes to prove source/tests/configuration/assets remain unchanged. It does not claim new Studio/device runtime evidence. Existing P1 results remain historical evidence in [P1 validation](P1-VALIDATION.md).

For implementation slices R1–R5 use the [layout validation matrix](GUI-LAYOUT-SPEC.md#migration-and-validation-plan) and [component contracts](GUI-COMPONENT-SPEC.md#validation-contracts): safe areas/short height, 125%/150% text, all input methods, layer/selection persistence, map bounds/clusters, loading/error/empty states, ticker pause/collapse, alert deduplication and payment comprehension. Preserve existing tests; change geometry expectations only for reviewed behavior changes. Do not count a preview as an integration test of live services.

Before live Energy Shop, add fixtures for 1×/2× eligible domestic and export billing, exclusion of grants/rewards, unchanged expenses/physical energy, no stacking, partial-interval expiry, active/paused/offline seconds, reconnect/rebirth, pass acquired mid-boost and currency cap. Fault-inject duplicate quotes/operations, ambiguous commit, stale session, crash after income/before checkpoint, subsequent durable spend, price/ownership lookup failures, cancellation and personal/regional prices. Verify no retained income with restored consumed duration. Real isolated Roblox ownership/payment-flow tests require separate authorization; do not perform purchases during documentation work.

### Established test layers

1. Pure Luau domain tests: graph routing, money, seeded generation, growth, condition, policy and reward formulas. Inject clock/random/catalog; fixtures are serializable and versioned. Runner may be an initially small Studio test harness or an approved dependency, selected in P1.
2. Adapter tests with controllable fakes: remote validation, retries, lease contention, persistence callback replay, outbox recovery and index lag. Fakes must model ambiguous writes and callback retries, not merely return success.
3. Roblox Studio integration in an isolated test universe: real DataStore operations, remotes, multi-client ownership, shutdown behavior, GUI input and API failure reporting. Mocks do not verify actual service budgets.
4. Device/playtest and profiling: desktop, tablet and mobile; low-end device identified before release; cold/warm starts, long sessions and large countries.

Keep deterministic pure suites fast enough to run for every domain change. Run required integration tests when affected adapters change. Repeat broad performance tests when topology limits, algorithms or replication volume change. Save actual output, tool versions and environment in the future phase report; do not label an unrun checklist “passed.”

## Critical test matrix

| Area | Cases and required result |
| --- | --- |
| Flow conservation | Radial, cyclic, parallel and island graphs; sources = sinks within tolerance; no per-link double capacity |
| Congestion | 10 MW source/4 MW line/7 MW load delivers 4; disconnected sink receives zero |
| Dispatch | Lower-cost feasible generation preferred after maximizing priority delivery; reverse residual rerouting finds feasible flow |
| Fairness | Shared bottleneck allocation meets common fraction; rotating remainder does not permanently starve low-ID/high-ID regions |
| Units | 6 MW for 1/60 hour = 0.1 MWh; equivalent time partitions give equivalent billable totals with remainder rules |
| Storage | Full/empty limits, both efficiencies, no same-device simultaneous modes, no lifetime-generation increment |
| Trade | Import/export exclusivity, domestic priority, interconnector capacity and event-source restrictions |
| Weather/faults | Same seed/version/step reproduces output; reload/iteration order cannot reroll bad conditions |
| Economy | No revenue from unused generation; all costs charged once; zero/negative/extreme inputs rejected; resale cannot profit |
| Growth/policy | Growth creates later demand; low reliability suppresses it; policy modifiers enact atomically and budgets pause benefits |
| Construction | Owned/legal route only; crossing lines do not connect implicitly; duplicate and stale quotes do not double charge |
| Maintenance | Inspection only reveals; repair changes condition; exclusive assignments and weather limitations enforced |
| Era reset | Exact-once reward; current state resets; permanent stats/claims survive; stale era request rejected |
| Save/load | Failed load never initializes defaults; successful nil load initializes once; previous/future schema handling |
| Leases | Two servers contend, owner expires, stale owner resumes; only valid token/revision can save |
| Ambiguous writes | Success with lost response; retry returns committed outcome without duplicated money/items |
| Boundaries | NaN, infinity, oversized/deep payloads, wrong owner IDs, command flood and stale revisions rejected cheaply |
| Replication | Dropped delta/resync, stale chunk, mixed snapshot revisions; no other player's private state leaked |
| Profiles | Offline display, safe filtering failure, older projection write rejected, archive reference only after write |
| Rankings | Current money/population decreases, rebirth updates, stale index repair, excluded storage/import generation |
| News | Duplicate/reordered/lost messages, expired leases, global budget; news cannot award money |
| Events | UTC boundaries, year rollover, active/closing states, cumulative max ingestion, offline reconciliation and claim retry |
| Tutorial | Skip/replay/resume each lesson; no sandbox leakage/rewards; missing target fallback |

## Numeric and property testing

Proposed energy comparison tolerance: absolute 10^-6 MWh plus 10^-9 relative for floating-point reports; cash ledger is exact integer minor units with persisted fractional carry. Set tolerance by solver representation and document any change; never round away systematic creation of energy. Run random bounded graph/property cases with reproducible seeds and include failing seeds in fixtures.

Properties: nonnegative demands/flows/energy; capacities respected; money changes equal ledger entries; deletion cannot increase reachable power; adding an unconstrained source cannot reduce maximum served demand under unchanged priorities; routing is invariant to table insertion order; simulation output does not depend on viewport position. Fairness tie-breaking may rotate by step but remains deterministic for a given step.

## Performance workload and gates

Use the proposed envelope of eight countries/server, each up to 16 sectors, 256 nodes, 512 lines and 64 demand groups. Include dense cyclic graphs, long bottleneck chains, rapid topology edits and simultaneous save requests. Measure solver iterations, p50/p95/p99 step time, aggregate work, memory growth, serialization size, remote bytes, GUI object count, frame time and service queue depth.

Initial targets: p95 step <5 ms/country, combined work <40 ms/step spread over frames, normal replication <20 KiB/s/player, active save <512 KiB, and 30 FPS on the chosen minimum device. Targets are unverified and may require smaller caps or a different solver. A ten-minute soak is a smoke test; require a longer multi-hour session and reconnect cycle before public testing. Trigger graph/GUI limits deliberately and verify rejection without charges or leaks.

## Balance and usability gates

Simulate a conservative player, aggressive exporter, high-tariff operator and maintenance deferrer using fixed scenarios. Check viable recovery, no infinite profitable buy/sell/rebirth cycles, finite cost of every revenue source and meaningful capacity constraints with maximum permanent upgrades. Personal event rewards must be achievable at both entry and advanced country sizes without deliberate blackout incentives.

Observe players without coaching: explain MW/MWh, diagnose congestion, connect a settlement, locate a save warning and skip/replay a lesson. Record misunderstanding and revise wording/flows. Verify 44-pixel touch targets, readable text, safe areas, color-independent alerts, scrolling and reduced motion on actual hardware when available.

## Documentation checks and release reporting

For this milestone check all 19 required Markdown files exist, internal relative file links resolve, decision/phase identifiers agree and no application code or dependencies were added. Review specifications manually for clock, units, authority, reset behavior and phase dependencies. These checks validate documents only.

Future phase completion report must list scope delivered, test commands/environment and actual results, known failures/untested manual steps, changed decisions and remaining work. Release blockers include save corruption, duplicated rewards, unauthorized cross-country mutations, unbounded work, invalid energy accounting and unusable primary touch controls. Publishing remains a separately authorized action.


## Grid Reinforcement v1 opt-in Test checks

In Test10776833313 only, use `ReinforcementTests` with other regression flags off. `A` runs pure model/overlay/history checks; `B` adds fake transaction/fault checks; `All` adds actual solver one/seven-day comparisons and normal-navigation client journey. The All journey includes a labelled three-second fake-save delay for pending-state inspection and waits for natural demand peaks; it never sets the simulation clock or gives funds. `Regression` runs reinforced eight-country resources plus retained Operations encoding/atomic/scenario/security/lifecycle/oracle/yield/scheduler gates. Restart Play between runs and clear the attribute afterward. `OperationsV11Legacy=true` separately retains First Playable/P3a/P3b/P3c/10,000-seed and shared GUI coverage.

Use canonical complete-record equality for restored ledgers and permanent receipts; raw JSON property order is not semantic state. Preserve failed logs and test the same assertions after fixes. Screenshots and engine-method input are not physical-device acceptance. Never enable any real execution gate for these suites.

`ReinforcementTests="Capture"` is an optional Test-only evidence runner, excluded from the default build. It first runs A/B and the normal Operations GUI suite, shows an explicitly labelled insufficient-funds presentation fixture (no server financial mutation), then invokes the ordinary quote/confirm actions against the fake host. A12-second injected fake response delay exposes the real pending UI; the saved result and capacity come from the normal transaction. It does not prove a12-second service latency guarantee. Clear `ReinforcementTests`, `ReinforcementReady` and legacy runner flags before ordinary Play. See [final evidence and known limits](GRID-REINFORCEMENT-V1-VALIDATION.md).

## Operations v1.3 opt-in acceptance

Use `OperationsV13="All"` only in Studio Test with other opt-in runner flags unset. An explicit server-ready attribute separates repeated eight-country acceptance from aggressive client viewport tests. Client instrumentation records snapshots, full layouts, measurements, canvas changes, remounts, focus/scroll retention and active presentation time. Five panels remain open for twelve seconds each while authoritative steps advance. Direct CanvasPosition setup is not physical-swipe evidence. `OperationsV13="Server"` repeats startup/fault/economy checks; `"Capture"` runs the ordinary GUI suite then four fifteen-second safe-root capture windows. All are absent from the production build. Clear runner/readiness attributes after Play.

The normal reinforcement journey waits for its specified phase of the unchanged cyclic scenario, so preceding tests cannot make it miss the first peak and assert against an unrelated time. Keep the bounded wait and all electrical/financial assertions. Resource failures retain exact step/status/capital diagnostics plus elapsed time, largest Heartbeat gap and batch counters. Never increase the runtime deadline to make the test pass. [Report and physical-device limitations](OPERATIONS-V13-VALIDATION.md).

## Visual Redesign v1 acceptance runner

In stopped Studio/Test10776833313, set `ReplicatedStorage.VisualRedesignTests` to `Screens` for genuine visual capture pauses and live stability, or `All` for directory/fleet/interaction/remote/reinforcement journey acceptance. Clear other opt-in runners before starting. The runner uses fake storage and refuses other environments. `Screens` logs named12-second capture windows; screenshots must be captured during that window, not inferred from an old log marker. Injected safe-root screenshots are engine layout evidence, not hardware touch/gamepad acceptance.

Retain separate `OperationsV11Legacy=true`, `ReinforcementTests="Regression"`, `OperationsV13="Server"` runs to avoid competing acceptance workloads. No real adapter flags are enabled. Stop Play and clear flags after acceptance. Both Rojo builds/static checks and full-project Script Analysis remain required.
