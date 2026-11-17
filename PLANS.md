# Development roadmap

Latest task — **17 November 2026 procedural/gameplay foundation: design complete only.** [Design package and proposed slices](docs/PROCEDURAL-GAMEPLAY-FOUNDATION.md) define a seeded temperate one-settlement start, climate/demand, minimal network and deferred planning/events. Owner accepts the illustrated settlement direction; Native remains default. **P2 has not started.** Recommended next implementation request: narrowly scoped P2a after its listed approval gates. Historical milestone records follow.

Previous implementation task: **R3.7 — real settlement integration**, implemented in the isolated Test mapping; engine validation complete: 3,717 assertions, both builds, 128 local checks and three ten-minute soaks passed; matched real desktop/mobile-safe-root captures recorded. Device-emulator/physical-device review remains outstanding. Owner-uploaded Decal 138420314032574 resolves to Image 90608851718773, owned by missawfulname. Separate Original/Settlements profiles reuse six ImageLabels and preserve the original frozen manifest; native forest/fields return in the settlement profile. [R3.7 validation](docs/R37-VALIDATION.md) records current evidence and comparison instructions. Terrain concepts remain direction only; Native remains production default. Stop after R3.7; older stop points below are historical milestones.

Status: P0 complete. P1 implementation authorized by the owner and implemented on 15 November 2026; validation evidence and remaining manual checks are recorded below. **Stop before P2.** Each later phase is independently reviewable; acceptance requires observed evidence, not only written specifications. See [Decisions](docs/DECISIONS.md) for approvals and [Testing](docs/TESTING.md) for shared gates.

GUI redesign follow-up: the three specifications are approved. **R1, R2 and R3 implemented under separate owner requests.** R2 desktop visual review was accepted in the R3 request. R3 adds a bounded modular illustrated map and retains the placeholder-data boundary. See [R3 validation](docs/R3-VALIDATION.md) for current checks and remaining visual/hardware acceptance. R3.1 visual refinement was subsequently authorized and implemented; see [R3.1 validation](docs/R31-VALIDATION.md) and [art strategy](docs/R31-ART-STRATEGY.md). Stop after R3.1: R4/R5/P2, dependencies and monetisation are not authorized.

P1–P4 together produce the first playable. A passing phase does not authorize installation, publishing, committing or pushing outside the user's instructions. At each boundary report actual deliverables, checks run, manual Studio work and remaining limitations.

## P0 — Blueprint (complete)

- **Scope:** inspect existing folder; produce the 19 requested Markdown documents and verify current API/tool recommendations using official sources.
- **Dependencies:** supplied product brief; access to local folder and official documentation.
- **Deliverables:** documentation index, system contracts, decision log, risk register and phased roadmap.
- **Acceptance:** all requested files exist; local links resolve; proposals and confirmed requirements are distinguished; no application code/dependencies or publication changes.
- **Testing:** document completeness/link checks and manual consistency review. Gameplay tests are not applicable yet.
- **Out of scope:** implementation, tool installation, Git initialization, Studio configuration and deployment.

## P1 — Development foundation and responsive GUI shell (implemented)

- **Scope:** choose/pin authorized tooling, establish proposed client/server/shared structure and a responsive GUI shell. Resolve D01, initial D12 choices and D17.
- **Dependencies:** P0; owner implementation request; authorization for any necessary installations; available Studio access.
- **Deliverables:** reviewed Rojo mapping, minimal server/client entrypoints, navigation/header/map placeholders, selected test harness and documented local workflow. Git/GitHub setup only if authorized.
- **Acceptance:** shell runs in Studio; desktop, phone and tablet layouts expose primary controls without clipping; client/server boundaries are clear; exact installed versions and manual setup are documented.
- **Testing:** build/type checks available in the selected toolchain; Studio launch; resize/touch-emulation checks; basic harness verification.
- **Out of scope:** persistent player data, electrical dispatch, money, real construction and all social systems.

Implementation status:

- [x] Preserve existing Rojo mapping/tool pin; establish strict client/shared/server modules.
- [x] Responsive dashboard, reusable components, navigation, illustrative pannable/zoomable map and inspector.
- [x] Loading/notice/error previews, startup error fallback, keyboard navigation and connection cleanup.
- [x] Dependency-free test harness; normal/test Rojo builds and static boundary checks.
- [x] Studio runtime: 98 pure layout/map assertions and 80 engine GUI assertions passed.
- [x] Setup instructions, implementation decisions and evidence/file inventory documented.
- [ ] Owner visual acceptance and actual touch-device checks (safe areas, dragging, rotation, long-session usability).

See [P1 validation](docs/P1-VALIDATION.md) for exact evidence and limitations. This is a presentation shell, not the first playable. No future-phase feature is authorized by completion of P1.

## P2 — Small country and electricity slice

The GUI redesign and the 17 November design task do not authorize or start this phase. Proposed split: **P2a** fixed one-settlement interactive electricity proof; **P2b** bounded seed-generated start and climate-aware demand. See [minimal simulation](docs/MINIMAL-SIMULATION.md) and [foundation milestones](docs/PROCEDURAL-GAMEPLAY-FOUNDATION.md). All values/algorithms require the recorded approval gates.

