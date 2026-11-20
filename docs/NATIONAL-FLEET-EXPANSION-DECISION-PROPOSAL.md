# National Fleet Expansion — First Player-Owned Wind Farm

19 November 2026 proposal. **W1–W7 approved by the owner on20 November2026 for pure/fake-storage Test implementation only; real execution remains excluded.** The later [implementation gate report](NATIONAL-FLEET-EXPANSION-V1-VALIDATION.md) records the historical W5 gate; D242 now approves the single immutable `legacySimulation` addition, subject to full-profile correctness and size acceptance. Historical proposal wording follows.

**Historical status:** Operations v1.3 authorizes this design only. No schema4 code, permanent purchase, real profile read/write, grant or new runtime technology is introduced. Rowanbridge is not an input to the calculations.

## Owner-approved fake Test decisions (D240, amended by D242)

| ID | Recommendation | Owner decision |
| --- | --- | --- |
| W1 | One surveyed `starter-wind-v1` project:2MW wind generator plus2MW connection, once/country, district prerequisite | Approved for fake Test |
| W2 |4,000 Credits total including survey/connection; Bank ≥4,250 and preserve next-step gross operating reservation; no separate survey fee | Approved;8,000 remains historical hypothesis |
| W3 | Reserved western future pad at local(320,704), rotated with saved starter layout; route north to(320,512), then east to substation(512,512) | Approved; preserves terrain and starter coordinates |
| W4 | Approved wind technology:2MW nameplate, existing v1 deterministic availability kernel,0 Credits/MWh and6 Credits/simulated hour while On; min0/cap in100kW increments; no ramp/storage/export | Approved for owned-country fake Test |
| W5 | Frozen namespaced wind-seed adapter and per-country region `starter-0-0`; schema4/ledger4/economy2/fleet1, no historical re-billing | Approved with D242 immutable legacySimulation addition |
| W6 | Fenced atomic whole-country Build with immutable semantic receipt and exact reconciliation; enable multi-source kernel only after confirmed purchase | Approved for fake storage |
| W7 | Separate pure/fake gate, schema4 readiness/approval, migration approval, then separate real purchase approval | Approved; real execution remains excluded |

## Player progression and site contract

Keep the existing5MW gas station and1,000-resident demand. The existing district project remains1,000 Credits and adds its approved250-resident demand. Requiring the district first gives a clear sequence, not an economic necessity: connect customers, accumulate funds, survey wind, review savings/variability, explicitly purchase, then operate gas and wind together. Survey is a free server eligibility query, not a paid land purchase or construction action.

Use the unused reserved western pad; the eastern pad belongs to the district. Rotate pad and corridor using the saved `StarterValidator.layout` rotation. Validate owned sector0,0, exact saved generation/candidate/version, all existing anchors and district receipt, reserved pad/corridor dry elevation40m, pad slope contract, no overlap with existing assets, and unobstructed authored polyline. Probe pad corners/centre and route every32 world units as in P3c. Route length384 world units is cosmetic geometry; one logical edge runs wind→existing substation with2,000kW capacity. The bend at the gas pad is not an electrical connection to the gas generator. Existing feed/town/district links, IDs and endpoints remain unchanged. One node/one line, no hidden extra capacity, circuit redundancy or power-flow impedance claim.

Suggested stable IDs are `<countryId>:wind:starter:generator` and `<countryId>:wind:starter:feed`, avoiding P3c's `:b:1/:b:2` namespace. Reject unsupported saved topology or failed site validation; do not relocate assets, alter a seed, flatten terrain or silently select another country. Validate all10,000 accepted seed/candidate/rotation fixtures before implementation acceptance.

The grid map previews the existing surveyed slot and route. Show4,000-Credit total, live/confirmed Bank, protected buffer, variable wind potential,6/hour On cost and explicitly conditional fuel savings. Confirm once. Saving blocks the critical transition; no offline catch-up. Only a confirmed complete record displays the new generator. Details/Locate and44px targets use the current shell. Native artwork should replace an existing cosmetic slot or reallocate decorations, keeping≤600 map descendants; no new sprite library is required.

