# P2b Stage 1 — proposed implementation contract

**Approved radius amendment:** outer temperate-transition radius is now **4608 world units (4.5 sectors)**; inner radius remains 2048. The owner explicitly retained every threshold and other formula. Current v1 text below reflects that amendment; historical failed-radius evidence remains in the validation report.

**Stage 2 update:** D83 authorizes implementation; D86 approves the sole radius amendment following D84/D85. Current formulas below include that amendment. Stage 1 proposal/stop wording is historical; no later phase is authorized.

17 November 2026. **Proposal for owner approval; no P2b implementation authorized or performed.** The owner accepts P2a as the gameplay foundation. This document resolves the options into one reviewable recommendation, not permanent gameplay rules. Source gates: [foundation plan](PROCEDURAL-GAMEPLAY-FOUNDATION.md), [starting country](STARTING-COUNTRY.md), [climate/demand](CLIMATE-AND-DEMAND.md), [world](WORLD-AND-EXPANSION.md), [decisions D66–D69 and D71–D75](DECISIONS.md), and [P2a evidence](P2A-VALIDATION.md).

## Decision gate and recommended package

The foundation plan says: “Before P2b approve deterministic integer hash/kernel/versioning, temporal demand tables, first-day envelope and fairness metrics.” The current request also requires separate Stage 2 approval. **Stop after this proposal.** Approving it would authorize the bounded Test implementation described here, not later systems or production rollout.

| Choice | Recommendation | Reason / tradeoff |
| --- | --- | --- |
| Seed and versions | Server-issued 16-byte seed, independently issued country ID; explicit generation, climate, demand, starter and name-pool versions | Reproducible geography without claiming globally exclusive names or geography |
| Integer terrain | Versioned 32-bit FNV-1a hash, exact limb arithmetic, absolute-coordinate two-scale value fields and Q12 smooth interpolation | Small dependency-free implementation with inspectable golden vectors; not a cryptographic algorithm |
| Climate | Shared coarse temperature/rainfall fields, bounded elevation correction, overlapping biome weights; temperate overlay fades between two and 4.5 sectors | No chunk-specific biome rolls or hard climate seams |
| Starting fairness | Fixed electrical equipment/population, reserved pads/routes, two exits; bounded eight-candidate search and deterministic safe fallback | Variation in geography without random early electrical disadvantage |
| Population/demand | Exactly 1,000 residents, 5 MW source, 10 MW gates; 3 MW non-HVAC reference demand; first-day demand ceiling 4.10 MW | Retains the accepted P2a scale; coefficients remain test balance, not real household statistics |
| Clock | Existing one-second / one-simulated-minute step; repeating deterministic 24-hour temperature and load curves | Demonstrates time/temperature demand without adding weather, seasons or event systems |
| Coordinates | One 1024-square active starting sector, 1/16-unit positions; separate generated view model | Preserves the authored demo and fixed P2a fixture without rescaling their data |
| Limits | One active sector, nine internal validation descriptors, three live nodes/two lines, eight countries, 600 map descendants | Does not enable the proposed larger P5a world or graph budgets |

## Seed, identity and deterministic arithmetic

Propose generating the seed once on server country creation using a fresh `HttpService:GenerateGUID(false)`, normalized to 32 lowercase hexadecimal digits and decoded as 16 bytes. Issue a separate country ID. The 128-bit container is not a promise of 128 independent random bits or collision-free geography. Never reduce the complete seed to a single 32-bit initial state: hash all seed bytes for every keyed sample. No username/UserId-derived seed, client seed remote or player reroll control. Test fixtures inject fixed seeds through a server test harness only.

Use a generation descriptor with `generationVersion=1`, `climateVersion=1`, `demandVersion=1`, `startTemplateVersion=1`, `namePoolVersion=1`, the seed, selected candidate index and fallback flag. Art revision is independent. Unknown/malformed versions or seeds fail closed. A future generator change gets a new version; retain v1 fixtures. P2b is session-only: recreation in a later session may create a new seed; durable identity and prepared-seed initialization retries remain P3 work, not an implied save guarantee.