- **Scope:** one settlement/generator/substation with connected basic network, fixed simulation clock, one generator type, aggregate demand and capacity-constrained transmission. P2b adds starting terrain only; resolve D02–D04 and D66–D69.
- **Dependencies:** P1; pure domain test harness.
- **Deliverables:** deterministic country fixture, NetworkModel/GridSolver, report contract, map selection and supply/congestion/disconnection displays.
- **Acceptance:** all initial demand is served in the revised one-settlement starter; the retained 7 MW regression behind a 4 MW bottleneck delivers only 4 MW; an isolated settlement receives zero; all accounting invariants pass and state remains server-owned.
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

- **Scope:** extend the proposed P2b starting generator to seeded adjacent-sector acquisition, terrain construction costs, legal sites, chunked map rendering and capacity guards. Starting-country generation is no longer wholly deferred to this phase; the split remains proposed.
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

- **Scope:** tariff and efficiency policies, subsidies within one Bank balance, approval/industry effects, one research chain, one national project, research manager and government adviser roles.
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
- **Out of scope:** forced rebirth, shop implementation (separate milestone), profiles/rankings publication and event participation until their phases.

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

## GUI redesign — separate review and migration sequence

Design-only R0 deliverables: [GUI vision](docs/GUI-VISION.md), [layout specification](docs/GUI-LAYOUT-SPEC.md) and [component specification](docs/GUI-COMPONENT-SPEC.md), plus terminology/economy/security decisions. All eight Inspiration references reviewed; code, tests, mappings and assets preserved. No approved price or live purchase path exists.

Implementation slices (R1–R3 authorized; later slices require a separate task):

1. **R1 — implemented:** approved theme tokens, Bank/Credits copy, integer-minor-unit formatter and exact Bank details control; P1 layout/navigation/map preserved. Existing suites retained; currency/GUI coverage added. See [R1 validation](docs/R1-VALIDATION.md) for passing local and engine checks plus remaining hardware/accessibility review.
2. **R2 — implemented:** compact responsive header/operational metrics, grouped/collapsible navigation, phone five-item bar, inspector stages, local text enlargement and explicit map/UI input paths. Selection/camera survive panel and route transitions. Future routes stay previews. See [validation and remaining acceptance](docs/R2-VALIDATION.md).
3. **R3 — implemented:** modular native terrain/asset artwork, separate connections/labels/selection, zoom detail/culling, layer availability/overlay controls and Locate. Existing world coordinates and input paths retained. See [R3 evidence](docs/R3-VALIDATION.md); no procedural expansion or solver implementation.
   **R3.1 — implemented:** settled-layout camera framing, richer native relief/settlement/infrastructure motifs; 1,091 assertions passed and 574 map descendants within the existing 600 ceiling. No external art introduced. Hybrid artwork is a documented recommendation, pending separate approval.
4. **R4:** sample ticker, news/alert components, reduced-motion and collapse behavior; no live feeds.
5. **R5:** nontransactional Energy Shop preview with Credits/Robux states; no platform prompts, grants or purchase remotes.

