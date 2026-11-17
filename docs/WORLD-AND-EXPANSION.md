# World and expansion

**P2b update — 17 November 2026:** The P2b isolated implementation follows [approved v1](P2B-DECISION-PROPOSAL.md) with one active 1024-square starting sector, 3x3 internal validation descriptors and the D86 climate-radius amendment. It does not stream, explore or purchase further sectors. [Validation](P2B-VALIDATION.md).

17 November 2026 P2b Stage 1: [specific implementation recommendations](P2B-DECISION-PROPOSAL.md) now consolidate the earlier options and identify conflicts with accepted P2a. **Historical gate: the original radius failed pre-integration validation. D86 subsequently approved 4608 units; the amended implementation and available [validation](P2B-VALIDATION.md) now pass.** Historical candidate values below are not silently promoted or replaced.

17 November 2026 design update: [Starting country](STARTING-COUNTRY.md) defines the owner-confirmed one-settlement temperate start and proposed seed/delta contract. [Climate and demand](CLIMATE-AND-DEMAND.md) separates continuous environment from cosmetic biome art. [Foundation plan](PROCEDURAL-GAMEPLAY-FOUNDATION.md) proposes P2a/P2b; none is implemented. Older R3 measurements below are historical.

R3.1 update: the owner requested visual refinement after accepting R3 technically. Current native art/framing, 1,091 passing assertions and 574-map-descendant measurements are recorded in [R3.1 validation](R31-VALIDATION.md). The [modular art recommendation](R31-ART-STRATEGY.md) remains a proposal; no uploads or future gameplay are authorized. Historical R3 measurements below are retained.

Status: procedural sectors, 2D construction and bounded expansion are confirmed. Generation algorithms and limits are proposals D04/D05. See [Data](DATA-AND-SECURITY.md) for storage ownership and [UI](UI-UX.md) for interactions.

## Sector identity and generation

Use integer sector coordinates `(sx, sy)` and local coordinates in a proposed 1,024 × 1,024 world-unit square. One world unit represents 10 map metres; geometry is a strategic abstraction. IDs combine generation version, sector coordinate and stable local index. Avoid array positions as persistent identity. The country holds a seed, generation version and explicit owned-sector set.

Generate a sector from a stable hash of country seed, coordinates and generation version, with separate random streams for terrain, settlements and resources. Discovering sectors in a different order must produce identical results. Do not depend on engine random iteration order or floating-point noise stability across future algorithm changes; pin the algorithm and retain old generators while saves reference them.

Proposed terrain classes: plains (baseline cost), forest (clearing premium), hills (line/site premium), mountains (large premium and fewer sites), water (special crossing/site restrictions). Resource attributes include wind exposure, solar potential, hydro sites, industrial suitability and fuel-resource bonuses. Bonuses change costs/availability through explicit modifiers; they do not create a second hidden source of electricity.

Each sector descriptor contains bounded generated settlements, candidate sites, resource scores and terrain samples. Persist generated identifiers plus changes: built/removed assets, population/development, ownership, depleted resource state and exceptional terrain edits. Use the versioned bounded starting-region reservation/candidate/fallback contract in Starting country so every seed has a viable opening. Do not regenerate existing modified sectors using a newer algorithm.

## Acquisition and placement

Expansion selects an adjacent unowned sector along a shared boundary, obtains a server-generated quote and purchases it. Proposed cost rises with owned sector count and terrain, with a preview of available resources. Cap frontier previews and query radius. Reject non-finite/out-of-range coordinates, nonadjacent claims, duplicates, exhausted storage budgets and stale quotes before charging.

Construction supports free-positioned substations at legal sites and node-to-node lines, optionally with a small number of player route waypoints. MVP uses straight node-to-node links; intersections are not electrical junctions unless a substation exists. Endpoints must belong to the player, support the line voltage class and be in owned sectors. A proposed line has at most eight waypoints and a 20 km length limit; longer routes need intermediate substations.

Server computes route length, terrain intersections, crossing permissions, effective rating and cost. Integrate distance across bounded terrain samples, with a maximum sample count and reject overly complex routes. Cost = fixed terminals + sum(segment km × technology cost/km × terrain factor) + explicit crossing fees. Terrain affects construction cost, not unexplained energy losses. MVP has one voltage tier; later tiers require transformer assets. Parallel lines are allowed only if priced and physically counted; duplicate request IDs never build another line.

All route segments must pass through owned terrain or an explicitly purchased right of way; MVP has no rights of way outside ownership. Deleting a substation with live attached lines is rejected until those lines are removed. Owned sectors cannot be sold while containing assets or population in the initial design.

## Bounded progression

Proposed initial budgets: 16 owned sectors, 256 electrical nodes, 512 physical lines and 64 demand aggregates per country; eight simultaneous countries per server for profiling. These are engineering envelopes, not Roblox platform limits or balanced launch promises. Show the current construction cap before purchase; reaching a cap never corrupts a save or silently deletes infrastructure.