Proposed keyed hash input, in order: ASCII `PS2B`, zero byte, 16 seed bytes, unsigned little-endian u32 relevant algorithm version, one-byte ASCII stream-tag length, stream tag, signed two's-complement little-endian i32 lattice X and Y, u32 candidate/slot index. Use explicit tags for elevation-coarse, elevation-fine, temperature, rainfall, start-layout and town-name. Global fields use candidate index zero; candidate changes only bounded start layout. No JSON/table-order hashing or shared mutable random stream. Unsupported tags/lengths are rejected. Range mapping uses the high 16 hash bits with an explicit integer scale; small mapping bias is acceptable for this noncompetitive cosmetic proof and is not a uniqueness guarantee.

FNV-1a-32: initial 2166136261; per byte XOR then multiply by 16777619 modulo 2^32. Implement multiplication with 16-bit limbs, not a potentially inexact full 32×32 double multiplication. Primitive expected vectors: empty bytes `811c9dc5`, ASCII `a` → `e40c292c`, ASCII `foobar` → `bf9cf968`. These were independently calculated for this proposal, not run in Luau. Stage 2 must add canonical-message and complete descriptor vectors, verified by an independent arithmetic reference before accepting the engine implementation.

Positions are integer sixteenths. Field interpolation uses Q=4096: `u=floor(localOffset*Q/latticeSpacing)`, `smooth(u)=floor((u*u*(3*Q-2*u)+Q*Q/2)/(Q*Q))`; interpolate X then Y with `lerp(a,b,w)=a+floor(((b-a)*w+Q/2)/Q)`. This fixes round-to-nearest with ties toward positive infinity, including negative values. Smooth endpoints are 0, 2048, 4096 at inputs 0, 2048, 4096. All intermediate ranges must be asserted below the exact integer envelope; no engine noise or platform random sequence supplies authoritative fields. P2b does not add a dependency.

## Terrain, climate and biome treatment

One authoritative sector contains a 17×17 grid at 64-world-unit spacing, including shared edges. At a shared coordinate, neighboring sectors query the identical absolute field; local row indices never seed a sample. A one-sample halo is evaluated for slope checks but need not be stored twice.

Proposed elevation in integer map metres: `60 + coarse[-160,160] + fine[-40,40]`, with lattice spacings 512 and 128 units; sea level zero. This gives a bounded -140..260 m base field. Reserve starter pads/routes at 40 m using a smooth 64-unit transition outside their protected interiors. Final land is elevation above zero. Coastline derives from this same field; no separate per-chunk island roll. Rivers/drainage, fuel deposits, wind and renewable resources remain absent/unavailable, not fabricated gameplay data.

Temperature mean samples use an 8192-unit lattice, -20..30°C in centidegrees; rainfall uses 4096 units and 200..2400 mm/year. Apply one elevation lapse correction of -0.006°C per positive elevation metre, rounded once to centidegrees. Elevation is not applied again during demand calculation. No coastal-exposure model or maritime weather amplitude is needed in this first implementation.

Blend final mean temperature to 17°C and rainfall to 1000 mm/year around starting-sector centre (512,512). Weight is one inside radius 2048, zero outside radius 4608, with the same smooth kernel applied to normalized squared radius in between. Clamp before multiplying to keep integer intermediates bounded. This protects the whole starter and both early exits; distant fields are not forcibly temperate. It narrows the earlier 2–4-sector transition proposal (outer radius subsequently amended to 4.5 sectors) to an explicit contract. Terrain protection is only pads/routes; it does not flatten the whole temperate area.

