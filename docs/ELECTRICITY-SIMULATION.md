# Electricity simulation

P2a update,17 November2026: the owner subsequently approved the fixed5 MW generator/3 MW demand/10 MW substation fixture and isolated live implementation. [Current P2a contract and evidence](P2A-VALIDATION.md) supersedes earlier P2a candidate values/status below; future procedural/climate/economy proposals remain unimplemented.

17 November 2026: [Minimal simulation](MINIMAL-SIMULATION.md) narrows the proposed P2a enabled features; [Climate and demand](CLIMATE-AND-DEMAND.md) specifies the proposed component demand model for P2b and later. Existing 7 MW examples remain regression fixtures, not the revised starting-country content. P2 reports sales/cost estimates only; spendable settlement remains P3. No simulation is implemented.

Status: networked delivery is confirmed. The solver, units, clocks and tuning here are proposals D02–D03. This is the authoritative specification for power accounting; [Economy](ECONOMY-AND-REBIRTHS.md) bills its outputs.

## Units and clock

| Quantity | Unit / rule |
| --- | --- |
| Capacity, dispatch, demand, line flow | MW, nonnegative magnitudes; signed flow only for edge direction |
| Energy and storage state | MWh |
| Cash | Integer hundredths of a Credit; user-facing balance is Bank, no Robux conversion |
| Condition, availability, efficiency, service ratio | Bounded 0–1 |
| Simulation | Fixed one-second wall scheduler; each completed step advances 1/60 simulated hour |
| Operating cost / fuel | Credits per simulated hour, Credits per MWh, and fuel units per MWh |
| Calendar events | Server UTC timestamps, independent of simulated time |

At this speed a simulated day lasts 24 wall minutes. Growth and research use explicit simulated-hour rates; event dates use UTC. A step delivering 6 MW produces 0.1 MWh. Do not multiply MW directly by a price per MWh. Keep fractional money/energy remainder accumulators and round at settlement boundaries; repeated tiny steps must not create or destroy billable energy.

D22 confirms one standard simulation speed for all countries and removes all proposed player/paid speed controls. The exact standard conversion above remains a D03 proposal. Double Income (design only) multiplies eligible sales revenue in Economy, never this clock, physical outputs, demand, growth, maintenance, reliability, lifetime energy or event contribution meters. A future confirmed country pause suspends progression and active boost time together; no client-only timer pause is authoritative. Event UTC schedules continue independently.

Use a monotonic scheduler, not client clocks. Process at most two overdue steps per frame slice; if overload persists, drop accumulated wall backlog without advancing the simulation clock, record lag and display slowed simulation. No giant delta-time catch-up or unbounded loops. Exact scheduler targets require profiling.

## State and responsibility

The server owns graph topology, switch status, asset health, dispatch settings, policy modifiers, weather state, demand, fuel and storage. A pure step consumes an immutable country snapshot, a fixed delta, versioned balance data and deterministic random state, and returns proposed next state plus an accounting report. It makes no service calls or GUI instances. The country service applies the result once and issues replication updates.

Nodes represent generator terminals, substations, regional demand buses, storage and interconnectors. Edges represent bidirectional transmission links with one shared MW rating. Split substations into input/output capacity gates so a bypass cannot evade their rating. Domestic distribution is an aggregate capacity gate from each regional bus to its residential/industrial demands; households are never nodes. Node/edge IDs and traversal order are stable.

Disconnected components are independent electrical islands. A closed edge may have signed flow, but total use of the physical link cannot exceed its rating. Opposite-direction routing must cancel or share capacity rather than granting two independent full ratings. Multiple components must never share an unphysical national supply pool.

## Recommended initial solver

Use a deterministic, capacity-constrained transport flow approximation with zero transmission losses in the MVP. It preserves energy and connectivity without pretending to solve electrical impedance.

1. Apply queued commands at the step boundary; derive effective ratings from health, policy, outages and the funded operating bounds in [Economy](ECONOMY-AND-REBIRTHS.md). Rebuild the routing graph only when needed; cache stable topology.
2. Compute each region's residential and industrial desired MW from population, base intensity, a deterministic daily demand curve, tariffs and policy. Clamp rates and modifiers. Compute regional weather from seeded time-indexed functions.
3. Compute source bounds: minimum of nameplate × condition derating × availability, dispatch cap, fuel-limited output and weather/resource limit. Off/failed generators have zero availability. MVP minimum stable output and ramp limits are zero/instantaneous; later versions can add constraints explicitly.
4. Route domestic demand first, by published service priority (essential domestic, other domestic, flexible industry). Use a residual-network min-cost maximum-flow solver, maximizing delivery within a tier before minimizing operating cost. Reverse residual edges must undo prior allocations; simple greedy paths without rerouting can strand feasible supply. Use deterministic integer-scaled costs and ID tie breaks.
5. For fairness within each tier, use a deterministic common served-fraction target: bounded binary search (proposed 12 iterations) over the same fraction of each sink request, then route residual feasible demand with stable rotating sink priority. This prevents ID order permanently starving a settlement. The solver API permits replacing this policy; test the iteration bound and residual pass.
6. After domestic flows are locked, route permitted exports and storage charging over remaining capacity. Prohibit simultaneous charge/discharge on a device and simultaneous import/export for the country. Use the country import mode whenever domestic demand requires imports; exports are disabled in that step. Storage may charge only in a charging step and supplies no discharge source in that step.
7. Compute actual generator output from source flow, not requested dispatch or nameplate. Fuel and variable cost follow output; standby/staff costs follow configured operating state. Curtailed renewable potential earns nothing.
8. Advance storage, settle supply/demand statistics and return the report. Apply money, wear and growth once. Later failure logic samples at the end of the step and affects the next step, preserving a single consistent topology per solve.