Before increasing limits, measure encoded save size, solver time, memory and replication under the [Testing](TESTING.md) workload. Raw procedural seed generation does not solve the cost of storing all player changes. Unvisited sectors are neither simulated nor saved. Owned offscreen sectors still contribute to the grid: viewport culling is only a rendering optimization.

Proposed later region consolidation replaces a completed region's interior with a bounded aggregate: boundary buses, transfer-capacity envelope, generation mix, demand, storage, condition distribution, operating costs and growth state. Require the player to accept the loss of detailed interior editing or support a bounded number of retained detail snapshots. Preserve all cross-boundary connections and validate energy/cost equivalence over representative cases before consolidation. It cannot merely discard internal bottlenecks. If safe aggregation is not ready, keep finite disclosed caps; do not advertise infinite active construction.

National Eras provide additional progression but remain optional. Long-term alternatives are region upgrades and consolidation. An endlessly growing list of consolidated regions also needs higher-level merging and a bounded history strategy. Approval and a tested design for this are required before claiming virtually unlimited expansion at launch.

## Map rendering and data interest

R3 presentation prototype (implemented, not a world-generation milestone): the existing 1200×800 authored plane is retained, with 17 cosmetic patches, five asset markers and three sample links. Rendering has independent terrain/infrastructure/connection/label/selection containers, a fixed reusable pool, conservative viewport culling and a hard 600-map-descendant ceiling. Actual fixture count is 448. No sector acquisition, authority, resync protocol or persistent 1024-unit sector conversion is implemented. The mechanisms below remain future contracts; native art does not prove their larger-world budgets. See [R3 validation](R3-VALIDATION.md).

Partition GUI rendering into sector chunks indexed by a spatial lookup. Compute visible world bounds from pan/zoom; request only owned visible chunks plus a one-chunk margin. Server validates interest requests against ownership and request-size/rate limits. Preview descriptors expose only permitted information. Maintain a small LRU cache; discard stale revisions on resync.

At far zoom show regional demand/supply totals, major substations and trunk connections. At medium zoom show settlements, generation and outages. At near zoom show sites, labels and line status. Pool GUI objects and labels; proposed maximum 600 total map descendants, including hidden fallback, decorations and labels, with clustering before that limit (D66 supersedes the earlier 600 objects plus 200 labels proposal). Lines crossing the viewport must render even if endpoints are outside it. Selecting a culled asset opens its data panel without forcing all country geometry to render.

## Acceptance and stages

Proposed P2a uses one fixed validated starter; P2b adds bounded seed-generated starting terrain and climate-aware demand; P5a retains adjacent acquisition and terrain costs. This sequencing is design-only D69, awaiting implementation approval. Later consolidation is P12 research, not a hidden MVP dependency. Tests cover order-independent generation, negative coordinates, cross-sector line geometry, maximum routes, discovery/reload parity, old-generation saves and culling without simulation change. At the cap, the player receives a useful limit explanation and spends nothing.

## Procedural generation and interest boundaries — proposed D66

Generate immutable terrain/resource descriptors in bounded jobs, keyed by seed/version/sector. At most one active generation job per country and a proposed queue of four; coalesce duplicates and cancel obsolete previews. Cache static environment once; compute time-varying weather only for owned demand/resource aggregates. Unowned preview regions do not simulate, earn or grow. Offscreen owned demand always participates in server simulation. No client request can choose a seed, terrain cost or resource amount.

Use absolute world-field samples and a canonical border ownership rule for coastline/rivers so neighboring chunks do not regenerate incompatible edges. Store world-coordinate node anchors independently of sector art. Cross-sector lines reference endpoint IDs and authoritative routes; sampling/intersection work remains bounded by existing route rules. Preview may show coarse climate/resource ranges; ownership and content revision determine what exact descriptors may be replicated. Acquisition revalidates adjacency, quotes, canonical generation version and storage budget, then commits ownership/debit once.

Proposed client interest: at most nine visible-plus-margin chunk descriptors, 16 cached descriptors, four in-flight requests; if viewport spans more, request a coarser summary rather than all detail. These are internal hypotheses, not proven platform limits. Revisioned snapshot/delta protocol remains in Technical architecture. Use a shared sprite/overlay pool across chunks, evict least-recent unselected descriptors, retain selected asset data in the inspector and render crossing links independently of endpoint visibility. Never instantiate one full current demo per chunk. Missing art uses bounded Native visuals; missing authoritative data says Unavailable. An art tier swap reuses its presentation slot and fixed terminal anchor.

The current six-image/595-descendant Test proof establishes no multi-sector capacity. Before a procedural renderer implementation, budget terrain, labels, hit targets, selection, cached hidden instances and line segments together under 600, with LOD and target clustering. If a pool redesign is necessary, propose and profile it separately; do not silently raise the ceiling. Existing 44px interaction and accessibility contracts persist. See the foundation risk register and starter migration contract for old-version/save behavior.