Propose temperature membership ramps: cold=1 at/below 0°C and 0 at/above 10°C; warm=0 at/below 20°C and 1 at/above 30°C; temperate=1-cold-warm. Dry membership falls linearly from 1 at 300 to 0 at 700 mm/year; wet rises from 0 at 1400 to 1 at 2000. Combine thermal and moisture memberships by multiplication into normalized cosmetic weights, rather than abrupt biome labels; mountain relief is a separate elevation decoration weight. The field values, not the chosen label, drive demand. At most two dominant cosmetic families are blended in Native presentation, with deterministic tie order. P2b need not render every named global biome or add a sprite library.

Boundary acceptance: exact shared-sample parity, including negative coordinates; neighboring 64-unit climate samples differ by at most 2°C and 150 mm/year; mask transitions have no one-cell discontinuity beyond quantization. These are proposed validation thresholds, not measured results. Fail the implementation gate if the algorithm cannot meet them; do not silently clamp away a failed fairness or seam test.

## Starting region and fairness

Retain 1,000 population, 5 MW generic generator, 10 MW substation, two 10 MW links and 10 MW demand-bus gate. All start healthy and connected. Bank remains the existing explicitly labelled placeholder. Population does not vary across seeds or grow. The existing eight-name candidate pool is proposed for this proof: Alderwick, Brackenford, Elmstead, Hazelbrook, Merefield, Oakcombe, Rowanbridge, Willowmere. This task requests approval of that pool; existing editorial-review status is not silently removed. Names can repeat; store name ID/version in the session descriptor.

Use a separate generated layout: generator (320,512), substation (512,512), settlement (704,512), optionally quarter-turned around (512,512) using the layout stream. Each link is 192 units. Reserve 96×96-unit asset pads, two 96×96 prospective development pads at (320,704)/(704,704), and 128-unit-wide routes joining them to the substation. Reserve opposite cardinal exit corridors through (0,512)/(1024,512), continuing 128 units into adjacent sectors; rotate these with the layout. All reservation queries use absolute coordinates and the selected country-level start descriptor, including queries from neighboring chunks. Never decide a neighbor's mask based on which chunk was generated first.

IDs use country/session namespace + sector + semantic slot (generator/substation/settlement), not candidate array order or town name. Rotation changes only this generated profile's anchors; P2a's station/junction/capital IDs and positions and all demo assets remain unchanged. Art tier changes cannot move the new profile's terminals.

Validate candidates 0..7 in deterministic order, then candidate 8 safe layout. Candidate layout rotation is keyed independently; failed candidates cannot reseed the global terrain/climate fields. Safe layout applies the same bounded terrain reservations and is still validated; if invalid, report generation unavailable rather than loop or issue a broken country. Return the selected descriptor before exposing any adjacent generation. The safe layout may reduce diversity but cannot bypass checks.

Required fairness vector for every accepted start:

- All three asset pads and both future pads are dry, connected and have <=2% sampled slope; protected corridor interiors are dry and require no specialist crossing.
- Both exit corridors connect to distinct cardinal neighbors. No purchases or legal construction actions are enabled by showing these opportunities.
- Equal equipment and population; generator On serves every minute of the first day with >=0.90 MW generation headroom, and every line/node remains within its rating.
- First-day requested energy is identical across seeds (same protected climate, population and curves). No random faults or seed-dependent electrical bonuses.
- Route lengths to pads/exits equal the unrotated reference, within 1/16-unit rounding. A geometric opportunity score based on those lengths plus dry/slope checks must stay within ±10% of reference; reject specialist-water/mountain crossings outright. This replaces an untestable currency-cost claim with a transparent geometric proxy for P2b. Affordability and ten-hour operating reserve remain explicitly unproven until P3 prices exist.

Stage 2 sweeps at least 10,000 fixed seeds plus adversarial seeds, reports every fairness component and fallback rate, and compares independently ordered chunk queries. Target fallback <=1%; a higher rate requires review even if starts are playable. Require >=99% distinct nonreserved starting-terrain fingerprints in that corpus, and report rotations/name frequencies; this is a diversity regression threshold, not worldwide uniqueness proof. If hash/noise quality produces visible repeated patterns, revise the proposed generation version before acceptance rather than conceal the repetition with art.