## Electrical abstraction and dispatch

Reuse the exact bounded FleetSolver's lossless integer-kW transport model, max-min sink fairness and minimum-variable-cost source allocation. No AC power flow, frequency, losses, inertia, voltage stability or N−1 guarantee. Do not alter the existing kernel or its native/30Hz4ms/80ms/750ms contract.

For the first permanent fleet, bound to2 sources and2 demand sinks, with5 physical nodes and4 logical edges after district+wind. Gas remains5MW; wind connection2MW; substation/town route10MW; district1MW. Wind is used first when feasible because its variable cost is0. Gas fills the residual. Report each source's actual dispatched kW, available/capped kW and wind curtailment. Curtailment earns nothing. Keeping gas On retains10/hour standby cost even if wind covers demand; switching it Off saves that fixed cost but cannot guarantee service during calm wind. Both Off/disconnected customers still request demand and accrue unmet history.

The current wind v1 kernel interpolates0–800 permille knots, so2MW nameplate currently produces0–1.6MW potential, not a guaranteed2MW. Preserve this behavior explicitly; changing its distribution requires separate approval. Seed adapter proposal: `FNV1a(ASCII "PSFLEET" + NUL + ASCII "v1" + NUL +16 decoded saved seed bytes) modulo2147483647`; freeze the integer result, region `starter-0-0` and windVersion1 in the migrated record. Reuse the existing exact hash arithmetic in a separately namespaced helper, without adding a tag or changing terrain streams. Simulation step, not wall time or join time, selects wind. No rerolling the wind recipe on reconnect.

Keep approved generated-country time-of-day/climate demand and district integer curve. Feed both sources/sinks into the general solver only after purchase; empty-fleet schema4 continues the unchanged legacy single/two-sink path. Cross-check no-wind equivalence and historical financial continuity before switching. Forecasts retain issue step/unchanged controls and distinguish capacity estimates from routed delivery. Disconnection or a later constrained route can curtail wind despite gas elsewhere; no national free energy pool.

## Economics and progression analysis

[Reproducible local calculator](../scripts/AnalyzeFleetExpansion.py) / [results](NATIONAL-FLEET-EXPANSION-CALCULATIONS.json) analytically replay the actual integer P2b demand formula for1,000 residents/17°C, district curve, existing wind knot formula and120/80/10+6 economy.32 synthetic seeds, gas/wind On, no binding network limits, zero initial carries, no new demand/rewards. This is design arithmetic, **not FleetSolver or real-profile acceptance**. Current saved carries may shift a boundary minor unit; future fake replay must use exact captured state.

| Reference synthetic seed | Gas-only | Gas+wind | Difference |
| --- | --- | --- | --- |
| One-day delivered |94.3256MWh |94.3256MWh |0; already served customers |
| One-day gas production |94.3256MWh |76.0380MWh |−18.2876MWh |
| One-day sales |11,319.07 Credits |11,319.07 Credits |0 |
| One-day gas variable costs |7,546.04 Credits |6,083.04 Credits |−1,463.00 |
| One-day fixed costs |240.00 Credits |384.00 Credits |+144.00 |
| One-day operating net |3,533.03 Credits |4,852.03 Credits |+1,319.00 |
| Seven-day operating net |24,731.17 Credits |34,075.14 Credits |+9,343.97 |

After4,000 capital, seven-day comparative Bank is+5,343.97 Credits. In the32-seed seven-day cohort, incremental operating net is9,343.97–9,974.37 Credits (median9,709.41); extrapolated payback67.37–71.92 simulated hours (median69.21). The reference first day alone extrapolates72.78h; neither extrapolation guarantees future wind.

