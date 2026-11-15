# Development roadmap

Status: proposed implementation sequence. P0 is this documentation milestone. **Stop after P0 until the owner requests implementation.** Each later phase is independently reviewable; acceptance requires observed evidence, not only written specifications. See [Decisions](docs/DECISIONS.md) for approvals and [Testing](docs/TESTING.md) for shared gates.

P1–P4 together produce the first playable. A passing phase does not authorize installation, publishing, committing or pushing outside the user's instructions. At each boundary report actual deliverables, checks run, manual Studio work and remaining limitations.

## P0 — Blueprint (current task)

- **Scope:** inspect existing folder; produce the 19 requested Markdown documents and verify current API/tool recommendations using official sources.
- **Dependencies:** supplied product brief; access to local folder and official documentation.
- **Deliverables:** documentation index, system contracts, decision log, risk register and phased roadmap.
- **Acceptance:** all requested files exist; local links resolve; proposals and confirmed requirements are distinguished; no application code/dependencies or publication changes.
- **Testing:** document completeness/link checks and manual consistency review. Gameplay tests are not applicable yet.
- **Out of scope:** implementation, tool installation, Git initialization, Studio configuration and deployment.

## P1 — Development foundation and responsive GUI shell (recommended next)

- **Scope:** choose/pin authorized tooling, establish proposed client/server/shared structure and a responsive GUI shell. Resolve D01, initial D12 choices and D17.
- **Dependencies:** P0; owner implementation request; authorization for any necessary installations; available Studio access.
- **Deliverables:** reviewed Rojo mapping, minimal server/client entrypoints, navigation/header/map placeholders, selected test harness and documented local workflow. Git/GitHub setup only if authorized.
- **Acceptance:** shell runs in Studio; desktop, phone and tablet layouts expose primary controls without clipping; client/server boundaries are clear; exact installed versions and manual setup are documented.
- **Testing:** build/type checks available in the selected toolchain; Studio launch; resize/touch-emulation checks; basic harness verification.
- **Out of scope:** persistent player data, electrical dispatch, money, real construction and all social systems.

## P2 — Small country and electricity slice

- **Scope:** starter map/asset fixture, fixed simulation clock, one generator type, aggregate demand, substations and capacity-constrained transmission. Resolve D02–D04.
- **Dependencies:** P1; pure domain test harness.
- **Deliverables:** deterministic country fixture, NetworkModel/GridSolver, report contract, map selection and supply/congestion/disconnection displays.
- **Acceptance:** existing 7 MW connected demand is served in the starter fixture; a 4 MW bottleneck only delivers 4 MW; an isolated settlement receives zero; all accounting invariants pass and state remains server-owned.
- **Testing:** pure flow/unit/replay fixtures, cyclic/parallel-edge rerouting, server-client isolation and initial profiling. Compare fair allocation prototype separately before enabling extra priority tiers.
- **Out of scope:** save/load, construction purchases, population growth, staff, storage and trade.

## P3 — Construction, economy and persistence

- **Scope:** straight legal connections, basic gas construction, money, domestic billing, bounded population growth and safe save/load. Resolve D05/D06/D16 and review D08 recovery before external playtesting.
- **Dependencies:** P2; isolated Roblox test experience and API access configured by an authorized operator.
- **Deliverables:** validated command gateway, atomic build ledger, derived demand/growth, profile schema/migrations, fenced session lease, save-status UI and bounded retry handling.
- **Acceptance:** player connects an unserved settlement, earns only from delivered MWh, builds capacity, observes population-driven demand and reloads the latest durable country; duplicate build requests charge once; failed loads do not create defaults.
- **Testing:** economy arithmetic, command abuse, save/reload, dual-session contention, ambiguous writes, lease expiry, invalid routes, size limits and real isolated DataStore integration.
- **Out of scope:** complex industries, taxes, extended world generation, maintenance, offline income and National Eras.

## P4 — Introductory tutorial and first-playable review

