# Testing and evidence

Status: automated tests for critical systems are required. Runner/tool selection and thresholds are proposed D17. No gameplay code exists and no gameplay tests have run in this documentation milestone.

## Test layers

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
