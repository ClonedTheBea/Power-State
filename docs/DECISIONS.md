# Decisions, questions and risks

Created 15 November 2026. This is the approval/status register. The owner's supplied brief confirms requirements; **no proposed default in this bootstrap has been approved by the owner**. Implementing a later task may approve its explicit scope, but do not infer approval of every future feature.

## Confirmed baseline

C01: Roblox/Luau, GUI-only, desktop/tablet/mobile, separate fictional countries with an existing imperfect grid.

C02: Physical network delivery with regional aggregated demand; generation alone earns no revenue; authoritative economy/simulation/rewards.

C03: Procedural bounded expansion, Government, maintenance/staff, storage/trade/weather, optional National Eras, permanent history, company profiles/rankings, three news scopes and data-driven global events.

C04: Fully skippable/replayable tutorial and incremental modular development. Operation Christmas Cheer runs annually 1–23 December and exports actual surplus through a temporary Lapland connector.

C05: This task creates documentation only. No application code, dependency installation, publishing, deployment, commit or push. Stop after documentation.

## Proposed architectural decisions

| ID | Proposal and rationale | Alternatives / consequences | Approval needed before |
| --- | --- | --- | --- |
| D01 | Plain strict Luau modules, one country mutation queue, server-only domain logic | Framework adoption adds dependencies; explicit modules are simpler initially | P1 source architecture |
| D02 | Lossless deterministic transport-flow solver with priority/fairness stages | Greedy routing can miss feasible delivery; DC/AC flow adds complexity; transport is not real electrical physics | P2 solver implementation |
| D03 | 1 wall-second step = 1 simulated minute; no offline progress; lag slows simulation | Different speed changes all balance; offline simulation needs bounded catch-up and event exclusions | P2 clock and P3 economy |
| D04 | One-sector starter fixture and straight node-to-node MVP lines | Freehand waypoints and voltage tiers follow later; fixture prices need playtesting | P2/P3 content |
| D05 | One-key active save, 16 sectors/256 nodes/512 lines/64 demand groups, eight countries/server initially | Larger limits require profiling; regional consolidation is unresolved long-term work | P3 persistence; P5a expansion |
| D06 | One consolidated treasury with explicit spending envelopes and delivered-energy billing | Separate government/utility accounts need a transfer/tax model; tariff bounds and growth rates are provisional | P3 economy; P7 Government |
| D07 | Optional eras, bounded legacy tracks and qualifying domestic delivery/reliability | Formula pacing untested; no forced rebirth at world cap | P8 |
| D08 | No debt initially; restricted once-per-era recovery restructuring | Unlimited bailout is exploitable; no aid may create irreversible failure | Public first-playable testing |
| D09 | Fictional policy mandates/elections deferred; policy effects derived at step boundary | Full political simulation is outside current scope | P7 policy; later election work |
| D10 | Staff teams, latent faults, separate inspection/repair and constrained automation | Individual employees add simulation/storage cost; failure curves need tuning | P5b/P6b |
| D11 | Eventually consistent public rankings, no rank-based scarce rewards, actual generation lifetime metric | Rich competition may need stronger index coordination; intentional output farming requires balance review | P9 |
| D12 | Alex Rowan adviser, live onboarding and isolated practice replay, phone bottom sheets | Name/style and exact layout are creative defaults; sandbox must not affect progression | P1 UI; P4 tutorial |
| D13 | Curated logos/colors, safe identity presets initially, filtered free text only after offline-display validation | Free-form uploads require more moderation; raw text must never be fallback | P9 |
| D14 | Global news admission limits and durable announcements with messaging hints | Real-time delivery is not guaranteed; optional celebrations may be suppressed | P10 |
| D15 | UTC event window; domestic-first event export; no import/storage contribution; bucketed cumulative ingestion | Source attribution could allow richer trade; worldwide reconciliation cost is an unresolved scale gate | P11 |
| D16 | Fenced profile lease, 60-second save/180-second lease targets, critical operations durable before success | Requires tested lost-response handling; session-library choice remains open | P3 |
| D17 | Pin tools in P1; choose minimal test harness before extra dependencies | No exact Rojo/test/formatter versions selected or installed; CI setup deferred until repository exists | P1 setup |