For P2 use one domestic priority and no trade/storage; retain the same conservation report and routing contract. Fair allocation complexity is a prototype risk: do not ship the extended solver before its bounded workload is measured. An operation-budget exhaustion invalidates the entire proposed step; it must not settle partial electricity or money. Pause that country with a diagnostic and limit further graph growth until recovery.

## Technology definitions

| Type | Proposed dispatch characteristics | Distinct cost / constraint |
| --- | --- | --- |
| Gas | Flexible dispatch up to available MW | Fuel per MWh; moderate construction, high variable cost |
| Coal | Dispatchable; later slow ramping | Fuel, emissions and greater maintenance |
| Nuclear | High steady availability; later outage scheduling/minimum output | High capital, fixed staffing, long construction; no weapon mechanics |
| Solar | Nameplate × daylight × cloud factor | No fuel; curtail excess; zero at night |
| Wind | Nameplate × bounded weather curve | No fuel; calm/cut-out conditions; correlated region weather |
| Hydro | Site-limited output and water budget | Water inflow/storage accounting in later phase; no unlimited river energy |

Each asset definition has technology ID/version, capacity, fixed cost/hour, variable cost/MWh, fuel intensity, health curve and build requirements. Initial fuel is a paid automatic supply with a configured price; discrete fuel inventories and logistics are deferred. Hydro uses a finite renewable resource budget even before reservoir detail. Weather persists through seed, algorithm version and simulated step index; reload must not reroll bad weather or faults.

## Storage and trade

For grid-side charge power Pc and discharge power Pd:

`nextStoredMWh = storedMWh + Pc × hours × chargeEfficiency - Pd × hours / dischargeEfficiency`.

Enforce charge/discharge MW ratings, 0 ≤ nextStored ≤ capacity, efficiencies in (0,1], and device mode exclusivity. Discharge availability cannot exceed stored × dischargeEfficiency / hours. Charging is a network demand, discharge is a source, and storage discharge is excluded from lifetime generation. Round-trip efficiency is the product of both efficiencies. Proposed initial storage is a battery with 0.95 each-way efficiency; values require approval.

Interconnectors are owned boundary nodes with a shared connection rating, contracts, import supply bounds and export sink bounds. Charge for delivered imports, pay for delivered exports, and constrain both through the domestic graph. Non-event exports can use storage if allowed by contract, but event exports exclude storage-origin and imported energy in the initial event version (see [Events](EVENTS.md)). Domestic-first dispatch is the proposed default; player priority overrides are deferred.

## Conservation and worked fixtures

For lossless MVP each completed step satisfies:

`generatedMWh + importedMWh + gridDischargedMWh = domesticDeliveredMWh + exportedMWh + gridChargedMWh`.

Also: delivered ≤ requested; all flows ≤ effective capacities; unmet = requested − delivered; fuel/cash deductions nonnegative; storage internal losses are accounted separately from grid-delivered discharge. Spilled/curtailed potential is not generation. If later forced minimum output creates spill, add explicit measured spill to the equality and exclude artificial dump-load generation from competitive eligibility pending D11.

Fixtures at 1/60 hour:

- 10 MW available generator → 4 MW line → 7 MW demand: generate/deliver 4 MW, unmet 3 MW, bill 4/60 MWh.
- Remove the line: zero delivery/revenue to that island, irrespective of national spare capacity.
- 10 MW source, 6 MW domestic, 3 MW export cap, 2 MW charge request: route 6 domestic, 3 export and 1 charge if all paths permit; output 10 MW.
- A 1 MWh battery discharging 6 MW with 0.95 efficiency for one step ends at approximately 0.894737 MWh; it delivers 0.1 MWh.
- Domestic demand 8 MW behind a 5 MW line with 12 MW generation: domestic delivery is 5 MW. An export elsewhere may use residual power only after domestic routing has maximized feasible service; the UI must call the remaining domestic problem congestion, not lack of generation.

## Reliability and stability

Condition and failures follow [Infrastructure](INFRASTRUCTURE-AND-STAFF.md). Hard capacity limits create congestion and shedding rather than sustained invisible overload. Later emergency overload may permit brief extra flow at accelerated wear, but requires explicit duration limits and tests.

Proposed “grid stability” is a 0–100 operational reserve/reliability score computed per island from spare dispatchable reserve and recent unserved energy. It is not frequency in hertz. Do not model frequency, voltage, reactive power, fault current, inertia or cascading electrical transients in MVP. Regional blackouts end when a powered path and capacity are restored; staged reconnection and cold-load pickup may be added later.

Transport flow permits paths that real power would not follow and ignores Kirchhoff loop flows, voltage, phase angles and line losses. Later DC load flow needs line reactance, reference bus per island, a linear solver, constrained dispatch and new fixtures; AC load flow adds reactive/voltage models and is unlikely to justify mobile-strategy complexity. Keep solver version in saves/replays and preserve the report contract so upgrades can be compared offline before migration.

## Acceptance

P2 must pass the fixtures, deterministic replay, cyclic/parallel-edge capacity tests, conservation and graph limits in [Testing](TESTING.md). P5b adds failure/repair fixtures and P6a adds technology and storage fixtures. Culling the map must never change simulation output; a solver timeout must never create money; fixed seeds and commands must reproduce results within declared numeric tolerance.
