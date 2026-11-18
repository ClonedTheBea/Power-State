# Procedural world and gameplay foundation

**P3a follow-up:** D94–D99 are owner-approved (D100); D104 authorizes the completed single-key real Studio/Test proof. [P3a validation](P3A-VALIDATION.md) records actual create/checkpoint/reconnect/release evidence and remaining service limits. Real start requires the approved account, universe and key; normal bootstrap remains unchanged. Earlier design-only wording below is historical.

**Current follow-up:** P2b and P2b.1 completed available validation. [P3a persistent-country design](P3A-DECISION-PROPOSAL.md) is the documentation-only persistence subset of P3; implementation and economic/construction work require separate approval. Earlier failed-gate/unstarted statuses below are historical.

17 November 2026 P2b Stage 1: [specific implementation recommendations](P2B-DECISION-PROPOSAL.md) now consolidate the earlier options and identify conflicts with accepted P2a. **Subsequently approved for Stage 2 (D83), but pre-integration climate validation failed; [gate and proposed correction](P2B-VALIDATION.md) await review.** Historical candidate values below are not silently promoted or replaced.

17 November 2026. **Documentation complete; no gameplay implementation authorized or performed.** Owner accepts R3.7 technical validation and the illustrated settlement direction for continued development. Hybrid remains an isolated proof; Native remains production default. Existing demo coordinates, artwork and source remain unchanged.

## Design package and authority

| Deliverable | Specification |
| --- | --- |
| Procedural architecture, expansion and bounded rendering | [World and expansion](WORLD-AND-EXPANSION.md) |
| Reproducible temperate start, fair opportunities, seed/delta saves | [Starting country](STARTING-COUNTRY.md) |
| Smallest network, service/reliability, sales/cost accounting | [Minimal simulation](MINIMAL-SIMULATION.md), [existing solver](ELECTRICITY-SIMULATION.md) |
| Climate fields, weather/calendar and explicit aggregate demand | [Climate and demand](CLIMATE-AND-DEMAND.md) |
| Development applications and staff boundaries | [Planning applications](PLANNING-APPLICATIONS.md) |
| Forecastable actual-load events | [National Demand Events](NATIONAL-DEMAND-EVENTS.md) |
| Approval register and conflict resolutions | [Decisions D65–D70](DECISIONS.md) |

Owner-confirmed: one fully connected small settlement/generator/substation; curated name; reproducible unique-country direction; temperate start; fair expansion; gradual climate; population/time/season/temperature/activity/efficiency/event demand; server authority; future planning/events. The exact seed algorithm, numeric limits, coefficients, calendar, starter ratings and milestone split are proposals. No proposal in this package is implementation authority.

## Recommended implementation sequence — all require separate requests

| Slice | Small bounded deliverable | Dependencies and exit evidence | Explicit exclusions |
| --- | --- | --- | --- |
| P2a — interactive electricity proof | One fixed session-only starter, one On/Off intent, server solver/report, truthful shortage/recovery display | Approve D02/D03 and narrow starter/command contract; unit conservation, replay, security, UI regressions and bounded profiling | Persistence, spendable earnings, generated countries, events, construction |
| P2b — seeded start and climate-aware demand | Pure versioned generator + starter validator; fixed-size seed-generated start in isolated Test; hourly demand and temperature | Approve D66/D67; golden vectors, fair-seed sweep, border parity, component/energy fixtures and Native view-model adapter | Sector purchases, full biome art library, renewable/fuel logistics, population growth |
| P3 — saved economic/construction loop | Save pinned seed/deltas, delivered-energy billing/cost reservations, one valid construction/connection opportunity and bounded development | Existing lease/ledger gates plus old-generator replay, load failures, initialization race, affordability/recovery and real Test persistence | Planning permission, live event catalogue, commerce |
| P4 — first-playable review | Tutorial and recovery for the new one-settlement start, save/reload and device usability | P3 complete; player can inspect, operate, expand, deliver, earn and reload | Public release or implicit Hybrid adoption |
| P5a — sector acquisition | Bounded adjacent quotes/ownership, multi-chunk interest/culling and terrain costs | Persistent generator versions; cap/route/boundary tests and measured client pool redesign | Infinite territory or region consolidation |
| Later demand-event pilot | One deterministic forecasted additive pulse | P2b demand + P3 durability/accounting; event replay and energy integration | Global events, R4 ticker, response technologies not yet built |
| P7 extension — planning applications | One residential/commercial application with explicit funding/commissioning | Construction, demand forecasts, persistence, policy/automation bounds | Full politics, unrestricted staff automation, all industries at once |

