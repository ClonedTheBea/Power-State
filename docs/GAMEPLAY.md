# Gameplay

Status: confirmed loop and feature scope; starting values, timings and command rules below are proposed defaults (D01–D04 in [Decisions](DECISIONS.md)).

## Player loop

Inspect demand and reliability → find the limiting generator, line or substation → compare investment and policy options → submit construction or operational orders → observe delivered electricity and costs → grow population and industry → reinvest. Later layers add maintenance scheduling, storage dispatch and delegated decisions. Players can always inspect why a region is underserved.

## Starting fixture

Use one owned sector with a 12 MW gas station, two 10 MW substations, a 6 MW transfer line, two connected settlements requesting 4 MW and 3 MW, and an unconnected 2 MW settlement. Route the first 4 MW load locally and the second across the transfer line. Initial reachable demand is 7 MW, so the grid works and has room to improve. Give assets 80–90% condition without an immediate forced failure. Condition mechanics activate only in their later phase.

Proposed start: 100,000 credits, 10,000 total residents distributed 4,000/3,000/3,000 across these settlements; settlement demand coefficients produce the fixture above and may differ by development level. Unconnected residents exist but do not pay electricity bills. These values are test fixtures, not balanced launch promises. Site costs must leave at least one affordable valid connection and enough reserve for ten simulated operating hours. Validate this when construction prices are set.

The initial choice is connecting the third settlement, not building the first source of electricity. Explain that 12 MW nameplate is available potential: dispatch initially generates only the 7 MW needed by connected customers.

## Order lifecycle

Client preview → server validation → accepted order/reserved funds → construction or immediate MVP completion → active asset → operating/derated/isolated/failed → repair or retirement. A client preview is an estimate; if cost or topology changed, reject with an updated quote instead of silently charging more.

Every request carries a request ID, session epoch and expected country revision. Server derives the player identity from the connection, validates ownership and command-specific constraints, and processes one country mutation at a time. The reply includes accepted/rejected status, reason and new revision. Retry the same request without double charging; stale requests require a refreshed preview. Critical persistent operations use durable operation IDs, not just an in-memory cache.

Construction costs are debited once when accepted. MVP construction completes in that transaction. Later timed orders reserve sites and connections; cancellation refunds only the configured unspent portion, never the original quote plus sale proceeds. Damaged or unbuilt assets cannot operate. Selling an asset removes its network contribution before the next simulation step and refunds less than its net paid cost. Dependent lines must be removed or the sale rejected with a clear reason.

## Emergencies and recovery

During a shortage, show unmet MW, affected regions and the cause: unavailable generation, capacity bottleneck or disconnection. Allow shedding low-priority industry, restoring a line, dispatching spare generation, reducing optional exports or requesting emergency import capacity. Never imply that generation on a disconnected island supplies the entire nation.

Proposed insolvency protection: restrict discretionary spending at zero cash; keep a minimal starter operator service and a once-per-era recovery restructuring that cancels optional projects and grants restricted repair credit. Its amount, eligibility and consequences need balance approval (D08); do not implement an unlimited bailout loop. Essential inspection/repair must remain achievable without a rebirth.

## Time and sessions

Use the simulation clock from [Electricity simulation](ELECTRICITY-SIMULATION.md). Proposed MVP has no offline production, growth, maintenance decay or construction progress. Disconnect pauses the country at its last durable state. Global event calendars use real UTC time and do not pause. Reconnection must not award elapsed offline event exports. Time acceleration and offline earnings require a separate approved design.

## Acceptance and dependencies

P2 proves the initial fixture and shortages; P3 enables construction, settlement and saving; P4 completes the first playable with tutorial. A valid connection increases reachable demand, actual supplied MWh produces revenue, an invalid route spends nothing, and disconnect/rejoin restores the latest saved state. Repeated clicks, a stale quote and deleting a connected substation must each have explicit, tested outcomes.