From250 Credits after a district purchase to4,250 eligibility requires4,000 earned Credits: about27.17 simulated hours at the reference gas-only daily average. At one completed minute per real second that is about27 active minutes, before accounting for transaction suspension, service delays or altered generator controls; ordinary menus keep simulation running. A stricter funds reservation wins if greater than250; no prospective sales fund the purchase.

Without the district, reference gas-only net2,778.32/day implies about34.55 simulated hours to earn4,000; W1 deliberately makes district progression a prerequisite. Capping wind to500kW reduces savings to732.73/day and extrapolated payback131.02h. A disconnected but On wind unit costs144/day with no fuel savings. Wind Off yields no wind cost/benefit; calm periods can make On operation temporarily loss-making. Do not alter these rates to guarantee investment returns. The owner subsequently approved4,000 Credits for this fake Test proof under D240; gameplay balance and real execution remain separate acceptance questions.

## Exact proposed schema4 cutover

Start only from a freshly validated schema3 profile with the approved identity/version/lease. No Training state is importable. Pure migration clones the profile, preserves every prior field/value except the explicit version substitutions below, and adds bounded metadata. It creates no asset, cost, grant, wind production or interval.

| Field | Proposed transformation |
| --- | --- |
| `schemaVersion` |3→4 |
| `country.bank.ledgerVersion` |3→4; every amount, currency, grant ID and250 buffer unchanged; add `windConstructionSpentMinor=0` |
| `country.economy.economyVersion` |1→2; preserve existing posted totals, meters, carries, statements, original activationStep/operation and cursor |
| `country.fleet` |New exact-fields version1 object below |
| recipe/seed/generation versions, settlement, original network, deltas, simulation/history, construction/receipt |Bit-for-bit canonical preservation |
| profile/country revision, epoch/lease/lastCommit |Pure preview unchanged; future fenced Migration commit advances only contractually specified revisions, no simulation step |

`fleet` fields: `version=1`, `compositionVersion=1`, `cutoverStep=current simulation.step`, `windVersion=1`, `windSeed`, `windRegion`, `investmentSerial=0`, `windReceipt=nil`, `windState=nil`, `units={ [existing generatorId]=gasUnit }`, `baseline={ legacyEconomy, legacyBank, legacyConstruction, legacySimulation, migrationOperationId }`. Baseline economics/Bank/construction/simulation are complete canonical immutable copies for audit/validation, not a restorable live profile or an independent balance. `migrationOperationId` is prepared once for approved execution; pure design previews use an explicit preview marker and cannot be saved.

`gasUnit` starts with exact old generatedKwMinutes, onlineSteps, variable/fixed expenses and both fractional remainders, costVersion1, on=current generator state, capKW=5000. No new wind unit is created during migration. National delivered/sales meters and their carries remain the existing values. Legacy `generatedKwMinutes` becomes explicitly total generation under economy2; per-unit meters separately sum to it. `onlineSteps` remains the legacy gas online count for compatibility; new units have independent counts. Existing aggregate fixed/variable expense fields become sums of source totals under the new version; the v1 fixed-cost formula must not be reapplied to total fleet On time.

Purchase adds one wind unit with zero meters/carries, agreed initialOn=true and cap2000; node/edge deltas and permanent receipt install together. Each successful later interval adds the server report's per-unit kW-minutes and online minute to its own meters. For each cost component, `postedDelta=floor((oldCarry+minuteNumerator)/60000)` and newCarry modulo60000. Gas rate8000, wind rate0; fixed numerators1,000,000/600,000 per On minute. Sales use delivered kW×12,000 and the preserved sales carry. National posted expenses equal source sums; national sales billed once, never once/source. Under economy2, legacy `variableExpenseRemainder` and `fixedExpenseRemainder` explicitly mirror the original gas unit for compatibility, not a pooled fleet remainder. Each new unit owns separate carries; validation must not combine them and round again. Likewise legacy gas `onlineSteps` must not be used to recompute the new aggregate fixed expense. Operating net excludes both district and wind capital.

