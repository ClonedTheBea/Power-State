# Technical architecture

Status: Roblox, Luau, GUI-only and server authority are confirmed. Module layout, tool choices, budgets and protocols are proposals D01–D05/D16–D17. API references were checked on 15 November 2026; no software or Roblox integration has been exercised in this task.

## Architecture recommendation

Use one Roblox experience place initially, with multiple independent countries per server. Disable ordinary character-driven gameplay as part of the Studio shell setup; the user interface is the game surface. No Workspace model is the canonical representation of an electrical asset. Render strategic state through client GUI objects and keep the full country graph in server tables.

Prefer plain typed modules and explicit dependency injection before adopting a large framework. Pure domain modules depend on data and injected clock/random interfaces, never Roblox services. Service adapters own network, storage and cross-server calls. Client controllers consume view models and send intent. This separation makes solver/economy tests possible without creating a live server.

## Proposed source layout (not created yet)

| Future path | Roblox destination / role |
| --- | --- |
| `src/shared/Types/` | ReplicatedStorage: protocol/data-view types |
| `src/shared/Catalog/` | ReplicatedStorage: nonsecret display definitions; server validates its own authoritative definitions |
| `src/shared/Util/` | ReplicatedStorage: pure broadly reusable utilities |
| `src/server/Domain/` | ServerScriptService: graph solver, ledger, growth, generation and condition logic |
| `src/server/Services/` | ServerScriptService: country orchestration, policy, orders, progression and event handlers |
| `src/server/Adapters/` | ServerScriptService: persistence, remotes, messaging and indexes |
| `src/server/Bootstrap.server.luau` | Server initialization and dependency wiring only |
| `src/client/Controllers/` | StarterPlayerScripts: input, selection, navigation and subscription lifecycle |
| `src/client/Views/` | StarterPlayerScripts: GUI components and map renderer |
| `src/client/Bootstrap.client.luau` | Client initialization only |
| `tests/unit/`, `tests/integration/`, `tests/fixtures/` | Test suites and versioned saved/replay examples |
| `assets/` | Curated source assets with provenance; separate from canonical country state |
| `default.project.json` | Future Rojo mapping, reviewed before Studio sync |

Use PascalCase files/modules/types, camelCase functions/fields and UPPER_SNAKE_CASE constants. Use `.server.luau`/`.client.luau` suffixes for entry scripts after verifying pinned Rojo handling; ordinary modules use `.luau`. Strict Luau is recommended, with explicit boundary validation. Comments explain units, invariants and algorithm decisions. Avoid circular service dependencies: pass narrow interfaces or publish typed domain events through the country orchestrator.

## Ownership and contracts

| Module/service | Owns | Inputs → outputs |
| --- | --- | --- |
| CountryService | Serialized country mutations and revisions | Validated command/step → new state and domain events |
| WorldGenerator | Versioned deterministic sector descriptions | Seed/coordinate/version → immutable descriptor |
| NetworkModel | Validated nodes, edges and cached topology | Asset/switch changes → routing graph |
| GridSolver | Capacity-constrained flow only | Graph/source/sink bounds → dispatch and delivery report |
| Economy | Money ledger and regional development | Report + policy + delta → charges, growth and approval |
| AssetService | Construction, condition and work orders | Commands + clocks → asset state transitions |
| GovernmentService | Policies/research/projects | Funded decisions → DerivedModifiers and completion events |
| ProgressionService | Achievements and National Eras | Trusted totals/commands → durable reward/reset mutation |
| EventService | Definition lifecycle and personal meters | Eligible delivered export report → cumulative contribution |
| PersistenceAdapter | Load, lease, save, migration, retry | Immutable snapshot/operation → committed revision or failure |
| ProjectionService | Public profiles/ranking writes | Committed state → sanitized derived snapshots |
| NewsService | Rate-limited scoped notices | Allowlisted domain events → durable/transient feed items |
| ReplicationService | Per-player snapshots/deltas and chunk interest | Approved view models → bounded RemoteEvent messages |

Side effects follow commit rules: simulation changes memory once; autosaves commit snapshots; critical rewards wait for durable commit; public publications derive only from saved state. Services cannot directly mutate another country's tables. Cross-server adapters never call into a client to determine truth.

## Scheduling and replication

One server scheduler distributes country steps across frames; do not create an independent Heartbeat loop for every asset. Cache graphs between topology changes. Stage pure calculations, validate the complete accounting result, then apply it once. Fail the country step safely if any invariant fails and emit sampled diagnostics.

Proposed targets at the [World](WORLD-AND-EXPANSION.md) envelope: p95 pure step below 5 ms per country and aggregate eight-country step work below 40 ms per simulated step spread over frames; client target 30 FPS minimum on the agreed low-end test device; full private-state network traffic target below 20 KiB/s/player in normal play. These are hypotheses requiring measurement, not achieved performance.

Initial join sends a summary snapshot and visible sector chunks with protocol version/revision. Subsequent deltas contain baseRevision and revision. Client applies only a matching chain; gaps request a rate-limited resync. Bound snapshot payload chunks (proposed 32 KiB application chunks), total in-flight chunks and client cache. A chunked snapshot must share one revision; buffer or restart if needed rather than blending unrelated revisions.