## Time, temperature and demand coefficients

Retain the P2a fixed-step clock, catch-up cap, energy accounting and 1440-minute reliability ring. New generated sessions start at local noon. Step inputs use the midpoint of the upcoming simulated minute; interpolate cyclic hour 23→0. A generator command re-solves using the current sampled demand and does not advance time or energy. Compute demand and solver result before committing either, so a failed solve cannot partially advance climate, history or energy.

Use a repeating 24-hour temperature triangle: minimum 12°C at 04:00, maximum 22°C at 16:00, linear interpolation between those endpoints and across midnight. At other world locations, add the same -5..+5°C anomaly to their spatial mean. No stochastic weather, seasonal simulation, annual calendar or event anomalies in P2b; those remain future versioned inputs. The protected start thus stays 12–22°C for the entire proof, not just its first day. This is an intentional novice test simplification, not a permanent climate rule.

Proposed component demand, aggregated before rounding:

- Residential: population × **0.0024 MW/person** × residential hourly factor.
- Commercial: **0.60 MW** × commercial hourly factor, independent of population in unit fixtures.
- Heating: population × **0.00008 MW/person/°C** × max(0,18-temperature).
- Cooling: population × **0.00006 MW/person/°C** × max(0,temperature-24).
- HVAC occupancy factors, electrification shares and efficiencies remain 1; industry/events zero. No policy or upgrade features are implemented.

These replace the earlier proposed 0.0006/.15 reference values for P2b only, while keeping the earlier HVAC coefficients. At unit curves: 20°C → 3.00 MW; 10°C → 3.64 MW; 30°C → 3.36 MW. No biome multiplier or extra temperature/season multiplier. Heat/cool setpoints retain a deadband.

Proposed hourly factors in thousandths, hours 00..23:

```
Residential: 800 800 800 800 800 800 1000 1100 1200 1000 1000 1000 1000 1000 1000 1000 1100 1200 1200 1200 1200 1200 1000 800
Commercial:  800 800 800 800 800 800  900 1000 1200 1200 1200 1200 1200 1200 1200 1200 1200 1200 1100 1000  900  800  750 750
```

Each table sums to 24000 (mean 1), maximum 1.2. The conservative protected-start bound is `2.4*1.2 + .6*1.2 + 1000*.00008*(18-12) = 4.08 MW`, leaving at least 0.92 MW of 5 MW capacity. Approve a **4.10 MW starting envelope** to allow quantization tolerance; reject rather than silently trim an invalid start. Reference demand is 3 MW at unit curves and comfortable temperature; it is not a promise that the opening noon sample is exactly 3 MW.

Sum components at fixed precision, quantize total desired power once to nearest 0.001 MW with ties upward, and feed the existing integer-kW solver. Maximum instantaneous rounding error is 0.0005 MW. Component diagnostics expose pre-round total and quantization difference; authoritative MWh use the quantized requested/delivered MW and 1/60 hour. No per-person or separate per-component rounding. A 10 MW settlement model cap is a fail-closed input guard, not a silent load clamp. No spendable money, income estimate, fuel cost or earnings is added.

## Coordinates, rendering and performance contract

Sector size 1024 units, 10 abstract map metres/unit; local coordinates [0,1024), floor division for negative coordinates. World positions use integer sixteenths. Proposed address envelope is sector indices -1024..1023 on each axis, not permission to allocate that territory. East/south edge belongs to the next chunk. Bounds, finite integers, supported versions and seed length are checked before generation. Adjacent edge samples may evaluate the upper boundary without allocating an out-of-range sector.

