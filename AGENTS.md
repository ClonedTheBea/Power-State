# Contributor instructions

## Scope and sources

- Read [README.md](README.md), [PLANS.md](PLANS.md), [docs/DECISIONS.md](docs/DECISIONS.md) and the relevant system specifications before changes. Follow confirmed requirements and recorded approved decisions. Proposals are not approvals.
- The bootstrap task is documentation only. Do not implement the game under that task. Later tasks may authorize their stated implementation scope.
- Preserve existing work. Implement only the requested phase or fix; avoid unrelated features. Do not install dependencies, publish, deploy, commit or push without authorization covering that action.
- For future artwork, prepare local files and upload instructions; the owner uploads to Roblox and supplies asset IDs. Do not automate Creator Dashboard uploads unless specifically requested for that upload.
- Resolve specification conflicts in the decision log. Record important new decisions, rationale, status and consequences; update affected documentation when behavior changes.

## Engineering

- Follow the module boundaries and proposed source layout in [Technical architecture](docs/TECHNICAL-ARCHITECTURE.md). Use PascalCase module/type names, camelCase functions/fields and UPPER_SNAKE_CASE constants. Prefer strict, typed Luau.
- Keep client GUI and authoritative server logic separate. Clients send intent and display server results; never accept client currency, rewards, progress, production, demand, clocks or ownership as truth.
- Write small cohesive modules with explicit dependencies. Avoid monolithic scripts and hidden mutable global state. Comment invariants, units and non-obvious tradeoffs rather than narrating syntax.
- Validate every remote's shape, size, finite numeric ranges, authorization, ownership, version, rate and legal transition. See [Data and security](docs/DATA-AND-SECURITY.md).
- Serialize country mutations, make reward claims and critical transitions idempotent, and prevent duplicate charges/rewards. Never perform external side effects in retried persistence callbacks.
- Preserve electricity and money invariants in [Electricity simulation](docs/ELECTRICITY-SIMULATION.md) and [Economy](docs/ECONOMY-AND-REBIRTHS.md).
- Bound simulation work, GUI instances, replication, queues, save size and historical data. Never add per-household simulation or assume unbounded Roblox capacity.
- Test simulation, persistence, economy, migration and security changes using [Testing](docs/TESTING.md). A mock does not prove real Roblox service behavior.

## Completion evidence

Report files and behavior changed, checks actually run, results and remaining work. Distinguish verified behavior from untested assumptions and manual Studio steps. Do not claim a playable build, service guarantee or approval without evidence.