Use reliable RemoteEvents for commands, command responses and authoritative state deltas; document asynchronous correlation IDs rather than depending on synchronous RemoteFunction waits. UnreliableRemoteEvents may later serve cosmetic telemetry only. The [official remotes guide](https://create.roblox.com/docs/scripting/events/remote) distinguishes these delivery patterns; reliability does not make a remote trusted. Never broadcast every country's full graph to all players.

## Persistence and cross-server services

Use standard DataStoreService records for durable player state, event records and sanitized public projections. Use OrderedDataStore for sortable derived numeric scores. Use MemoryStoreService for expiring coordination/cache entries and MessagingService for notification hints. None supplies a cross-key transaction; [Data](DATA-AND-SECURITY.md) and [Events](EVENTS.md) specify recovery and idempotency explicitly.

Avoid Parallel Luau/Actors initially. Pure country steps may become candidates after profiling demonstrates a need, but serialization boundaries, safe service use and worker state transfer need a separate design. More servers and lower country-per-server caps may be simpler than parallelizing a complex mutable world.

## Development workflow and human boundary

Proposed workflow: source edited locally → format/type/test checks → Rojo build/sync into a dedicated development Studio place → Studio server/client/device tests → review → separately authorized publish. Git/GitHub provide history and review once repository setup is authorized; no repository was initialized in this task.

Rojo has a server/CLI and Studio plugin, with a matching major version required. The official [installation guide](https://rojo.space/docs/v7/getting-started/installation/) documents those components. Pin exact tool versions when P1 begins; this blueprint does not claim a specific latest release. Prefer the official Rojo toolchain path, with installation still requiring authorization. A package manager, formatting tool and test framework are optional until deliberately selected.

Rojo source mappings are the source of truth for mapped scripts. Avoid making Studio-only edits to those scripts that a later sync will overwrite. Curated Studio assets need an explicit export/versioning workflow. Rojo cannot live-sync every property type, as described in its [sync limitations](https://rojo.space/docs/v7/sync-details/); do not assume it controls account permissions, publishing or all Studio properties.

Codex can prepare source, tests, mappings and documentation when authorized. The owner may need to create/select the experience, install/enable the Studio plugin, connect a sync session, set game permissions and API access, run device/Studio checks, and publish. Available automation must be verified before promising to perform these operations. Use an isolated test experience for DataStore integration; Studio access to production stores can affect live data, per [Roblox's data-store guide](https://create.roblox.com/docs/cloud-services/data-stores).

## Official API and tooling verification register

Checked 15 November 2026 by reading official project/platform documentation. These are API capabilities, not local test results. Recheck limits and selected tooling before implementing each dependent phase.

| Source | Verified capability / relevant constraint | Design use |
| --- | --- | --- |
| [Roblox Data stores](https://create.roblox.com/docs/cloud-services/data-stores) | Persistent server-side records; UpdateAsync callback semantics; Studio access caution | Canonical profiles and atomic per-key mutations |
| [Roblox data-store limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits) | Request/throughput/storage constraints; runtime request-budget inspection | Bounded snapshots and priority queues; no copied historic quota formula |
| [Versioning and caching](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching) | Version retention/caching behavior differs from unlimited backups | Explicit recovery fixtures and migration review |
| [OrderedDataStore](https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore) | Sorted score retrieval via GetSortedAsync | Global derived leaderboards |
| [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores) | Ephemeral shared maps/queues with expiry | Temporary coordinator leases/cache, never sole durable record |
| [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService) | PublishAsync and SubscribeAsync | Version/ID notification hints |
| [Cross-server messaging](https://create.roblox.com/docs/cloud-services/cross-server-messaging) | Topic-based server communication | News invalidation; durable polling fallback is our design |
| [Remote events](https://create.roblox.com/docs/scripting/events/remote) | Async events, unreliable events and yielding request/response functions | Intent commands and revisioned state replication |
| [Client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary) | Input validation and rate-limiting requirements | Boundary checks before simulation or spending |
| [Text filtering](https://create.roblox.com/docs/ui/text-filtering) | Developer responsibility for uncontrolled displayed text | Company identity moderation and safe fallback |
| [UI constraints](https://create.roblox.com/docs/ui/size-modifiers) | Scaling, automatic sizing and constraints | Responsive GUI implementation |
| [Luau types](https://luau.org/types/) | Gradual typing and strict mode | Explicit contracts; runtime validation remains separate |
| [Rojo overview](https://rojo.space/docs/v7/) | File-based Roblox development workflow | Source synchronization with Studio |
| [Rojo installation](https://rojo.space/docs/v7/getting-started/installation/) | CLI/server and plugin setup | Version-pinned future environment setup |
| [Rojo sync details](https://rojo.space/docs/v7/sync-details/) | File-to-instance mappings and unsupported live-sync properties | Reviewed mapping and asset workflow |

## Acceptance

P1 proves tool/version selection and a responsive GUI shell only after authorized setup. P2 proves pure simulation contracts; P3 proves persistence against an isolated Roblox environment. Profiling gates precede higher world caps, extra countries per server and event launch. No document here constitutes evidence that a tool is installed, an API succeeds under load or the target frame rate has been reached.
