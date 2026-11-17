# Minimal server-authoritative electricity slice

17 November 2026. Proposed P2 split under D68/D69; **not implementation approval**. [Electricity simulation](ELECTRICITY-SIMULATION.md) remains the conservation/solver authority; this narrows its first enabled features. [Foundation plan](PROCEDURAL-GAMEPLAY-FOUNDATION.md) defines subsequent gates.

## Smallest interactive P2a candidate

One session-only country, one settlement, one 3 MW generator, one 3 MW substation and two 3 MW links. Use a fixed validated starter descriptor first, not the existing five-asset cosmetic demo as live truth. One domestic demand tier, fixed desired 0.75 MW, fixed healthy availability, lossless transport and automatic dispatch. Keep NetworkModel/GridSolver modular; use the existing proposed deterministic residual-flow contract and tests for loops/bottlenecks even if the starting graph is a chain. Do not implement the extended priority/fairness, storage or trade solver at once.

One explicit server-validated operating intent (generator On/Off) provides an observable action: Off causes zero delivery and a shortage; On restores service. Switching is a proposal requiring the P2 implementation request, not a new UI now. Client sends only asset ID, requested boolean, command ID, epoch and expected revision; server checks finite/bounded payloads, ownership, legal transition and rate limits. The displayed art/ID cannot confer ownership. No dispatch MW or money supplied by a client is trusted.

## Step and accounting contract

One serialized country step: validate queued commands → capture immutable population/weather/catalog versions → compute demand/source bounds → solve routes through line and substation gates → validate conservation → integrate MWh/costs → apply once with step/revision → replicate the permitted view. Pure demand/solver functions call no services. Failed calculation or budget exhaustion commits no partial time, energy, money or history; suspend with a diagnostic. No unbounded wall-time catch-up.

Generator available MW is the minimum of nameplate and all enabled derating/dispatch/fuel/weather bounds. In P2a these extra factors are explicitly neutral; actual output equals routed source flow and never nameplate by default. Generator On incurs fixed running cost even at zero dispatch; Off incurs zero operating cost in this narrow candidate (future standby/maintenance separate). Network bottlenecks can curtail generation despite spare installed capacity.

Report includes country/step/revision and model versions; simulated hours; requested/delivered/unmet MW and MWh per demand bus; actual generation/available capacity; signed line flows/shared ratings; substation throughput/rating; island IDs; reason codes; eligible domestic delivered MWh; cost/revenue estimates; reliability window state. National supply means delivered MW. Expose disconnection, source shortage and route bottleneck separately; mixed causes may coexist. Attribute reasons through bounded reachability and source/capacity diagnostics, not by comparing national totals alone.

Instant service ratio is delivered/requested when requested >0, otherwise Unknown. Proposed rolling reliability = sum(deliveredMWh)/sum(requestedMWh) over the last 24 simulated hours, using 24 fixed hourly buckets and an elapsed-history label. Zero-demand history stays Unknown and cannot qualify for rewards. Show partial-window duration; do not invent full-day reliability on a new country. Store bounded bucket/remainder state once saving exists. Reserve margin is separate from reliability; neither is physical frequency stability.

## Sales and operating costs

P2a computes a nonspendable report estimate; it does not mutate Bank, grant rewards or save money. P3 applies the existing exact-once ledger and funded-operation constraints. Eligible sale energy is actual delivered domestic MWh only. No earnings from unused capacity, unmet demand or event forecasts. Income factor remains 1; no shop mechanics.

Use the existing **proposed** illustrative tariff 120 Credits/MWh, inclusive gas variable cost 50 Credits/MWh and fixed On cost 10 Credits/simulated hour. Fuel is included in 50; never charge it again. At 0.75 MW over 1/60 hour: generate/deliver 0.0125 MWh, sales 1.5 Credits, variable cost 0.625, fixed cost 1/6, net estimate 0.708333… Credits. P3 carries fractional minor-unit remainders and settles to integer hundredths; do not truncate every tick. On with zero demand has no sales and still incurs fixed cost. No negative Bank or automatic free fuel is implied; P3 reserves affordable operating costs before solving, as specified in Economy.

## Required fixtures and future interfaces

| Fixture | Expected result |
| --- | --- |
| Starter .75 MW, all 3 MW gates, generator On | .75 MW output/delivery; zero unmet |
| Generator Off or disconnected | Zero delivery/revenue; .75 MW unmet |
| One line or substation restricted to .4 MW | .4 MW output/delivery; .35 MW unmet; no capacity bypass |
| Zero demand, generator On | Zero generation/sales; fixed operating cost remains |
| Isolated demand beside another powered island | No borrowing from a national power pool |
| Duplicate/stale operating command | At most one accepted transition; no double step/energy settlement |
| Three successive steps vs equivalent energy sum | Same MWh and carried-money totals within specified numeric tolerance |

Retain existing 7 MW/4 MW, cyclic/parallel-edge, residual rerouting and conservation fixtures as regression scenarios, not the new starting-country content. Exact integer power scale/tolerances and solver operation limit need approval with D02; no arbitrary precision promise. Proposed quantization is 0.001 MW with explicit bounded residual accounting, to be tested against small demands.

Future technology definitions expose optional fuel inventory/rate, weather potential, ramp MW/hour, minimum stable output, storage MWh/efficiency, import/export contract and maintenance availability. Enable each only with its own versioned balance/conservation tests. Storage discharge is not generation; import supply must route through a real connector. No fuel logistics, renewable dispatch, ramping, storage, imports, maintenance, population growth, planning or events ship in P2a.

Acceptance: server owns the action and report, first tick serves all starting demand, operational interruption/recovery is truthful, aggregate conservation holds, no cross-player leakage, and the existing GUI/input regression suite passes with Native default. Add bounded-step profiling before increasing the graph size. This is a first interactive simulation proof, not the saved construction/economy first-playable promised by P3/P4.
