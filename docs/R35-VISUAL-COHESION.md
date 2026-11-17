# R3.5 — Hybrid map visual cohesion

16 November 2026. Owner accepts R3.4 technical evidence but has not approved Hybrid as the default. R3.5 authorizes Test-only presentation refinement and future-art planning. No new artwork, uploads, asset IDs, gameplay or production changes.

## Implemented marker experiment

`tests/integration/HybridPresentation.luau` decorates the existing map only through the isolated HybridProof. Production contains neither module. Its five existing 44×44 buttons, electrical positions, accessibility names, activation handlers, focus objects, cluster picker and selection brackets remain intact.

When Hybrid is Ready, the dark target background and border become transparent. The existing technology silhouette is drawn as a 22px circular badge in the upper-right portion of its original target. This exposes more of the illustrated building without creating a second clickable object or moving a connection anchor. The badge stays entirely within the 44px target; floating it outside that target was rejected because the visible affordance would no longer match the tappable region. Five reusable Frame/UIScale/UICorner bundles add 15 descendants, reaching 595 map descendants with the atlas, below the existing 600 limit. No per-pan allocations, new textures or animated effects.

Names are contextual: selected asset, mouse hover or keyboard/gamepad GUI focus. The existing label toggle, collision suppression and viewport clipping still apply. The Assets list and inspector retain full names when a map label cannot fit. Touch selection opens the existing inspector; hover is never the only path to information. The existing cyan selection brackets and focus outline are retained to preserve the approved non-colour-only distinction. A separate selection ring was considered but is not implemented: at current scale it would compete with the ground artwork and duplicate the brackets. It can be reviewed later with larger building footprints.

Native mode, loading and failed/unavailable images retain or restore the original marker artwork, background and labels. A Test-only `CohesionEnabled=false` attribute on CountryMap displays the R3.4 marker treatment with the same real atlas for direct comparison; true/nil enables R3.5 once ready. Neither control exists in production. Destroy/remount releases the decorator and restores original view functions and child parenting.

## Art consistency inventory — proposals, not implemented artwork

| Visible clash | Proposed treatment | Constraints |
| --- | --- | --- |
| Native rounded hills and forest triangles beside painted ridge/forest | Quiet native colour masses underneath a small family of painted relief/vegetation motifs | Never fill the scene with individual trees; retain bounded patch pool and fallback |
| Straight native fields beside curved illustrated agriculture | Reuse a compatible field-region grammar with hedgerow edge variants | No arbitrary mirroring that reverses upper-left lighting; no repetitive whole-region stamps |
| Newford painted houses versus native Southbank/Eastmere blocks | One village prototype and a restrained coastal attachment, sharing roof/wall palette with Newford | Existing settlements/ports remain illustrative; no new gameplay capacity implied |
| Painted cliff abruptly joins outlined native shore | A limited endpoint transition treatment following the approved shore probes/tangents | Do not move coastline geometry or hide failed joins with unrelated objects |
| Native angular river/roads against painted terrain | Keep readable ribbons initially, reduce purely decorative contrast only after a matched review | Transmission geometry and analytical overlays remain separate and unchanged |
| Dark industrial pads and marker symbols compete with buildings | Grounded building silhouette with a small screen-space badge and contextual name | Art pivot is cosmetic; connection terminal stays authoritative and stationary |

Recommended composition, back to front: water/base land; compatible coast backing; native meadow masks concealing the coast's opaque inland overlap; bounded terrain/relief patches; settlement/industrial illustrations; native transmission lines; fixed-screen-size hit targets/badges; labels, selection and focus feedback. Keep the actual approved coast ordering from R3.4. Do not add a country-sized overlay, global texture filter, extra gameplay layer or per-household geometry.

For future sectors, record each motif's world footprint, ground pivot, overhang, art revision, edge compatibility and palette/lighting family. Choose variations from stable cosmetic descriptors, independently from gameplay identities. Edge families need explicit land/shore/water contracts; a transparent rectangle alone does not establish seamless tiling. Use a bounded visible-sector pool and retain the native fallback on missing variants. Sector generation itself is outside R3.5.

The current proof has only five map descendants of headroom beneath its 600 limit. Future artwork must replace/reuse budgeted presentation slots or first obtain a measured pool redesign; a bigger atlas does not authorize more simultaneously visible instances. Do not keep adding hidden variants or allocate a sprite per household. A future variant swap should reuse the existing ImageLabel where compatible, retaining a bounded native fallback pool.

## Settlement development visual contract — design only

The eventual renderer consumes a server-supplied settlement identity, development tier and cosmetic descriptor revision. It must never infer tier, demand, population, income or connection state from the sprite, its density or a local timer. Thresholds, growth rules and downgrade behavior require separate gameplay approval.

| Visual stage | Recognisable silhouette | Stable information |
| --- | --- | --- |
| Village | Low roofs, open plots, gardens and one small civic landmark | Same settlement ID, ground pivot and electrical terminal |
| Town | Denser street block, civic tower, mixed low/mid-rise roofs | Same terminal; art changes cannot reroute existing links |
| City | Bounded skyline cluster, stronger civic centre, denser contiguous districts | Aggregate illustration, never one GUI object per building |
| Industrial centre | Distinct warehouse/turbine/service-yard profile and freight access motif | A parallel district specialisation, not an automatic residential tier or proof of generation |

Proposed descriptor separation: `settlementId` and `connectionAnchor` identify the network entity; `artFamily`, `artTier`, `artRevision`, `groundPivot`, `worldFootprint`, `overhang` and `fallbackKind` describe cosmetic presentation. Unknown tiers use the native labelled fallback; they must not masquerade as zero population or missing electricity. The current five IDs/anchors and frozen six-motif manifest are unchanged.

All variants in a family share a documented ground reference. A taller roof extends upward from it; increasing density fills a reserved footprint rather than moving the terminal. If a future stage genuinely needs a larger footprint, validate its conservative culling envelope and collisions independently, without modifying network endpoints. Swap a ready texture atomically after a coherent server snapshot; retain the last compatible illustration/native fallback during loading. No crossfade or additional pool allocation is required. Selection, inspector, camera and accessibility identity survive the cosmetic swap.

Acceptance for a later village/town/city proof: overlay the same anchor crosshair and transmission endpoints on every tier at all five zooms; verify constant target location, readable 44px controls, bounded overhang, no edge seams, missing-tier fallback, stable instance counts and no client gameplay writes. Include downgraded/unknown revisions and rapid out-of-order cosmetic updates in future integration tests.

## Recommended next step

Owner review of R3.5 screenshots and badge/label behavior first. Then request a narrowly scoped **local** art sample (one native-village replacement plus one terrain/shore transition study), with an explicit atlas/pivot/gutter/provenance specification, before extending the library. Do not repack or overwrite revision 3 as part of this stage. The owner uploads any separately approved files and supplies IDs. Keep Native as production default until cohesive visuals and real-device usability/performance are accepted.

See [R3.5 validation](R35-VALIDATION.md) for measured evidence and remaining limitations. This document proposes future artwork and presentation contracts; it grants no upload or later-phase implementation approval.