Each slice runs relevant builds/Script Analysis/regression tests, then desktop/tablet/mobile and input-accessibility checks. See the [detailed migration and validation plan](docs/GUI-LAYOUT-SPEC.md#migration-and-validation-plan). Sample map/news/shop states must remain labelled; new art provenance/upload authorization is separate. Successful mock screens do not satisfy future domain acceptance.

R2 completion evidence: both Rojo builds/static checks passed; final Studio suites passed 324/26/348/16/135 assertions (849 total); final edit-mode Script Analysis reported zero errors/warnings. The ten-minute smoke passed 591 cycles with 411 GUI descendants stable; final orientation/covered-focus fixes were followed by targeted device/regression checks. Desktop, iPhone portrait/landscape, tablet and gamepad emulator paths were inspected. The owner accepted R2 desktop visuals in the subsequent R3 request; actual touch/controller hardware remains outstanding. See the historical R2 report for precise limitations. R3 evidence is recorded separately.

R3 completion evidence: both Rojo builds/static checks passed; Studio suites passed 1,039 assertions including 190 R3 assertions, with zero Script Analysis errors/warnings. The 600.8-second smoke passed 591 cycles with 803 shell descendants stable (448 map descendants). A subsequent resize-focus correction passed full regressions and phone orientation checks. Native illustration remains subject to owner visual review and real-device acceptance; see the R3 report for measurements and limitations.

### Proposed live Energy Shop milestone (unscheduled, not authorized)

Prerequisites: completed P3 ledger/persistence and explicit owner authorization; approved Credits price model, operating reserve, active-time checkpoint protocol and ownership-outage policy; D30/D31 already confirm ordinary-menu behavior and dormant temporary remainder. Requires current Roblox API verification and separately authorized pass setup. No simulation-speed products or extra income stacking.

Deliverables: server-authoritative atomic Credits purchase, active-time persistence, verified permanent entitlement and truthful price/status/confirmation UI. Acceptance: identical 2× eligible sales factor, unchanged expenses/energy, no double grants/debits, no offline/paused duration consumption, recoverable ambiguous transactions and explicit financial advantage disclosure. Test physical accounting isolation, save failures, multi-session races, expiry, regional/personalised prices and real platform ownership in an isolated environment. P6a adds export eligibility tests; P8 verifies rebirth preservation and resolves the held legacy income track; P9 reviews Bank leaderboard treatment. No phase is silently renumbered or expanded.

## R3.2 — modular illustrated art proof (local production complete; join revision needed)

After planning completion, the owner authorized local production against the six-motif atlas specification. Produced the 1024×1024 RGBA atlas, six exports, original generated raster sources, editable six-layer OpenRaster, projected-size contact sheet, manifest/provenance and inspection diagnostics. All 70 local automated artwork checks pass. The native-coast proxy reveals a visible grass seam and abrupt shoreline transitions: coast join acceptance remains unresolved. See [local validation and limitations](docs/R32-LOCAL-ART-VALIDATION.md). No upload, Roblox IDs or renderer implementation; R3.1 remains the running baseline.

## Historical visual follow-up recommendations

**R3.5 — isolated visual cohesion complete:** 22px badges inside unchanged 44px targets, contextual names and immediate Native/missing-art restoration are implemented only in the Test decorator. Map count is bounded at 595. Final coverage: 2,306 engine assertions, 101 local checks, both builds, zero Script Analysis errors/warnings; retained real/native ten-minute soaks each passed 591 cycles. Desktop/tablet/mobile comparisons and limitations are in [R3.5 validation](docs/R35-VALIDATION.md). Owner visual acceptance and real-device testing remain pending. Review the candidate, then separately authorize a small local art study from [the terrain and settlement proposal](docs/R35-VISUAL-COHESION.md). No new artwork or progression system implemented; stop after R3.5.

**R3.4 — Stage 2 isolated proof complete:** real adapter uses verified Image `86222383311104` from uploaded Decal `105986918888502`, owned by `missawfulname` / `149564436`. Both builds and 83+14 local checks pass; 2,089 engine assertions pass. Real-texture soak passed 600.8 seconds / 591 cycles / 935 stable descendants; native soak passed 600.9 seconds / 591 cycles / 929 descendants. Script Analysis: zero errors/warnings. Actual desktop, phone and tablet emulator comparisons are recorded. Recommend visual refinement and physical-device testing before adoption; owner visual acceptance remains pending. Production remains Native and was not synced; no permissions, uploads or gameplay changes. See [R3.4 validation](docs/R34-VALIDATION.md). Stop after Stage 2.

**R3.3 — isolated mock renderer implemented:** owner accepted all six motifs for proof use; native remains default. Frozen manifest, six-sprite pool, injected readiness/failure lifecycle, native replacement ownership and test-only attribute comparison are implemented. Both builds and local asset checks pass; Studio suites pass 1,830 assertions including 739 synthetic hybrid checks. Proof count is 580 map / 935 shell. See [R3.3 validation](docs/R33-VALIDATION.md) for final soak/analysis evidence and benchmark limits. Real texture testing is blocked at the missing approved asset ID; request separate checksum/destination-specific upload approval before real-adapter testing. Historical R3.2 notes follow.

R3.3 completion evidence: 83 read-only asset/mapping checks passed; owner reports no Script Analysis errors with the current-script filter disabled. Existing native soak passed 600.9 seconds / 591 cycles with 929 shell descendants stable. Synthetic hybrid draw p95 remained below 1ms in all measured passes; no texture/GPU/memory result is claimed. Stop at this mock boundary.

R3.2b local raster correction delivered in [atlas revision 3](assets/r32-proof-v3/README.md): inspected curved grass seam removed, central mismatch zero, source inland and both endpoint overlap bands alpha 255. 70 atlas and 161 coast assertions pass. Natural cliff endpoints remain abrupt and one southern filtered sample is alpha 254; owner visual review is still required. See [R3.2b validation](docs/R32B-COAST-VALIDATION.md). No runtime integration or upload; prior revision notes below remain historical.

R3.2a local refinement delivered: five non-coast motifs accepted by the owner for proof use and preserved byte-for-byte; only coast art revision changes in atlas revision 2. The central colour seam diagnostic improves 37.93%. Strict opaque interior and both proposed endpoint overlap gates remain unmet; coast visual acceptance is pending. See [R3.2a validation](docs/R32A-COAST-VALIDATION.md) and [before/after](assets/r32-proof-v2/coast-before-after.png). Review this candidate and resolve the precise paint/alpha joins before any integration approval.

Review the [latest contact sheet](assets/r32-proof-v3/contact-sheet.png) and [high-resolution coast comparison](assets/r32-proof-v3/coast-high-resolution-comparison.png). Review the remaining endpoint appearance before integration acceptance. Upload approval must identify the reviewed artwork/checksum and intended Roblox owner/experience; runtime integration is separate. The native baseline remains available. R4/R5/P2 have not started; P2 still requires D02–D04 resolution.
