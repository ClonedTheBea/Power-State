# Infrastructure and staff

Status: maintenance, inspections, repairs and delegation are confirmed. Costs, staffing ratios and condition curves are proposed D10. [Simulation](ELECTRICITY-SIMULATION.md) owns effective capacities; this system supplies asset condition and availability.

## Asset lifecycle and faults

Every asset has stable ID, definition/version, location, built step, condition, operational state, maintenance history summary, last inspection, known faults and server-private latent faults. Age advances only while the country simulation runs under the proposed no-offline-simulation rule. Condition decays according to age, utilization and weather exposure, with preventive work reducing the future decay rate for a bounded duration.

Proposed states: constructing, active, derated, isolated, failed, repairing and retired. A work order cannot target retired or wrong-owner assets. Repairing requires isolation for specified fault classes; that removes capacity and may cause a planned outage. Retirement cancels or resolves reservations once. Condition does not directly reveal every latent defect to the client.

Proposed wear: condition decreases by a bounded base rate/hour multiplied by utilization, age and weather factors. Failure probability over delta hours is `1 − exp(−hazardPerHour × deltaHours)`, with hazard derived from condition and unresolved defects. Use per-asset seeded draws keyed by simulation step, so different asset iteration order does not reroll failures. Store the relevant random/version state. Cap correlated storm events to a defined affected set rather than rolling unbounded work.

An inspection produces findings and confidence; it does not restore condition. A repair resolves named faults and restores a bounded amount of condition after time, staff and materials are paid. Preventive maintenance reduces risk without guaranteeing immunity. Clearly label “no fault detected” versus “no faults exist.”

## Employee roles

| Role | Responsibility | Delegation boundary |
| --- | --- | --- |
| Grid operator | Switching, alerts and approved dispatch policies | Cannot change national tariffs or spend outside operations budget |
| Engineer | Design/commissioning capacity and complex repair capability | Technology and project prerequisites still apply |
| Inspection personnel | Ground assessment and defect reports | Findings only; no automatic repairs without policy |
| Ground maintenance team | On-site preventive work and repair | Travel/access constraints and materials budget |
| Helicopter inspection team | Rapid corridor surveys | Weather, base access and flight cost |
| Drone inspection team | Frequent local surveys | Range, weather and technology requirements |
| Maintenance manager | Prioritizes inspections/repairs | Player risk threshold, reserve, budget and outage limits |
| Energy trader | Executes permitted import/export policy | Connection capacity, reserve floor and price limits |
| Research manager | Runs research queue | Approved priorities and funded research budget |
| Government adviser | Explains policy effects and flags pressure | Recommendation only unless an explicit policy automation is enabled |

MVP has a starter abstraction for operation; staff simulation arrives later. Proposed staff representation is teams/counts by role and skill tier, not hundreds of individual NPCs. Each team has wage/hour, availability, assigned order and supported capabilities. Hiring costs and payroll are expenses paid from the Bank; firing cannot cancel already-spent work into a refund. Team count and work queue length have explicit caps (proposed 32 teams and 128 queued orders per country).

## Inspection modes

| Method | Proposed relative cost / duration | Capability | Limits |
| --- | --- | --- | --- |
| Ground | Low equipment cost; longest travel | Close mechanical/terminal inspection; high detail | Road/access delay, slow long corridors, cannot enter energized restricted work zones |
| Helicopter | High fixed mobilisation and hourly cost; fastest long corridor | Wide aerial visual/thermal scan | Severe weather/night policy, flight base, misses internal defects |
| Drone | Medium setup, low repeated local cost; short missions | Frequent visual/thermal scan | Range/battery, wind/rain, technology unlock, misses internal defects |

Definitions specify eligible defect classes, deterministic detection probability by severity/method/skill, duration and cost. Weather cancellation pauses or reschedules, retaining paid mobilisation cost. Repeated instant inspections cannot cheaply reroll detection: use an inspection cooldown and seeded finding opportunity per asset/inspection window. Higher-tech methods complement rather than strictly replace ground inspection.

## Work orders and automation

Order record: ID, target asset, type, fault IDs, priority, assigned team, quoted cost, reserved funds, progress hours, required outage, state and originating manager/player. Lifecycle is queued → reserved → travelling → executing → complete, with paused/cancelled/failed alternatives. Team availability and prerequisites gate each transition. One exclusive repair lock per asset; inspections may not operate during incompatible repair work.

Managers run at a proposed 10-simulation-minute cadence with a bounded candidate scan. Policies specify maximum spend/hour, protected cash reserve, fault severity threshold, maximum simultaneous outages and allowed inspection methods. All automated actions call the same command validation/transaction path as player actions. Reserve funds before dispatch, recheck conditions at execution, and record an explanation in the activity feed. An emergency override needs player consent through its configured policy, not hidden unlimited spending.

## Acceptance and stages

P5b adds condition, one inspection method and repair; P6b adds alternate inspection modes and managerial automation, with research/government roles completed in P7. Tests distinguish detection from repair, verify no active power from an isolated asset, bound manager spending under concurrent orders, enforce method limitations, and replay seeded failures after reload. A player can see why work is paused and recover from a blackout without buying an unavailable team. Full employee personalities and 3D vehicles are excluded.