- **Scope:** implemented tutorial lessons, contextual help, isolated practice replay and basic shortage recovery. Complete D12 review.
- **Dependencies:** P3 complete loop; safe practice-state isolation.
- **Deliverables:** Chief Grid Adviser lessons 1–4/6 and independence review, skip/resume/replay controls, technical glossary, usable phone/tablet workflows and first-playable test report.
- **Acceptance:** a new player can inspect, connect, deliver, earn, grow, save and reload; every implemented lesson can be skipped/replayed; practice never changes real totals; a shortage can be recovered without resetting the save.
- **Testing:** guided usability observation, all lesson transitions, reconnect/resume, zero-funds recovery scenario and actual touch-device checks when available. Record hardware checks still outstanding.
- **Out of scope:** full ten-lesson content for unimplemented systems, public release/publishing, seasonal events and advanced progression.

## P5a — Procedural sectors and bounded expansion

- **Scope:** seeded adjacent-sector acquisition, terrain construction costs, legal sites, chunked map rendering and capacity guards.
- **Dependencies:** P4; D05 accepted engineering envelope; save schema prepared for seed/version/deltas.
- **Deliverables:** WorldGenerator, discovery/purchase commands, stable sector IDs, zoom detail/culling and limit UI.
- **Acceptance:** discovery order and reload preserve identical sectors; terrain visibly affects quotes; offscreen demand still simulates; limits reject before spending.
- **Testing:** generator fixtures across versions/coordinates, geometric route checks, save-size profiling and maximum map device tests.
- **Out of scope:** regional consolidation, unlimited active maps, voltage tiers and complex resource extraction.

## P5b — Condition, inspections and repairs

- **Scope:** wear, latent faults, ground inspection, ground repair teams and blackout recovery. Resolve first D10 settings.
- **Dependencies:** P5a; persistent orders and cost reservations.
- **Deliverables:** AssetService condition/fault model, staff team records, work-order state machine and tutorial lesson 5.
- **Acceptance:** inspection reveals without repairing; paid completed repair restores an isolated asset; failures are deterministic; recovery remains achievable on low funds.
- **Testing:** seeded faults, exclusive assignments, cancellation/refunds, interrupted orders and planned-outage accounting.
- **Out of scope:** helicopter/drone methods, managers, detailed employee personalities and all 3D vehicles.

## P6a — Generation mix, weather, storage and trade

- **Scope:** coal, nuclear, solar, wind and hydro definitions, regional weather, batteries and bounded international contracts.
- **Dependencies:** P5b, stable report contract and expanded dispatch tests.
- **Deliverables:** technology catalog/prerequisites, variable availability/fuel costs, storage ledger, interconnector source/sinks and tutorial lesson 7.
- **Acceptance:** each technology has a meaningful constraint; storage conserves energy with losses; imports/exports obey connection ratings and bill once; no electricity appears across islands.
- **Testing:** night/calm/drought/outage fixtures, storage full/empty and rounding, trade exclusivity and worst-case solver profiling.
- **Out of scope:** AC/DC electrical physics, fuel logistics chains, player-to-player trading and global events.

## P6b — Inspection technology and bounded delegation

- **Scope:** helicopter/drone inspection plus grid operators, engineers, maintenance managers and energy traders.
- **Dependencies:** P6a and P5b orders; approved D10 automation policies.
- **Deliverables:** distinct inspection capabilities, policy/budget controls, manager scheduling and explanation feed.
- **Acceptance:** weather/range restrictions matter; managers cannot exceed budget/reserve or bypass player command checks; player can pause automation and inspect decisions.
- **Testing:** simultaneous reservations, weather cancellations, no inspection reroll exploit, bounded scans/queues and long-session cost balance.
- **Out of scope:** autonomous government policy selection, full employee career simulation and research management until P7.

## P7 — Government, research and industry

- **Scope:** tariff and efficiency policies, subsidies within one treasury, approval/industry effects, one research chain, one national project, research manager and government adviser roles.
- **Dependencies:** P6b; D06/D09 policy model; bounded order/budget services.
- **Deliverables:** Government tab, DerivedModifiers, DAG research, staged project commissioning and tutorial lessons 8–10 including practice emergency.
- **Acceptance:** policies change actual demand/cost/growth; unfunded programmes pause; project completion creates ordinary constrained assets once; full ten-lesson tutorial is available and replayable.
- **Testing:** policy toggle exploit, DAG cycle detection, project retry, budget exhaustion, industry feedback and full tutorial regression.
- **Out of scope:** elections, party politics, independent tax accounts and macroeconomic simulation.

