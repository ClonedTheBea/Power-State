# World and expansion

Status: procedural sectors, 2D construction and bounded expansion are confirmed. Generation algorithms and limits are proposals D04/D05. See [Data](DATA-AND-SECURITY.md) for storage ownership and [UI](UI-UX.md) for interactions.

## Sector identity and generation

Use integer sector coordinates `(sx, sy)` and local coordinates in a proposed 1,024 × 1,024 world-unit square. One world unit represents 10 map metres; geometry is a strategic abstraction. IDs combine generation version, sector coordinate and stable local index. Avoid array positions as persistent identity. The country holds a seed, generation version and explicit owned-sector set.

Generate a sector from a stable hash of country seed, coordinates and generation version, with separate random streams for terrain, settlements and resources. Discovering sectors in a different order must produce identical results. Do not depend on engine random iteration order or floating-point noise stability across future algorithm changes; pin the algorithm and retain old generators while saves reference them.

Proposed terrain classes: plains (baseline cost), forest (clearing premium), hills (line/site premium), mountains (large premium and fewer sites), water (special crossing/site restrictions). Resource attributes include wind exposure, solar potential, hydro sites, industrial suitability and fuel-resource bonuses. Bonuses change costs/availability through explicit modifiers; they do not create a second hidden source of electricity.

Each sector descriptor contains bounded generated settlements, candidate sites, resource scores and terrain samples. Persist generated identifiers plus changes: built/removed assets, population/development, ownership, depleted resource state and exceptional terrain edits. Store a starter fixture override so every seed has a viable opening. Do not regenerate existing modified sectors using a newer algorithm.

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

Partition GUI rendering into sector chunks indexed by a spatial lookup. Compute visible world bounds from pan/zoom; request only owned visible chunks plus a one-chunk margin. Server validates interest requests against ownership and request-size/rate limits. Preview descriptors expose only permitted information. Maintain a small LRU cache; discard stale revisions on resync.

At far zoom show regional demand/supply totals, major substations and trunk connections. At medium zoom show settlements, generation and outages. At near zoom show sites, labels and line status. Pool GUI objects and labels; proposed maximum 600 visible map objects plus 200 labels, with clustering before that limit. Lines crossing the viewport must render even if endpoints are outside it. Selecting a culled asset opens its data panel without forcing all country geometry to render.

## Acceptance and stages

P2 uses one handcrafted generated fixture; P5a introduces seeded adjacent acquisition and terrain costs. Later consolidation is P12 research, not a hidden MVP dependency. Tests cover order-independent generation, negative coordinates, cross-sector line geometry, maximum routes, discovery/reload parity, old-generation saves and culling without simulation change. At the cap, the player receives a useful limit explanation and spends nothing.
