# National Demand Events — future design

17 November 2026. Confirmed future demand-event direction; proposed D70 mechanics. Separate from global export/reward events in [Events](EVENTS.md) and from R4 news presentation. No event engine, reward, ticker or multiplayer system is implemented.

## Events change loads, not displays

| Event | Authoritative effect | Forecast distinction |
| --- | --- | --- |
| Football half-time kettle surge | Short additive residential MW pulse across eligible settlements | Announced match window; bounded uncertain start/amplitude |
| Major television event | Residential activity pulse with a decay curve | Published programme time, imperfect participation estimate |
| Cold snap / heatwave | Regional ambient temperature anomaly through WeatherModel | Forecast range versus committed weather realization |
| Industrial commissioning | Once-only activation of an approved industry's persistent load schedule | Forecast commissioning window; not a recurring pulse plus duplicate base load |
| National celebration | Temporary bounded residential/commercial activity loads | Known calendar occasion, uncertain participation |

Each instance has country/era/event ID, definition/version, deterministic stream key, affected demand component/settlement set, scheduled start/end simulation step, actual amplitude/shape, forecast revision/confidence and lifecycle Planned → Forecast → Active → Completed/Cancelled. Persist the bounded realization or its pinned deterministic parameters before presenting a committed forecast; reconnect cannot reroll it. Forecast errors use a separate stream and do not reveal exact future values to the client. “Not perfectly predictable” never means changing actual weather after observing the player's response.

Proposed forecasts publish an expected MW band and time window at least six simulated hours ahead for scheduled pulses, revised closer to onset. Staff may later narrow uncertainty/extend the horizon within defined limits; they cannot alter actual demand. Unscheduled events require a separately balanced warning policy. Clock is the country simulation calendar, paused offline; a future real-world broadcast tie-in must explicitly define UTC eligibility and no offline catch-up. Do not mix the global event calendar with domestic simulated half-time by accident.

## Integration and bounds

DemandModel sums additive pulses in MW for eligible connected **and disconnected** settlements; GridSolver determines delivery and shortfall normally. A forecast is not demand. Weather anomalies change HVAC terms once; never also add a generic heatwave multiplier. Industry commissioning moves demand into the permanent base at its commit boundary; retire the temporary transition so it cannot be counted twice.

Proposed triangular surge: 0→0.3 MW over five simulated minutes, then 0.3→0 over five. Its requested extra energy is `0.5 × 0.3 × (10/60) = 0.025 MWh`; actual delivery may be less. Integrate event shapes over step intervals or split at their knots so coarse steps do not miss the entire pulse. Use a fixed maximum number of subintervals and reject unsupported definitions before scheduling.

Proposed limits: eight active events and 16 forecast instances per country, 32 shape knots per definition, bounded affected settlement lists within the 64-demand-group envelope. Same-category temperature anomalies use a documented precedence/combination rule; additive consumer pulses share a published demand-envelope cap. On overflow, defer/reject scheduling with a diagnostic rather than silently discard genuine demand or allocate unbounded work. Preserve a compact completion key/history, not per-tick event records.

Fast-response generators, batteries and emergency imports are future ordinary source/dispatch options constrained by ramp, energy and network ratings. No event grants free electricity or bypasses a bottleneck. Income is only from actually delivered eligible MWh through the ordinary ledger; no special event reward is assumed. Do not bill a predicted surge or treat shedding as an event success.

## Tests and gates

Replay before/during/after a surge across disconnects; duplicate activation; interval boundary integration yielding 0.025 MWh; partial delivery and line bottlenecks; overlapping weather/consumer events; forecast uncertainty versus unchanged actual realization; zero-population eligibility; industry base-load transition; maximum event/subinterval work; no GUI-only KPI effects. Forecast cadence, amplitude distributions, political consequences and staff costs require balance approval. Implement one deterministic pulse only after P2b demand and P3 save/ledger reliability; the full catalogue and response technologies remain separate later milestones.