P2a is the **smallest practical interactive first-playable implementation milestone**, explicitly a simulation proof rather than the project's full saved first-playable. P1–P4 remain the complete loop. Do not attempt seed generation, all climates, finance, Government and event systems in one P2 task. P2b moves only starting-region generation earlier than the old P5a proposal; purchasable expansion stays P5a. A country reset or new seed is not available to players during session-only tests.

## Conflicts resolved and open decisions

The old three-settlement/7 MW opening becomes a solver regression fixture, not the new-player specification. Existing five-asset rendered demo is untouched. The formerly suggested 600 visible objects plus 200 labels is superseded as a procedural client planning target by a total **600 map-descendant envelope**, counting hidden fallback/labels; increasing it needs a measured, approved redesign. The current 595-count proof cannot be duplicated per sector. Unique names/geography globally are not guaranteed by finite random pools; country identity is distinct, and collision policy needs clarification if exclusivity is intended.

Before P2a approve solver/clock defaults, the On/Off command and fixed starter values. Before P2b approve deterministic integer hash/kernel/versioning, temporal demand tables, first-day envelope and fairness metrics. Before P3 approve Bank reserve, prices, economic recovery and generator-retention/migration strategy. Before later systems approve calendar/event cadence, planning capacity reservations and political consequences. These are concrete review gates, not requests to authorize more work now.

## Risk register

| Risk | Failure mode | Mitigation and acceptance evidence | Gate |
| --- | --- | --- | --- |
| Save compatibility | New generator moves built sites or resurrects deleted assets | Pin versions; retain old generator; tombstones; reference/terrain migration fixtures; fail closed on unknown version | P2b/P3 |
| Seed initialization/rebirth | Retry produces a different world or duplicate starter grant | Prepared deterministic creation operation and fenced atomic save; ambiguous-response/reset tests | P3/P8 |
| Determinism | Discovery order, negative coordinates or engine noise changes terrain | Integer hash golden vectors, canonical ordering/quantization, shared border tests and cross-runtime replay | P2b |
| Unfair seed | Starter island cannot expand affordably | Reserved land/routes, finite candidate search, safe template and opportunity-cost distribution sweep | P2b/P3 |
| Climate discontinuity | Hard chunk seam or implausible biome alternation | Shared continuous fields/halos, bounded gradients, smooth starting transition and map inspection | P2b/P5a |
| Save growth | Deltas/resources/events exceed profile budgets | Proposed 16-sector/256-node/512-line/64-demand caps; encoded-size preflight, no silent truncation | P3/P5a |
| Client rendering | Multiplying 595-descendant scene by sector exhausts budget | Shared bounded pool, LOD/clustering, eviction; no per-pan allocations; physical-device measurement | P2b/P5a |
| Server performance | Climate/noise/routing/event work spikes | Cache static fields, capped demand groups/events, bounded solver and generation jobs; reject partial step | P2/P5a |
| Economy balance | Tiny demand/fast clock creates insolvency or explosive profit | Explicit MW→MWh units, carried money remainders, reserve and fixed-cost tests, demand/price sweeps at income factor 1 | P3 |
| Double counting | Weather/season/events/industry/efficiency apply twice | Component ledger; typed event channel; commissioning transition; same-temperature and overlap fixtures | P2b/later events |
| Forecast exploitation | Reconnect rerolls a bad event or forecast grants money | Pinned realization/stream, bounded persisted event state, forecast separate from billing | Event pilot |
| Planning overcommitment | Multiple approvals promise the same feeder capacity | Permission distinct from funded reservations; revalidate at commissioning and idempotent activation | P7 extension |
| Visual authority leakage | Painted houses imply population/connectivity | Server data → cosmetic descriptors → renderer → overlays, stable terminal IDs and native fallback | Every slice |
| Scope expansion | Design package mistaken for P2/government approval | Status on every spec, explicit slice request and acceptance gates; Native remains default | Every slice |

## Documentation validation

See [design validation](PROCEDURAL-FOUNDATION-VALIDATION.md) for checks actually performed. No generator, climate model, demand calculation, solver, save adapter, planning application or event code was implemented or tested in Studio under this task. Prior R3.7 results remain historical evidence for the renderer only. No artwork, source, production settings, dependencies, uploads, permissions, commits or deployment changes.
