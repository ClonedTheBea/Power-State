# Power State

Power State is a GUI-only Roblox electricity-grid strategy and tycoon game. Each player runs the energy infrastructure and national energy policy of a separate fictional country, starting with a small connected grid that meets initial demand and offers room to develop.

## Project status

17 November 2026: [Procedural world and gameplay foundation](docs/PROCEDURAL-GAMEPLAY-FOUNDATION.md) is documented, including starting-country generation, climate/demand, a minimal simulation slice, future planning applications and national demand events. **Design only; P2 remains unstarted.** Owner accepts the illustrated settlement direction; Hybrid remains experimental and Native is the default.

Latest: **R3.7 real settlement proof** adds a separate Test-only Original/Settlements comparison using six reusable sprite labels and the verified owner-uploaded image. See [implementation, validation and comparison instructions](docs/R37-VALIDATION.md). Engine suites and three ten-minute soaks passed; desktop/mobile-safe-root captures are recorded. Device review remains outstanding; Native remains production default. Earlier milestone notes below are historical.

Documentation bootstrap and P1 GUI foundation implemented on 15 November 2026. The owner initialized Git and connected Rojo before P1. The responsive shell runs in Studio with illustrative metrics, map navigation and feedback components. Electricity simulation, economy and persistence are not implemented.

**Presentation shell only; P2 has not started.** See [Studio setup and tests](docs/STUDIO-SETUP.md) and [P1 validation and file inventory](docs/P1-VALIDATION.md). No dependencies were installed and no commits, pushes, publishing or deployment were performed.

The GUI specifications are approved: [vision](docs/GUI-VISION.md), [layouts and migration](docs/GUI-LAYOUT-SPEC.md), [components and theme](docs/GUI-COMPONENT-SPEC.md). R1 implements theme tokens and Bank/Credits. **R2 implements the responsive shell:** compact header, operational metrics, grouped collapsible rail, five-item mobile navigation and contextual inspector. **R3 adds the modular illustrated country prototype**, with bounded native terrain, separate infrastructure/links/labels, layer controls and Locate. R3.1 refines native artwork and initial camera framing; see [current validation](docs/R31-VALIDATION.md) and [the modular art proposal](docs/R31-ART-STRATEGY.md). See [R3 validation and file inventory](docs/R3-VALIDATION.md) for current evidence and limitations; [R2 validation](docs/R2-VALIDATION.md) and [R1 validation](docs/R1-VALIDATION.md) preserve earlier milestones. R4, Energy Shop and simulation have not started.

R3.2 local artwork is produced; five motifs are owner-accepted for proof use. [R3.2b local coast correction](docs/R32B-COAST-VALIDATION.md) fixes the inspected grass seam and source opacity; natural cliff endpoints and one filtered-alpha sample remain open for review. See the [six-motif atlas and integration proposal](docs/R32-ART-PROOF-PLAN.md). No hybrid runtime or uploads; R3.1 remains the executable baseline.

R3.3 update: all six motifs are now approved for an isolated proof. The [test-only mock hybrid renderer](docs/R33-VALIDATION.md) passes engine regressions and synthetic benchmarks; native remains the default/fallback. No atlas is uploaded or configured, and the mock displays only labelled diagnostic footprints. Real texture testing requires separate approval. R4/R5/P2 remain unstarted.

## How to read this blueprint

R3.4 Stage 2: the isolated Test proof now loads the approved atlas's verified image dependency (`86222383311104`; uploaded decal `105986918888502`). Production stays Native. See [R3.4 validation, comparison instructions and measured limitations](docs/R34-VALIDATION.md). Future artwork uploads are performed by the owner unless a specific upload is requested.

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
| [Procedural/gameplay foundation](docs/PROCEDURAL-GAMEPLAY-FOUNDATION.md) | New design package, proposed milestones, risks and approval gates |
| [World and expansion](docs/WORLD-AND-EXPANSION.md) | Generation, sectors, map and finite resource budgets |
| [Economy and rebirths](docs/ECONOMY-AND-REBIRTHS.md) | Money, growth, National Eras and exploits |
| [Government](docs/GOVERNMENT.md) | Policy, research and strategic projects |
| [Infrastructure and staff](docs/INFRASTRUCTURE-AND-STAFF.md) | Assets, inspections, repair and automation |
| [UI/UX](docs/UI-UX.md) | Desktop, tablet, mobile and accessibility |
| [GUI vision](docs/GUI-VISION.md) | Reference review, illustrated country art direction, terminology and scope conflicts |
| [GUI layout specification](docs/GUI-LAYOUT-SPEC.md) | Responsive wireframes, navigation, map/inspector/ticker interactions and migration slices |
| [GUI component specification](docs/GUI-COMPONENT-SPEC.md) | Theme/contrast, reusable component states, shop presentation and input contracts |
| [Tutorial](docs/TUTORIAL.md) | Chief Grid Adviser and replayable learning |
| [Multiplayer and news](docs/MULTIPLAYER-AND-NEWS.md) | Isolation, rankings and news delivery |
| [Events](docs/EVENTS.md) | Shared objectives and Operation Christmas Cheer |
| [Company profiles](docs/COMPANY-PROFILES.md) | Offline public identity and historical records |
| [Data and security](docs/DATA-AND-SECURITY.md) | Schemas, persistence, recovery and trust boundaries |
| [Technical architecture](docs/TECHNICAL-ARCHITECTURE.md) | Modules, services, tooling and verified references |
| [Testing](docs/TESTING.md) | Critical invariants, fixtures and release evidence |
| [Decisions](docs/DECISIONS.md) | Confirmed requirements, proposals and owner questions |

## First playable destination

A responsive map shows a seeded temperate country with one initially served settlement, generator and substation. The player develops and connects new demand, sees power delivered and billed, expands generation, observes population growth, saves and reloads, and completes or skips an introductory tutorial. Phases P1–P4 reach this destination; maintenance, storage and social systems follow incrementally.

Development uses strict Luau, Roblox Studio, Rojo and Git. The existing Rokit configuration pins Rojo 7.7.0; the observed Studio plugin is 7.7.1. Tests use a dependency-free Studio assertion harness. See [the setup guide](docs/STUDIO-SETUP.md) for commands and [the setup boundary](docs/TECHNICAL-ARCHITECTURE.md#development-workflow-and-human-boundary) before changing Studio settings.
