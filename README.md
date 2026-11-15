# Power State

Power State is a GUI-only Roblox electricity-grid strategy and tycoon game. Each player runs the energy infrastructure and national energy policy of a separate fictional country, starting with an imperfect but functioning grid.

## Project status

Documentation bootstrap completed on 15 November 2026. This folder was empty and was not a Git repository when inspected. There is no gameplay implementation, installed toolchain, Studio place, or verified playable build. No dependencies were installed and nothing was committed, pushed, deployed or published.

**This milestone is documentation only. Stop before implementation.** Future implementation requires a new task from the owner. The recommended first task is phase P1 in [PLANS.md](PLANS.md).

## How to read this blueprint

- **Confirmed** means a requirement supplied by the owner, not a tested implementation.
- **Proposed** means an architectural recommendation, design default or balance value awaiting owner approval. All unspecified mechanics and numbers in these documents are proposals; writing them down does not approve them.
- **Verified API** means checked against official documentation on 15 November 2026, not exercised in Studio. The source register is in [Technical architecture](docs/TECHNICAL-ARCHITECTURE.md).
- **Deferred** means part of the intended game, outside the first playable scope.

[Decisions](docs/DECISIONS.md) tracks approval status, unresolved choices, contradictions and risks. Approval should be recorded there with date and rationale. Authoritative details live in the document responsible for that system; cross-document conflicts must be resolved explicitly rather than silently choosing a value.

## Documentation index

| Document | Responsibility |
| --- | --- |
| [AGENTS](AGENTS.md) | Instructions for future contributors and Codex sessions |
| [Plans](PLANS.md) | Phases, dependencies and acceptance gates |
| [Vision](docs/VISION.md) | Product requirements, audience and boundaries |
| [Gameplay](docs/GAMEPLAY.md) | Player loop, starting state and command lifecycle |
| [Electricity simulation](docs/ELECTRICITY-SIMULATION.md) | Units, dispatch, routing, conservation and limitations |
| [World and expansion](docs/WORLD-AND-EXPANSION.md) | Generation, sectors, map and finite resource budgets |
| [Economy and rebirths](docs/ECONOMY-AND-REBIRTHS.md) | Money, growth, National Eras and exploits |
| [Government](docs/GOVERNMENT.md) | Policy, research and strategic projects |
| [Infrastructure and staff](docs/INFRASTRUCTURE-AND-STAFF.md) | Assets, inspections, repair and automation |
| [UI/UX](docs/UI-UX.md) | Desktop, tablet, mobile and accessibility |
| [Tutorial](docs/TUTORIAL.md) | Chief Grid Adviser and replayable learning |
| [Multiplayer and news](docs/MULTIPLAYER-AND-NEWS.md) | Isolation, rankings and news delivery |
| [Events](docs/EVENTS.md) | Shared objectives and Operation Christmas Cheer |
| [Company profiles](docs/COMPANY-PROFILES.md) | Offline public identity and historical records |
| [Data and security](docs/DATA-AND-SECURITY.md) | Schemas, persistence, recovery and trust boundaries |
| [Technical architecture](docs/TECHNICAL-ARCHITECTURE.md) | Modules, services, tooling and verified references |
| [Testing](docs/TESTING.md) | Critical invariants, fixtures and release evidence |
| [Decisions](docs/DECISIONS.md) | Confirmed requirements, proposals and owner questions |

## First playable destination

A responsive map shows a small country with existing generation and connected settlements. The player connects an underserved settlement, sees power delivered and billed, expands generation, observes population growth, saves and reloads, and completes or skips an introductory tutorial. Phases P1–P4 reach this destination; maintenance, storage and social systems follow incrementally.

Development is intended to use Luau, Roblox Studio, Rojo, Git and GitHub. Exact versions, test runner and repository setup remain proposals. See [the setup boundary](docs/TECHNICAL-ARCHITECTURE.md#development-workflow-and-human-boundary) before using tools or changing Studio settings.