Only sector (0,0) is live/rendered. Internally at most its 3×3 validation neighborhood is retained; outer fields are pure addressable samples, not explored territory. No interest/sector-purchase remote, streaming queue or player seed selector. Preserve independent demo/P2a sources and a generated Test view-model source. The generated map uses its own 1024-square bounds; do not stretch it into the authored 1200×800 coordinates or silently inherit hardcoded camera bounds.

Proposed module boundaries: server WorldGenerator + StarterValidator, pure ClimateModel and DemandModel, small SimulationService composition change; client cosmetic descriptor adapter feeding bounded Native terrain and existing native electrical overlays. No renderer derives demand/legality from colors or artwork. Reuse/replace terrain slots, not duplicate the current 541-descendant scene. Plan at most 320 terrain/decorative descendants and 200 infrastructure/control/label descendants, leaving 80 spare under the hard 600 map limit. Preserve 44px targets, culling, zoom bounds, camera/selection and old Hybrid test profiles. If measured composition cannot fit, stop for review rather than raise the budget or disable accessibility.

Proposed engineering gates, to measure after implementation:

- At most one generation job per country, eight total, round-robin; no unbounded queue. Yield after 128 field samples or 2 ms, whichever first. Time affects scheduling only, never candidate choice or output.
- At most 25,000 final field-sample positions across the eight attempts plus fallback (including validation halo); precomputed global fields reused. Deterministic budget exhaustion fails closed. A wall-time watchdog may report unavailable but must not select a different seed/template.
- Target generation p95 <=100 ms accumulated CPU per start on the recorded Studio host; 2-second wall-time watchdog under normal local testing. Report cold/warm and per-stage measurements; neither figure is a Roblox guarantee.
- Target <=2 MiB incremental retained Lua memory per country for the nine descriptors and <=256 KiB encoded full generated snapshot. Measure batches and report allocator/GC noise, rather than claiming exact per-table memory.
- Retain P2a graph ceiling 32 nodes/64 lines/200,000 solver scans; live generated graph remains three nodes/two lines. Target demand+solve <=1 ms p95 per country and eight-country batch <=8 ms p95 on the test host. No 256-node/512-line expansion is authorized.
- Static world descriptor replicated once per mount/resync; dynamic demand/weather/report only thereafter, <=8 KiB encoded diagnostic target per periodic snapshot, existing one-second cadence. Serialized-size measurement is a proxy, not actual wire-byte proof.

## Validation and approval consequences

After approval: freeze canonical vectors; build pure generation/validation fixtures; integrate the independent generated profile; run identical-seed and reordered-chunk replay, negative boundaries, fallback, 10,000-seed fairness/diversity sweep, day wrap/midpoint/HVAC/component/quantization/energy tests, malformed bounds and version tests. Retain the exact P2a fixed fixture, hostile transport/security cases and GUI/Native/Hybrid regressions. Run both builds, Studio Script Analysis, matching desktop/tablet/mobile checks, remount/selection/culling/instance tests and endurance; measure generation/step memory/time separately from rendering. Test ownership with separate clients where available and disclose hardware gaps.

No current proposal enables saves, growth, construction, purchases, climate events, annual weather, planning, economy, monetisation, R4/R5 or production. Test universe 10776833313 only; Production 10776828545 untouched. Owner handles future artwork uploads; no assets are required here.

Stage 1 checks actually performed: source-document review; independent arithmetic checks of the two 24-hour table sums, 4.08 MW conservative bound and three primitive hash vectors; local Markdown-link and whitespace checks. No generator, fair-seed sweep, runtime test, performance benchmark or P2b build was performed. Existing P2a results are historical evidence, not P2b results.

API basis reviewed 17 November 2026: Roblox documents [GenerateGUID](https://create.roblox.com/docs/reference/engine/classes/HttpService); Luau documents [bit32 and standard-library numeric operations](https://luau.org/library/). These support feasibility of the proposed implementation, not its distribution quality or measured performance.
