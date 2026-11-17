# Climate and aggregate electricity demand

**P2b update — 17 November 2026:** P2b v1 implementation uses the owner-approved [contract](P2B-DECISION-PROPOSAL.md), including D86 outer radius 4608 / inner radius 2048, unchanged gradient thresholds, exact midpoint demand curves and aggregate kW rounding. The initial climate is protected; no seasons, random weather or events are implemented. [Current validation](P2B-VALIDATION.md).

17 November 2026 P2b Stage 1: [specific implementation recommendations](P2B-DECISION-PROPOSAL.md) now consolidate the earlier options and identify conflicts with accepted P2a. **Historical gate: the original radius failed pre-integration validation. D86 subsequently approved 4608 units; the amended implementation and available [validation](P2B-VALIDATION.md) now pass.** Historical candidate values below are not silently promoted or replaced.

17 November 2026. Owner confirms the required influences; formulas, coefficients and calendar below are **proposals D67/D68**, not measured weather realism or balanced gameplay. Use [Simulation](ELECTRICITY-SIMULATION.md) units and [Starting country](STARTING-COUNTRY.md) guarantees.

## Continuous environment before biome labels

Generate continuous fields in absolute world coordinates, not one biome roll per chunk. Proposed inputs: mean temperature (°C), annual rainfall (mm/year), elevation (map metres), coastal exposure [0,1], wind speed (m/s) and direction, solar resource [0,1], hydro catchment potential [0,1], and versioned geological/fuel deposit descriptors. Resource potential constrains later technologies; it produces no electricity by itself. Fuel deposits use explicit type, finite recoverable fuel units and extraction limits, not an infinite terrain bonus.

Proposed generator uses a coarse global lattice with integer-hashed samples and a documented smooth interpolation kernel. Adjacent sectors sample the same shared border coordinates plus a fixed halo; quantize output after interpolation. Low-frequency temperature/rainfall fields and bounded elevation/coast modifiers yield gradual climate gradients. Starting-template correction blends to zero with a smooth radial weight over a proposed 2–4-sector transition ring; reserve a continuous coast/land mask before computing exposure. The exact kernel, lattice scale, field ranges and maximum gradients require golden-vector tests and approval. Chunk boundaries must never be field discontinuities.

Biome weights derive from temperature, rainfall, elevation and exposure with overlapping bands, then normalize. Possible labels include temperate, Arctic, tundra, boreal, desert, tropical, mountain and maritime. Mountain/maritime may overlay thermal classes. No obligation to place every climate, no fixed distance to Arctic/tropical, and no alternating biome checkerboard. Art chooses compatible blended families from these weights; a renderer's missing sprite cannot alter temperature or fuel deposits.

Define deterministic rivers through a separately versioned regional drainage graph with canonical shared-edge crossings, fixed upstream summaries and bounded evaluation. Do not recursively generate an entire upstream world when opening a chunk. P2 requires neither river hydrology nor harvestable geological resources; initial fields may remain static descriptors until their dependent systems are authorized.

## Calendar, weather and replay

Proposed simulated calendar: 365 days/year, 24 hours/day, four labelled seasons with smooth cyclic interpolation, common country-local solar hour. Retain D03's proposed one wall second per simulated minute, fixed steps, bounded lag handling and no offline catch-up. A calendar mapping version and integer step determine season/hour; opening a menu has no effect. UTC global events remain a separate clock.

Ambient temperature = spatial mean + smooth seasonal anomaly + diurnal anomaly + bounded correlated weather anomaly. Maritime exposure damps amplitudes; elevation effects are already included in the mean and must not be applied twice. Correlated weather uses time-indexed regional cells and interpolation, with separate streams for forecast error and actual weather. Reload/sector discovery cannot reroll conditions. Never draw independent random weather per render frame or demand query.

Initial climate-aware demand can consume deterministic temperature samples without implementing renewable dispatch, storms or resource extraction. Later weather effects on generation use the same authoritative weather snapshot as demand. Future event cold snaps/heatwaves enter the weather anomaly exactly once, not an additional blanket demand multiplier.