Bank conservation: original grant + cumulative base/bonus sales − aggregate operating expenses − original district capital − bank.windConstructionSpentMinor. Existing bonus remains0; future entitlement integration needs a separate approved version. `bank.spentMinor` includes both capital categories; `constructionSpentMinor` remains the original district amount, with separate `bank.windConstructionSpentMinor` so its frozen receipt stays valid. Full v4 validation must verify the legacy baseline with unchanged schema3 projection, all cutover equalities, later per-unit arithmetic, both permanent receipts and asset correspondence. Never make schema3 validation silently accept v4.

Existing schema1/2/3 read/migration regressions remain unchanged. Unsupported, corrupt or mixed versions fail closed. Retain the existing192KiB soft size warning and256KiB hard encoded-profile cap; preflight must show room for baseline and bounded fleet/receipts. No real migration until exact field diff, protected preimage, SHA256/platform metadata and new fake validation have owner approval.

## Atomic construction and recovery

Server catalog fixes project/version, site, capacity, route, price and operating cost. Client sends only bounded intent/quote ID and command sequence. Quote lasts30 seconds, binds authenticated owner/country/session/catalog/topology/site; allow one quote and one pending transaction. Refresh never confirms. Revalidate district prerequisite, not-built receipt, schema, ownership, safe180-second lease/30-second margin, Bank and gross reservation immediately before capture.

Suspend country mutations only for the critical transaction. Capture all confirmed and pending valid earned state once. Whole-profile candidate contains one4,000 debit, one generator/line, controls/recipe, capital total, topology/serial transition and permanent semantic receipt. `BuildWind` fences epoch/token/base revision and exact expected profile. Callbacks assign one immutable candidate, not recompute costs or random seeds. Full returned profile or readback equality establishes success. Missing/denied/ambiguous response retains suspension and reconciles the same operation; no blind refund, forced unlock, replacement purchase or client-side asset activation.

Later checkpoints must preserve the wind and district receipts even when lastCommit changes. Repeated semantic purchase returns AlreadyBuilt without charge. Leave/shutdown resolves or retains the pending operation under existing approved coordinator limits; no release racing an old checkpoint. Reconnect loads either complete old or complete purchased state. No offline production. Recovery after later financial steps cannot restore an old pre-purchase/pre-migration image automatically; any recovery write requires separate review and complete intervening-state reconciliation. Do not add keys/stores for the transaction.

## Required implementation gates

1. Approve W1–W7, particularly price/prerequisite, seed adapter, initialOn state and field contract.
2. Pure site/geometry and schema4 migration tests:10,000 seeds/all rotations, preserved identities/coordinates/receipts/history/carries, malformed/mixed versions, bounded size, no grant/debit/advance, repeated conversion identity.
3. Fake two-source composition/ledger: original one/two-sink fixtures, oracle/fairness/conservation, routed wind curtailment, unavailable/Off/capped/disconnected units, exact rates/carries, no duplicate sales, insufficient gross funding and immutable failed steps. Compare analytical design fixtures to actual solver, including both sides of rounding boundaries and adverse climate/demand phases.
4. Fake atomic purchase: exact affordability ±one minor unit, stale sessions/revisions/quotes, callback retries, lost responses, concurrent save/leave, crash/reconnect, permanent receipts after checkpoints, no debit without node/edge and no node/edge without debit.
5. Native responsive preview/controls, snapshot/scroll/focus stability, source costs and forecasts, original First Playable and Operations retained regressions, eight-country native/30Hz timing/size/queue/memory, both builds/Script Analysis. No copying temporary Training assets into generated countries.
6. Separately approved read-only real readiness; then separately approved migration; then separately approved purchase and bounded post-build electricity proof. Production remains excluded throughout this proposed sequence.

After wind, consider demand expansion or a second surveyed variable/dispatchable investment only after operating data and owner review. New terrain sectors, arbitrary routing, multi-site construction, storage, government systems and additional technologies are not included.
