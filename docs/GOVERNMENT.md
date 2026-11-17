# Government

17 November 2026: [Planning applications](PLANNING-APPLICATIONS.md) proposes permission, conditional approval, funding and idempotent commissioning as a separately gated future P7 extension. Permission alone creates neither population nor electrical capacity. No initial-simulation planning or staff gameplay is authorized.

Status: Government owns national policy, research, subsidies, major projects and strategic upgrades. Policy values and administrative mechanics are proposals D06/D09. [Economy](ECONOMY-AND-REBIRTHS.md) defines the single Bank balance.

## Future interface

Owner-confirmed R1 clarification: Government will use inner tabs **Overview, Policies, Projects, Priorities and Legislation**. This is a future layout requirement, not R1 implementation or approval of new legislation/election gameplay. Tab contents remain governed by the relevant phase and system decisions.

## Responsibilities and data

GovernmentService owns policy selection, budget envelopes, research queues and national project stages. It produces a versioned DerivedModifiers record consumed at the next simulation boundary. It does not directly set generated MWh or credit revenue. Each policy definition has ID/version, prerequisites, level/options, adoption cost, recurring cost, effects, incompatible policies, enactment delay and cooldown.

Budget categories: operations, maintenance, development, research and subsidies. Sum of reserved commitments cannot exceed available cash after the protected reserve. Recurring budgets are spending ceilings per simulated hour, not prepaid money; order reservations are already encumbered funds and cannot be spent again. Display allocated, committed, spent and free cash separately.

## Proposed initial policies

| Policy | Operational effect | Cost / tradeoff |
| --- | --- | --- |
| Household tariff | Changes billed price and residential demand elasticity | High rates reduce approval and growth |
| Efficiency campaign | Reduces residential MW per resident after enactment | Program cost and gradual adoption |
| Industrial development grant | Accelerates funded industry's development | Greater future MW demand; expense paid from the Bank |
| Clean-energy support | Discounts eligible construction from a finite subsidy envelope | Consumes a budget allocation from the Bank; no unlimited refund |
| Emissions standard | Restricts dirty-plant dispatch or adds an explicit emissions operating cost | May reduce affordable capacity and approval in underserved regions |
| Reliability standard | Sets reserve targets and manager maintenance priorities | Less optional export and more maintenance spending |

Modifiers are derived from policy IDs/levels and approved balance data on the server, not serialized client values. Publish the effective time and predicted direction of change. Enactment is serialized with construction and dispatch, so one step never applies half the old and half the new policy set. A policy cannot be repeatedly toggled to collect adoption grants; cooldown and cost are applied at acceptance. If a funded program runs out of money, pause its benefits and show the cause at the next boundary.

## Research

Research definitions form a directed acyclic graph: prerequisite IDs, points required, cost/hour, staff requirement, unlocked technology and era/permanent scope. Validate the graph for cycles and missing references before release. Initial research runs one project at a time, advancing only when its staffing and budget requirements are met. Store accumulated points, not a client finish timestamp. Completion unlocks catalog entries once; it does not directly spawn free assets.

Proposed early nodes: improved gas efficiency, higher-capacity lines, battery storage and drone inspections. Exact unlock ordering must match phase availability; do not show purchasable research for unimplemented assets. Permanent research acceleration affects rate, not prerequisites. Ordinary completed research resets with an era unless explicitly marked permanent.

## National projects

Projects use planned → funded → constructing → commissioned, with paused/cancelled alternatives. Each stage specifies cost, simulation-hour duration, prerequisites and physical outputs. Example: a regional transmission backbone requires owned endpoints, approved route and funded segments; on completion it creates ordinary network assets with ordinary capacity and upkeep. A nuclear programme unlocks sites and technology rather than bypassing construction. Cancellation follows the same nonrefundable spent-cost rules as ordinary construction.

Commissioning atomically checks IDs and applies outputs so retry cannot duplicate assets. A lost prerequisite pauses the project; it never grants partial hidden capacity. Project boundaries and definitions are versioned so changing future balance does not silently corrupt an active project.

## Approval and political pressure

Approval derives from [Economy](ECONOMY-AND-REBIRTHS.md). Low reliability can trigger bounded advisory objectives such as restoring a region; rewards must be finite and cannot exceed the cost of intentionally manufacturing repeated crises. Proposed later elections are fictional policy mandate events, offering temporary constraints or bonuses. They do not remove ownership or force a rebirth. Whether elections exist at all remains D09.

## Acceptance and rollout

P7 introduces tariff, efficiency policy, one research chain and one staged national project. Tests must show a policy changing actual demand/cost/capacity through DerivedModifiers, budget exhaustion pausing benefits, repeated enactment not duplicating effects, cycle rejection, and commissioning exactly once. Elections, party simulation and complex taxation remain outside that phase.