## P8 — National Eras and permanent progression

- **Scope:** eligibility, preview/confirmation, atomic reset, legacy tracks and preserved lifetime/history. Resolve D07/D08 progression balance.
- **Dependencies:** P7; critical persistence and reward operations proven.
- **Deliverables:** era UI/service, eligibility report, permanent-upgrade catalog and migration fixtures.
- **Acceptance:** reset applies once or not at all after failure; current infrastructure/money/population reset; lifetime statistics/achievements persist; a player can decline and continue playing.
- **Testing:** lost response, reconnect during reset, old request replay, max numeric thresholds, maximum-upgrade stacks and no starter-money farming.
- **Out of scope:** forced rebirth, premium boosts, profiles/rankings publication and event participation until their phases.

## P9 — Company profiles, achievements and rankings

- **Scope:** offline public projections, curated customization, achievements, compact history and three server/global boards. Resolve D11/D13.
- **Dependencies:** P8 durable totals; safe text/cosmetic catalog; tested publication budgets.
- **Deliverables:** profile read/view service, idempotent achievement claims, archive pagination, ranking publisher/cache and stale-state UI.
- **Acceptance:** offline profiles work without exposing private saves; current boards decrease after rebirth/spending; lifetime generation survives; public text always uses safe filtering/fallback.
- **Testing:** stale projection/index races, throttling, offline reads, achievement retry, filtering failure and archive write interruption.
- **Out of scope:** rank-based scarce rewards, arbitrary image uploads, public messages and player trading.

## P10 — National, server and global news

- **Scope:** scoped template feeds, deduplication, durable important global announcements and rate-limited publication. Resolve D14.
- **Dependencies:** P9 sanitized identity and domain events.
- **Deliverables:** NewsService, three filtered views, coordinator lease/hint channel and durable polling recovery.
- **Acceptance:** national news stays private, server news stays scoped, global volume is bounded and missed messaging does not lose an essential durable announcement.
- **Testing:** dropped/duplicate/reordered notifications, coordinator replacement, rate-limit saturation and identity filtering.
- **Out of scope:** chat, unrestricted user-authored news, rewards based on received notifications and scheduled event gameplay.

## P11 — Data-driven events and Operation Christmas Cheer

- **Scope:** event definition/state machine, temporary Lapland connector, eligible export meter, personal/community objectives, cosmetics/currency and permanent records. Resolve D15 and perform capacity planning before release.
- **Dependencies:** P6a physical trade, P8 idempotent progression, P9 history, P10 news and tested durable event registry/reconciliation.
- **Deliverables:** reusable objective handlers, versioned annual instance, cumulative buckets/outbox recovery, reward claims, closing/finalization and cleanup.
- **Acceptance:** only physically delivered eligible surplus counts; domestic/network consequences are real; retries do not inflate totals; offline contributions reconcile; event closure leaves permanent records and removes temporary capacity.
- **Testing:** all boundary/crash/claim cases in [Events](docs/EVENTS.md), population-scale ingestion prototype, new/veteran balance and failure to finalize safely during prolonged outages.
- **Out of scope:** automatic public launch, unrelated seasonal events, external backend adoption without a separate decision and energy-source attribution beyond the initial conservative rule.

## P12 — Long-term scale and further systems (research gate)

- **Scope:** assess safe regional consolidation, larger world envelopes and any justified simulation improvements; select one bounded implementation proposal at a time.
- **Dependencies:** measured bottlenecks and long-session data from previous phases; owner approval of editing/accuracy tradeoffs.
- **Deliverables:** prototype benchmark and migration design, updated decisions and a new incremental implementation plan.
- **Acceptance:** consolidation preserves tested boundary capacity/delivery/cost behavior, storage remains bounded and players understand lost/retained editing ability; no cap increase without evidence.
- **Testing:** aggregate-versus-detailed scenario comparison, migration recovery, repeated consolidation and multi-hour load tests.
- **Out of scope:** promising literal infinity, silently forcing eras, implementing elections or AC power flow merely because they are listed as possibilities.

## Recommended next request

Implement **P1 only** after confirming the initial architecture/layout and authorizing any required tooling setup. This creates a reviewable foundation without entangling the first UI decisions with saving or electricity balance. P2 follows once the shell and test workflow are verified.