## Aggregate demand equation

For settlement s at start of completed step k, desired power (MW) is:

`D = clamp(R + H + C + B + I + E, 0, approvedSettlementDemandCapMW)`

- `R = population × residentialMWPerPerson × residentialCurve(hour) × residentialEfficiency`.
- `H = population × heatShare × heatMWPerPersonPerDegree × max(0, heatSetpointC − ambientC) × heatingCurve(hour) × heatingEfficiency`.
- `C = population × coolShare × coolMWPerPersonPerDegree × max(0, ambientC − coolSetpointC) × coolingCurve(hour) × coolingEfficiency`.
- `B = commercialReferenceMW × commercialActivity × commercialCurve(hour) × commercialEfficiency`.
- `I = sum(commissionedIndustryRatedMW × loadFraction(schedule) × industryEfficiency)` over a capped aggregate list.
- `E` is the sum of active, eligible additive event demand in MW from [National Demand Events](NATIONAL-DEMAND-EVENTS.md). Weather-type events change ambientC instead.

All population/activity/industry/upgrades/events are server-owned. Each multiplier has versioned finite bounds; shares lie in [0,1], efficiency demand factors in a proposed [0.5,1], and heatSetpoint < coolSetpoint. An upgrade chooses a canonical effective factor for its component; never apply it a second time to national totals. Base residential intensity excludes HVAC and separately modelled commercial/industry loads. Season enters through actual temperature and explicitly seasonal schedules; no permanent “Arctic ×2” or repeated season × temperature penalty. Tariff elasticity and policies, when authorized later, apply once to named eligible components and must not silently cancel essential temperature loads.

Curves contain 24 bounded hourly samples, interpolate linearly with cyclic hour 23→0, and are normalized to mean 1 over a day for reference-energy curves. Industry schedules are load fractions, not normalized curves, so a closed plant stays closed. Example residential shape: lower overnight, morning/evening peaks; commercial shape: daytime peak; coefficients/table values require calibration. Heating/cooling curves describe occupancy only, not a second temperature anomaly. Cap breaches produce diagnostics and a visible design-limit state, not silent loss of simulated load; generation/development must reject changes that exceed model budgets before committing.

P2a uses fixed demand. Proposed P2b starter coefficients: 1,000 people, residential 0.0006 MW/person, commercial 0.15 MW, industrial/events zero; 18°C heat and 24°C cool setpoints; heat coefficient 0.00008 MW/person/°C, cool 0.00006, shares 1 and efficiency factors 1 for unit tests. Proposed starter curve caps are 1.4 for residential/heating/cooling and 1.3 for commercial; at the first-day 12°C minimum the upper bound is 0.84 + 0.672 + 0.195 = 1.707 MW, below the 2 MW starter demand envelope. These are illustrative coefficients, not empirical household statistics. At unit curves: 20°C → 0.75 MW; 10°C → 1.39 MW; 30°C → 1.11 MW. At 0.8 residential/heating efficiency and 10°C → 1.142 MW (commercial unchanged). Keep fractional energy, not per-person rounding.

For each fixed step sample deterministic inputs at its midpoint, treat resulting MW as constant for that step and integrate `requestedMWh = D × stepHours`. Split at known event/schedule boundaries when required; do not bill an entire step's peak as an hour. No asynchronous settlement result can mix old population with new upgrade versions. Growth applies after completed-step accounting; new demand is visible next step.

## Verification and disclosure

Test zero population, independent commerce/industry, day wrap, seasonal wrap, heat/cool deadband, nonfinite inputs, efficiency stacking and aggregate caps. Compare cold/hot scenarios to the three worked values; equal temperatures/schedules/population must yield equal demand regardless of biome label/art. Sum components and energy before computing national displays. Test replay after disconnect and event/weather overlap, border continuity including negative coordinates, and upper-bound demand for every starter weather/curve combination. Fixed coefficients/curves need owner balance approval and future telemetry; no climate/demand code is added here.