Balance numbers in system documents inherit proposal status even when absent from this table. Link a new D-ID when a tuning change materially changes the architecture or player contract.

## Contradictions and clarifications

| Tension / unclear requirement | Proposed resolution | Remaining owner choice |
| --- | --- | --- |
| Virtually unlimited expansion versus finite storage/CPU | Finite disclosed active caps, repeatable upgrades and later tested consolidation | Accept caps and consolidation editing tradeoffs; do not advertise infinite active map |
| Permanent event history versus unbounded records | Compact immutable summaries and paginated archives; no permanent tick/news logs | Capacity plan and account-deletion behavior before launch |
| Both utility owner and national government | One treasury; budgets/subsidies are internal allocations | Whether later independent tax/utility ledgers are desired |
| Sophisticated electricity versus approachable play | Capacity-constrained transport and clear cause labels | Whether DC load flow ever adds enough player value |
| Actual surplus event exports versus domestic reliability | Route domestic first and meter reachable export; conservative import/storage exclusion | Whether explicit domestic-sacrifice policies are desirable later |
| Lifetime generation leaderboard versus no free generation income | Track actual dispatched generator energy; billing only on delivery | Whether purposeful low-value output for ranking is acceptable |
| Offline profiles versus private country and moderation | Sanitized persisted projection with timestamp; safe presets/fallback | Free text scope after filtering tests |
| Rebirth resets infrastructure versus active event progress | Reset connector; preserve contribution, baseline and claims | Rebuild cost/one-time starter connector balancing |
| Global schedules versus no servers online | UTC eligibility computed on server start; no promise of an always-running worker | Whether external scheduling infrastructure is needed later |

## Major risks and mitigation gates

| Risk | Severity | Mitigation / evidence required |
| --- | --- | --- |
| Save duplication/loss from overlapping sessions | Critical | P3 fault-injection and real isolated-universe tests, fencing and no default overwrite on failure |
| Solver too slow or unfair on cyclic grids | High | P2 residual-flow/fairness fixtures and maximum graph profiling; reduce limits or redesign before expansion |
| Exponential progression overwhelms numbers or storage | High | Checked numeric caps, compact history, late-game balance sweeps and approved consolidation strategy |
| Event total loses or duplicates offline contributions | Critical | Durable enrollment registry, cumulative bucket slots and closing reconciliation; load-test before P11 acceptance |
| Derived ranking stale write races | Medium | Eventual consistency labels, canonical projection validation, repair jobs and no competitive reward reliance |
| Full replay contaminates real progress | High | Separate practice state and adapters; tests forbid economy/events/lifetime side effects |
| Mobile map becomes unusable | High | Early touch prototype, viewport culling, actual device validation before claiming support |
| API/tool changes invalidate assumptions | Medium | Official source register dated; reverify at phase start; pin installed versions |
| One treasury makes subsidies confusing | Medium | Internal transfer labels, clear expense ledger, usability tests |
| Automation removes meaningful decisions | Medium | Player policies/budgets, transparent work explanations and enduring capacity constraints |

## Next approval checkpoint

No answer is needed to finish this documentation task. Before implementation, resolve D01, D12's initial layout and D17 tool setup for P1. Before P2, confirm D02–D04 and choose whether to prototype the full fairness algorithm or first prove the single-tier solver contract. Approvals of later balance/event systems can wait until their phases.

Record future changes with date, status (proposed/approved/rejected/superseded), owner/source of approval, rationale, affected files, migration impact and verification required. Do not rewrite a rejected option into an apparently approved historical decision.
