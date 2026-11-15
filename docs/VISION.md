# Vision

Status: confirmed product requirements with proposed success measures. See [Decisions](DECISIONS.md) for architectural approvals.

## Product promise

Run a country by making electricity dependable. Players diagnose visible shortages, invest in networks, use national policy to encourage development, and discover that successful growth creates new demand. Accessible explanations expose enough operational detail for strategy without requiring engineering training.

## Confirmed requirements

1. Roblox and Luau; GUI-only play with no explorable 3D world requirement.
2. Desktop, tablet and mobile support; each player owns a separate fictional country.
3. The starting country has population, settlements, generators and ageing but functioning infrastructure.
4. Procedural expansion supports effectively unlimited progression within technical limits.
5. Generated electricity must pass through a capacity-constrained network to consumers or exports. Generation alone is not revenue.
6. Aggregated demand, maintenance, failures, storage, weather, interconnectors and distinct generation technologies support believable decisions.
7. Energy decisions influence population, industry, approval and the national economy.
8. Government includes policy, subsidies, research, strategic upgrades and major projects; elections/political events may follow later.
9. Employees, inspections, repairs and budget-constrained managerial delegation support larger countries.
10. Optional National Eras reset temporary progress while preserving permanent upgrades, lifetime statistics and historical achievements.
11. Offline-viewable company profiles, achievements, server/global rankings, and national/server/global news provide social context.
12. Data-driven limited-time global events support shared contributions and permanent records, starting with Operation Christmas Cheer.
13. An in-depth tutorial is fully skippable and replayable.
14. Important simulation, economy, progression and reward calculations are server-authoritative; architecture is modular, testable and bounded.

## Design priorities

Proposed priority order: data integrity, understandable cause and effect, mobile usability, satisfying incremental choices, then simulation sophistication. Show both MW (current power) and MWh (energy over time), with plain-language help. Make unreliability visible regionally instead of applying an unexplained national penalty.

Target first-session experience: within ten minutes a new player identifies an underserved settlement, constructs a valid connection and explains why cash changes. Validate with observation rather than treating this as established player research. Experienced players should choose between cheap but congested generation, expensive local generation, network upgrades and demand policy.

## Boundaries

Proposed exclusions: physical avatars as gameplay, household agents, real-world country politics, player-to-player energy trading, mandatory rebirth, real-money finance systems and a professional AC power-flow simulator. Monetisation is undecided and must not silently enter the economy design.

“Virtually unlimited” describes repeatable expansion and progression, not infinite active nodes or permanent full-resolution history. Regional aggregation and National Eras can extend progression, but mandatory rebirth cannot be the only response to a technical cap. See [World](WORLD-AND-EXPANSION.md).

## Product acceptance

The complete vision is met only when all confirmed systems have shipped through the [roadmap](../PLANS.md). The first playable is deliberately smaller. Its acceptance requires a complete build-connect-deliver-earn-grow-save loop on desktop and touch, no client-authoritative money, and recovery from a supply shortage without starting a new save.
